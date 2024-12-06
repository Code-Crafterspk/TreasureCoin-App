import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mining/authentication/forgotPassword.dart';
import 'package:mining/authentication/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../boardingScreen/lastboardingScreen.dart'; // Replace with your desired screen
import '../miningApp/utils/bottomNavigationBar.dart';
import 'googleButton.dart';
import 'utils.dart'; // Assuming this is a utility class for displaying toast messages
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  // Firebase Authentication instance
  FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref(); // Realtime Database reference
  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }


  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString('email') ?? '';
    passwordController.text = prefs.getString('password') ?? '';
  }

// Function to store email and password
  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email); // Save email
    await prefs.setString('password', password); // Save password
  }

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

  // Function to handle login
  Future<void> login(String email, String password) async {
    setState(() {
      loading = true;
    });

    try {
      // Sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await saveCredentials(email, password);

      // Fetch a fresh Firebase ID token (JWT)
      String? jwtToken =
          await userCredential.user?.getIdToken(true); // Force refresh

      if (jwtToken != null) {
        // Store the token in SharedPreferences
        await _storeJwtToken(jwtToken);

        // Navigate to the next screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BottomNav()), // Your desired screen
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      // Error handling
      if (e.code == 'user-not-found') {
        utils().toastMessage('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        utils().toastMessage('Wrong password provided.');
      } else {
        utils().toastMessage(e.message ?? 'An error occurred');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      utils().toastMessage('An error occurred: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // Function to handle logout
  Future<void> logout() async {
    await _auth.signOut(); // Sign out the user
    await _clearStoredToken(); // Clear the stored JWT token
    // Optionally navigate to the login screen or show a confirmation message
  }

  // Example function to fetch data using the JWT token
  Future<void> fetchData() async {
    String? token = await getStoredJwtToken();

    // Handle the response...
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to LastBoardingScreen when back button is pressed
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
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 100),
                      const Text(
                        'Login',
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Forgotpassword()));
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            login(emailController.text.trim(),
                                passwordController.text.trim());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 150, vertical: 15),
                          backgroundColor: const Color(0xFFFFD700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF010670),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                              ),
                              children: [
                                TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: 'Sign up',
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SignupScreen()),
                                      );
                                    },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 25),
                      // Add your Google login button if needed

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
      ),
    );
  }
}
