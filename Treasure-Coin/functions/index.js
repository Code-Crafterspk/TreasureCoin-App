const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// Configure Nodemailer with your email service
const transporter = nodemailer.createTransport({
  service: 'gmail', // Change this if you are using another email service
  auth: {
    user: 'saadflutterdev@gmail.com', // Your email
    pass: 'Iamtheone@11' // Your email password (or app-specific password)
  }
});

// Cloud Function to send the reset code
exports.sendResetCode = functions.https.onCall(async (data, context) => {
  const email = data.email;

  // Generate a 6-digit code
  const code = Math.floor(100000 + Math.random() * 900000).toString();

  const mailOptions = {
    from: 'saadflutterdev@gmail.com',
    to: email,
    subject: 'Password Reset Code',
    text: `Your password reset code is: ${code}`,
  };

  try {
    await transporter.sendMail(mailOptions);
    // Store the code temporarily in Firestore or Realtime Database (optional for verification)
    await admin.firestore().collection('passwordResetCodes').doc(email).set({ code });

    return { success: true, message: 'Code sent successfully' };
  } catch (error) {
    console.error('Error sending email:', error);
    throw new functions.https.HttpsError('internal', 'Unable to send email');
  }
});

// Cloud Function to verify the code
exports.verifyResetCode = functions.https.onCall(async (data, context) => {
  const { email, code } = data;
  const doc = await admin.firestore().collection('passwordResetCodes').doc(email).get();

  if (!doc.exists) {
    throw new functions.https.HttpsError('not-found', 'No reset code found for this email');
  }

  const storedCode = doc.data().code;

  if (storedCode === code) {
    return { success: true, message: 'Code verified successfully' };
  } else {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid code');
  }
});
