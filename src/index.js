// server.js
import express from 'express';
import mongoose from 'mongoose';
import bodyParser from 'body-parser';
import authRoutes from '../routes/authRoutes.js';
import miningRoutes from '../routes/miningRoutes.js';
import dotenv from 'dotenv';
import cors from 'cors';
import cookieParser from 'cookie-parser'; 
import path from 'path';

dotenv.config();
const app = express();

// Set the view engine to EJS
app.set('view engine', 'ejs');
app.set('views', path.join(process.cwd(), 'Backend/views')); // Use process.cwd() for dynamic path resolution

// Middleware
app.use(cors({
    origin: 'http://localhost:3000', // Change this to your React app's port
    credentials: true, // Enable cookies to be sent with requests
  }));
app.use(cookieParser()); // Add cookie-parser middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use(express.static(path.join(process.cwd(), 'public')));


// RoutesStatus
app.use('/api/auth', authRoutes);
app.use('/api', miningRoutes);

dotenv.config();

const uri = process.env.MONGO_URI; // Ensure this matches your .env file



dotenv.config();



const mongoURL = 'mongodb://127.0.0.1:27017/treasure_coin'; // Manual MongoDB connection string

mongoose.connect(mongoURL, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => console.log('MongoDB connected successfully'))
.catch((error) => console.error('Error connecting to MongoDB:', error));

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send({ message: 'Something went wrong!' });
});
//Home Route
// Example route in your backend
app.get('/api/home', (req, res) => {
    const homeData = {
        title: "Welcome to the Home Page",
        message: "This is the home page content.",
    };
    res.json(homeData); // Send data as JSON
});


// Registration Route
app.get('/register', (req, res) => {
    res.render('register'); // Render the registration EJS file
});

app.post('/api/auth/register', async (req, res) => {
    const { username, password } = req.body;
    // Registration logic here (check for existing users, hash password, save user)
});

// Login Route
app.get('/login', (req, res) => {
    res.render('login'); // Render the login EJS file
});

app.post('/api/auth/login', async (req, res) => {
    const { username, password } = req.body;
    // Login logic here (check credentials, create session or JWT)
});

// Start server
const PORT =  3000; // Use environment variable or fallback to 5000
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});


process.on('SIGINT', () => {
    mongoose.connection.close(() => {
        console.log('MongoDB connection closed.');
        process.exit(0);
    });
});
export default app;