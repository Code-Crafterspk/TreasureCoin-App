import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mining/miningApp/mainScreen/miningDataProvider.dart';
import 'package:mining/miningApp/utils/constants.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class mainScreen extends StatefulWidget {
  PersistentTabController controller = PersistentTabController(initialIndex: 0);

  mainScreen({super.key, required this.controller});

  @override
  State<mainScreen> createState() => _mainScreenState();
}

class _mainScreenState extends State<mainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF05086f),
        body: CustomScrollView(slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Stack(
              children: [
                Container(
                  height: 218,
                  width: 430,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: AppColors.primaryColor,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo Image
                      Image.asset(
                        "assets/topLogo.png",
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(height: 15),

                      // Estimated Reward
                      Consumer<DataProvider>(
                        builder: (context, dataProvider, child) => Text(
                          'Estimated Reward: ${dataProvider.estimatedReward}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 22,
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Reward Date
                      Consumer<DataProvider>(
                        builder: (context, dataProvider, child) => Text(
                          'Reward Date: ${dataProvider.rewardDate}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 22,
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 202,
                  left: -45,
                  child: Container(
                    height: 374,
                    width: 518,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/middleImage.png"),
                      ),
                      color: AppColors.textColor,
                    ),
                  ),
                ),

                // Refer Friends Container
                Positioned(
                  top: 364,
                  left: 20.55,
                  right: 20.55,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.primaryColor,
                    ),
                    width: 384.45,
                    height: 216.4,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Refer Friends, Earn Rewards',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  offset: Offset(0.5, 0.5),
                                  blurRadius: 1.0,
                                  color: Colors.black.withOpacity(0.9),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Share Your Referral link:',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 3),
                          Consumer<DataProvider>(
                            builder: (context, dataProvider, child) => Text(
                              dataProvider.referralLink,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Referral Stats',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  offset: Offset(0.5, 0.5),
                                  blurRadius: 1.0,
                                  color: Colors.black.withOpacity(0.9),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 3),
                          Consumer<DataProvider>(
                            builder: (context, dataProvider, child) => Text(
                              'Friends Joined: ${dataProvider.friendsJoined}',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Consumer<DataProvider>(
                            builder: (context, dataProvider, child) => Text(
                              'Commission Earned: \$${dataProvider.commissionEarned}',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Consumer<DataProvider>(
                            builder: (context, dataProvider, child) => Text(
                              'Referral Rewards: \$${dataProvider.referralRewards}',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Positioned(
                  top: 610,
                  left: 20.55,
                  right: 20.55,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top Miners This Month',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF002366),
                              shadows: [
                                Shadow(
                                  offset: Offset(0.5, 0.5),
                                  blurRadius: 1.0,
                                  color: Colors.black.withOpacity(0.9),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 1),

                          // Leaderboard entries
                          Consumer<DataProvider>(
                            builder: (context, dataProvider, child) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var miner in dataProvider.topMiners)
                                  Text(
                                    '#${dataProvider.topMiners.indexOf(miner) + 1} ${miner['name']} - \$${miner['amount']}',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 1),

                          // See Full Leaderboard
                          Text(
                            'See Full Leaderboard',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF002366),
                              shadows: [
                                Shadow(
                                  offset: Offset(0.5, 0.5),
                                  blurRadius: 1.0,
                                  color: Colors.black.withOpacity(0.9),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    width: 384,
                    height: 150,
                  ),
                ),
              ],
            ),
          )
        ]));
  }
}
