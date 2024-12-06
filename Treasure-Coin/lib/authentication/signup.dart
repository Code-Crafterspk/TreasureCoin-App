import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:shared_preferences/shared_preferences.dart';
import '../boardingScreen/lastboardingScreen.dart';
import '../miningApp/utils/bottomNavigationBar.dart';
import 'googleButton.dart';
import 'login.dart'; // Assuming you have a login screen implemented

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  bool loading = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _clearStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // Remove any stored token
  }

  Future<void> _storeJwtToken(String token) async {
    await _clearStoredToken(); // Clear any old token
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token); // Store the new token
  }

  Future<String?> getStoredJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> signup(String email, String password) async {
    setState(() {
      loading = true;
    });

    try {
      // Use Firebase Auth to create a new user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.toString(),
      );

      // Check if the user was created successfully
      if (userCredential != null && userCredential.user != null) {
        // Save the user's name to Firebase Auth profile
        await userCredential.user!.updateProfile(displayName: nameController.text.trim());
        await userCredential.user!.reload();

        // Save user data to SharedPreferences
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save(); // This triggers the onSaved method for each form field

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', nameController.text.trim());
          await prefs.setString('email', emailController.text.trim());
          await prefs.setString('password', passwordController.text.trim());

        }

        setState(() {
          loading = false;
        });

        // Navigate to login screen or next screen
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen())
        );
      } else {
        setState(() {
          loading = false;
        });

        Fluttertoast.showToast(
          msg: "User creation failed. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });

      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'The email address is already in use by another account.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        default:
          message = 'An error occurred: ${e.message}';
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      setState(() {
        loading = false;
      });

      Fluttertoast.showToast(
        msg: "An unexpected error occurred: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LastboardingScreen()),
          );
          return false; // Prevents default back button behavior
        },
        child: Scaffold(
          body: Stack(
            children: [
              // Background image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background.png'),
                    // Ensure this image is added to your assets
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                // Make the entire content scrollable
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 100),
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 32,
                            color: Color(0xFFffd735),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController,
                                decoration: InputDecoration(
                                  hintText: 'E-mail',
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Color(0xFF9d8236),
                                  ),
                                  prefixIcon: const Icon(Icons.email,
                                      color: Color(0xFFfbd034)),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: const BorderSide(
                                      color: Color(0xFF9d8236),
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: const BorderSide(
                                      color: Color(0xFF9d8236),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter email';
                                  }
                                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                      .hasMatch(value)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                keyboardType: TextInputType.name,
                                controller: nameController,
                                decoration: InputDecoration(
                                  hintText: 'Enter Name',
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Color(0xFF9d8236),
                                  ),
                                  prefixIcon: const Icon(Icons.person, color: Color(0xFFfbd034)),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: const BorderSide(color: Color(0xFF9d8236), width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: const BorderSide(color: Color(0xFF9d8236), width: 2.0),
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter username';
                                  }
                                  if (!RegExp(r'^[a-zA-Z0-9_]{3,16}$').hasMatch(value)) {
                                    return 'Username must be 3-16 characters and can only contain letters, numbers, and underscores';
                                  }
                                  return null;
                                },
                                onSaved: (value) async {
                                  // Save the username in SharedPreferences
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('name', value ?? 'Unknown');
                                  print('Username saved: $value');
                                },
                              ),

                              const SizedBox(height: 10),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Color(0xFF9d8236),
                                  ),
                                  prefixIcon: const Icon(Icons.lock,
                                      color: Color(0xFFfbd034)),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: const BorderSide(
                                      color: Color(0xFFfbd034),
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: const BorderSide(
                                      color: Color(0xFF9d8236),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter Password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password is too short';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                controller: confirmPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Re-Enter Password',
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Color(0xFF9d8236),
                                  ),
                                  prefixIcon: const Icon(Icons.lock,
                                      color: Color(0xFFfbd034)),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: const BorderSide(
                                      color: Color(0xFFfbd034),
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: const BorderSide(
                                      color: Color(0xFF9d8236),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Re-enter Password';
                                  }
                                  if (value != passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              signup(emailController.text.trim(),
                                  passwordController.text.trim());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 140,
                                vertical: 15), // Reduced horizontal padding
                            backgroundColor: const Color(0xFFFFD700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: Size(
                                200, 50), // Set a minimum size for the button
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF010670),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                );
                              },
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Color(0xFFffd735),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        GestureDetector(
                          child: GoogleLoginButton(
                              onPressed: () async {
                                try {
                                  // Initialize GoogleSignIn
                                  final GoogleSignIn googleSignIn = GoogleSignIn();

                                  // Sign out from the current Google session to ensure a fresh login
                                  await googleSignIn.signOut();

                                  // Now attempt to sign in
                                  final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

                                  if (googleUser == null) {
                                    // User canceled the sign-in process
                                    return;
                                  }

                                  // Obtain auth details from request
                                  final GoogleSignInAuthentication googleAuth =
                                  await googleUser.authentication;

                                  // Create a new credential for Firebase
                                  final credential = GoogleAuthProvider.credential(
                                    accessToken: googleAuth.accessToken,
                                    idToken: googleAuth.idToken,
                                  );

                                  // Sign in to Firebase with the Google credential
                                  UserCredential userCredential = await FirebaseAuth.instance
                                      .signInWithCredential(credential);
                                  print('Signed in as: ${userCredential.user?.displayName}');

                                  // Fetch the Firebase ID token (JWT)
                                  String? jwtToken = await userCredential.user?.getIdToken(true);

                                  if (jwtToken != null) {
                                    // Store the JWT token in SharedPreferences
                                    await _storeJwtToken(jwtToken);

                                    // Store user profile data in SharedPreferences
                                    if (userCredential.user != null) {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      await prefs.setString('name', userCredential.user!.displayName ?? "Unknown");
                                      await prefs.setString('email', userCredential.user!.email ?? "No Email");
                                      await prefs.setString('profileImageUrl', userCredential.user!.photoURL ?? "No Image URL");

                                      print('Saved user profile data');
                                    }

                                    // Navigate to the next screen
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => BottomNav()),
                                    );
                                  }
                                } catch (e) {
                                  print('Error during Google sign-in: $e');
                                  // Handle sign-in errors (e.g., show an error message to the user)
                                }
                              }
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
