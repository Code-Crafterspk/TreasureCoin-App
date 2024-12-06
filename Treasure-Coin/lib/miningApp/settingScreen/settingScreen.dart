import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mining/authentication/login.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import '../utils/image_picker.dart';

class SettingsScreen extends StatefulWidget {
  final PersistentTabController controller; // Add the controller property

  const SettingsScreen({Key? key, required this.controller}) : super(key: key); // Add controller to constructor

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _name = "Your Name";
  String? _email = "Your Email";
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? "Your Name";
      _email = prefs.getString('email') ?? "Your Email";
      _profileImageUrl = prefs.getString('profileImageUrl');
    });
  }

  void _updateProfileImage(String imageUrl) async {
    setState(() {
      _profileImageUrl = imageUrl;
    });

    // Save the imageUrl to shared preferences or database here
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profileImageUrl', imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textColor,
      appBar: AppBar(
        backgroundColor: Color(0xFFffd735),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: ImageIcon(
              AssetImage("assets/img_13.png"),
              size: 30,
              color: Colors.black,
            ),
            onPressed: (){
              widget.controller.jumpToTab(0);

            }
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ImagePickerWidget(onImageUpload: _updateProfileImage),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 23),
              child: Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  height: 3,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name:  $_name',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          color: AppColors.primaryColor)),
                  Text('E-mail:  $_email',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          color: AppColors.primaryColor,
                          height: 3)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 23),
              child: Text(
                'About',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text('Terms & Conditions',
                  style: TextStyle(
                      fontFamily: 'Montserrat', color: AppColors.primaryColor)),
              onTap: () {
                // Handle Terms & Conditions tap
              },
            ),
            ListTile(
              title: Text('Privacy Policy',
                  style: TextStyle(
                      fontFamily: 'Montserrat', color: AppColors.primaryColor)),
              onTap: () {
                // Handle Privacy Policy tap
              },
            ),
            SizedBox(height: 20),
            _buildMenuItem(

                Icons.notifications, '     Notification', () {
              print('Notification tapped');
            }),
            _buildMenuItem(Icons.help, '     Support', () {
              print('Support tapped');
            }),
            _buildMenuItem(Icons.contact_mail, '     Contact us', () {
              print('Contact us tapped');
            }),
            _buildMenuItem(Icons.logout, '     Log out', () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Log out?'),
                  content: Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async{
                        await FirebaseAuth.instance.signOut();
                        // SharedPreferences prefs = await SharedPreferences.getInstance();
                        // // await prefs.remove('name');
                        // // await prefs.remove('email');
                        // await prefs.remove('profileImageUrl');
                        // await prefs.remove('jwtToken'); // Assuming you stored the JWT token with this key
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                              (route) => false, // This removes all previous routes
                        );
                      },
                      child: Text('Log out'),
                    ),
                  ],
                ),
              );



            }),
          ],
        ),
      ),
    );
  }

  ListTile _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: AppColors.primaryColor,
          )),
      onTap: onTap,
    );
  }
}
