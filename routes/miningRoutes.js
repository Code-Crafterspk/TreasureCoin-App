import express from 'express';
import jwt from 'jsonwebtoken';
import MiningSession from '../models/MiningSession.js';
import cookieParser from 'cookie-parser';
import mongoose from 'mongoose';
import User from '../models/User.js';
const { ObjectId } = mongoose.Types;

const router = express.Router();

const authenticateToken = (req, res, next) => {
    const token = req.cookies.token;

    if (!token) {
        return res.status(401).json({ error: 'Unauthorized access. Please log in.' });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ error: 'Invalid token. Please log in again.' });
        }
        req.user = user;
        next();
    });
};

// New route to start a mining session
router.post('/mining/start', authenticateToken, async (req, res) => {
    const existingSession = await MiningSession.findOne({ userId: req.user.userId, isMining: true });

    if (existingSession) {
        const elapsed = Date.now() - new Date(existingSession.startTime).getTime();
        const hoursElapsed = elapsed / (1000 * 3600);
        
        if (hoursElapsed >= 24) {
            existingSession.isMining = false;
            existingSession.endTime = Date.now();
            const coinsEarned = Math.floor(hoursElapsed) * 0.1;
            existingSession.coinsMined += coinsEarned;
            existingSession.totalCoins += coinsEarned;

            await existingSession.save();
        } else {
            return res.json({ message: 'An active mining session is already in progress' });
        }
    }

    const newSession = new MiningSession({
        userId: req.user.userId,
        startTime: Date.now(),
        isMining: true,
        coinsMined: 0,
        totalCoins: existingSession ? existingSession.totalCoins : 0,
        lastUpdated: Date.now()
    });

    await newSession.save();
    res.json({ message: 'Mining session started' });
});

router.get('/mining/status', authenticateToken, async (req, res) => {
    const session = await MiningSession.findOne({ userId: req.user.userId, isMining: true });

    let miningDuration = 0;
    let coinsEarned = 0;
    let startTime = null;

    if (session) {
        startTime = session.startTime;
        const currentTime = Date.now();
        miningDuration = Math.floor((currentTime - startTime) / 1000);
        const hoursMined = Math.floor(miningDuration / 3600);
        coinsEarned = (hoursMined * 0.1).toFixed(1);

        session.coinsMined = coinsEarned;
        await session.save();
    }

    res.json({
        session: session ? session.toObject() : null,
        miningDuration,
        coinsEarned,
        startTime
    });
});

router.post('/mining/stop', authenticateToken, async (req, res) => {
    const session = await MiningSession.findOne({ userId: req.user.userId, isMining: true });
    if (session) {
        const elapsed = Date.now() - new Date(session.startTime).getTime();
        const hoursElapsed = elapsed / (1000 * 3600);
        session.isMining = false;
        session.endTime = Date.now();

        const coinsEarned = Math.floor(hoursElapsed) * 0.1;
        session.coinsMined += coinsEarned;
        session.totalCoins += coinsEarned;
        await session.save();

        res.json({
            message: 'Mining session stopped',
            session,
            miningDuration: elapsed / 1000, // in seconds
            totalCoins: session.totalCoins
        });
    } else {
        res.json({ message: 'No active mining session found' });
    }
});

router.get('/mining/progress', authenticateToken, async (req, res) => {
    const session = await MiningSession.findOne({ userId: req.user.userId, isMining: true });

    if (!session) {
        const previousSession = await MiningSession.findOne({ userId: req.user.userId }).sort({ endTime: -1 });
        return res.json({
            message: 'No active mining session. Here is your previous data:',
            totalCoinsMined: previousSession ? previousSession.totalCoins : 0
        });
    }

    const currentTime = Date.now();
    const miningDuration = Math.floor((currentTime - session.startTime) / 1000);
    const percentage = ((miningDuration % 3600) / 3600) * 100;

    res.json({
        session,
        miningDuration,
        percentageCompleted: percentage.toFixed(2),
        totalCoinsMined: session.totalCoins
    });
});

router.get('/rewards/monthly', authenticateToken, async (req, res) => {
    const startOfMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1);
    const rewards = await MiningSession.aggregate([
        { $match: { userId: req.user.userId, startTime: { $gte: startOfMonth } } },
        { $group: { _id: "$userId", totalCoins: { $sum: "$coinsMined" } } }
    ]);
    
    const monthlyRewards = rewards.length > 0 ? rewards[0].totalCoins : 0;
    res.json({ totalMonthlyRewards: monthlyRewards });
});

router.post('/referral/invite', authenticateToken, async (req, res) => {
    const referralCode = `${req.user.userId}-${Date.now()}`;
    
    await Referral.create({ userId: req.user.userId, referralCode });

    res.json({ message: 'Referral link generated', referralLink: `https://yourapp.com/register?ref=${referralCode}` });
});

// Claim rewards route
router.post('/rewards/claim', authenticateToken, async (req, res) => {
    const userId = req.user.userId;
    const currentDate = new Date();

    const lastMonth = new Date(currentDate);
    lastMonth.setDate(currentDate.getDate() - 30);

    try {
        const sessions = await MiningSession.aggregate([
            {
                $match: {
                    userId: new mongoose.Types.ObjectId(userId),
                    startTime: { $gte: lastMonth },
                    isMining: false,
                },
            },
            {
                $group: {
                    _id: {
                        $dateToString: { format: "%Y-%m-%d", date: "$startTime" }
                    }
                }
            },
            {
                $sort: { _id: 1 }
            }
        ]);

        let consecutiveDays = 0;
        let maxConsecutiveDays = 0;
        let previousDate = null;

        sessions.forEach(session => {
            const activityDate = new Date(session._id);

            if (previousDate) {
                const diffInDays = Math.floor((activityDate - previousDate) / (1000 * 60 * 60 * 24));
                
                if (diffInDays === 1) {
                    consecutiveDays++;
                } else if (diffInDays > 1) {
                    consecutiveDays = 1;
                }
            } else {
                consecutiveDays = 1;
            }

            maxConsecutiveDays = Math.max(maxConsecutiveDays, consecutiveDays);
            previousDate = activityDate;
        });

        let coinsToClaim = 0;
        if (maxConsecutiveDays >= 28) {
            coinsToClaim = 20;
        } else if (maxConsecutiveDays >= 21) {
            coinsToClaim = 15;
        } else if (maxConsecutiveDays >= 14) {
            coinsToClaim = 10;
        } else if (maxConsecutiveDays >= 7) {
            coinsToClaim = 5;
        }

        if (coinsToClaim === 0) {
            return res.json({
                message: 'You are not eligible for rewards',
                totalCoins: 0
            });
        }

        const user = await User.findById(userId);
        if (user) {
            user.walletCoins = (user.walletCoins || 0) + coinsToClaim;
            await user.save();

            return res.status(200).json({
                message: `You have successfully claimed ${coinsToClaim} coins!`,
                totalCoins: user.walletCoins
            });
        } else {
            return res.json({ message: 'Error claiming rewards' });
        }

    } catch (error) {
        console.error(error);
        return res.json({ message: 'Error claiming rewards' });
    }
});

export default router;
