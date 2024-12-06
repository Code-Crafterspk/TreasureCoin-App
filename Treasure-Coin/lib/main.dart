import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import the ScreenUtil package
import 'package:mining/SplashScreen/SplashScreen.dart';
import 'package:mining/authentication/login.dart';
import 'package:provider/provider.dart';
import 'miningApp/mainScreen/miningDataProvider.dart';
import 'miningApp/mining/miningDataProvider.dart';
import 'miningApp/wallet/walletDataProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (context) => MiningDataProvider()),
        ChangeNotifierProvider(create: (context) => WalletProvider()),
      ],
      child: ScreenUtilInit(
        designSize: Size(375, 812), // The design size, e.g., iPhone X resolution
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Mining App',
            theme: ThemeData(
              primarySwatch: Colors.yellow,
            ),
            home: child, // Passing child to ensure ScreenUtil works properly
          );
        },
        child: SplashScreenWrapper(), // Set the SplashScreenWrapper as the child
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthCheckScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}

class AuthCheckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return SplashScreen();
          } else {
            return LoginScreen();
          }
        }
        return CircularProgressIndicator();
      },
    );
  }
}
