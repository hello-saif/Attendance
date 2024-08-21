import 'package:attendance/Screen/Home_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'Sign In&Out/Sign_In_Screen.dart';
import 'Widget/Deawer.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the scaffoldKey to the Scaffold
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        leading: IconButton(
          icon: const Icon(Icons.format_line_spacing),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Use the scaffoldKey to open the drawer
          },
        ),
        title: const Text('High School Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.login_outlined),
            onPressed: () {
              _signOut(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const UserDrawer(),
      body: const Home_Page(
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const Sign_In_Screen(title: '',)), (route) => false);// Replace '/Sign_In_Screen' with your login screen route
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      // Show error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to sign out. Please try again.'),
        ),
      );
    }
  }
}
