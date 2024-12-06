import 'package:flutter/material.dart';
import 'package:mining/miningApp/utils/constants.dart';
import 'package:mining/miningApp/mainScreen/mainScreen.dart';
import 'package:mining/miningApp/settingScreen/settingScreen.dart';
import 'package:mining/miningApp/wallet/walletScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mining/authentication/login.dart';
import '../mining/miningScreen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      mainScreen(controller: _controller),
      Miningscreen(controller: _controller),
      Walletscreen(controller: _controller),
      SettingsScreen(controller: _controller),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home, color: AppColors.primaryColor),
        title: "Home",
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.work_outline, color: AppColors.primaryColor),
        title: "Mining",
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.wallet, color: AppColors.primaryColor),
        title: "Wallet",
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings, color: AppColors.primaryColor),
        title: "Settings",
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: Colors.white,
      ),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarItems(),
      backgroundColor: Color(0xFF07096d),
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(20),
        colorBehindNavBar: Color(0xFF07096d),
      ),
      navBarStyle: NavBarStyle.style13,
      onItemSelected: (index) {
        setState(() {});
      },
    );
  }
}