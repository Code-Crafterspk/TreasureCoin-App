import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mining/authentication/signup.dart';
import 'package:mining/boardingScreen/ButtonWidget.dart';

import '../authentication/login.dart';

class LastboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/background.png', // The path to your background image
                fit: BoxFit.cover, // Ensures the image covers the entire background
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 80), // Adjust this value to move the text down as needed
                  const Text(
                    'You Are Here!',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 30,
                      color: Color(0xFFf5cf04),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40), // Space between the text and the next content
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/img_1.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: const Text(
                      'Ready to start your treasure hunt? Log in or sign up to begin your journey!',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 21,
                        color: Color(0xFFf5cf04),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // Buttons at the bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Login button on the left
                  ButtonWidget(title: 'Login', onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );                  }),
                  // Signup button on the right
                  ButtonWidget(title: 'SignUp', onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
