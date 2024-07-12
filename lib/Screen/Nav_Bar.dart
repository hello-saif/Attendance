import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
        title: const Text('Person'),
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
      body: const Center(
        child: Text('Content of your screen goes here'),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login screen or any other screen after logout
      Navigator.pushReplacementNamed(context, '/Sign_In_Screen'); // Replace '/Sign_In_Screen' with your login screen route
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

class UserDrawer extends StatelessWidget {
  const UserDrawer({Key? key}) : super(key: key);

  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          FutureBuilder<User?>(
            future: _getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const UserAccountsDrawerHeader(
                  accountName: Text('Loading...'),
                  accountEmail: Text('Loading...'),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const UserAccountsDrawerHeader(
                  accountName: Text('Guest'),
                  accountEmail: Text('Not logged in'),
                );
              }
              User user = snapshot.data!;
              return UserAccountsDrawerHeader(
                accountName: Text(user.displayName ?? 'No name'),
                accountEmail: Text(user.email ?? 'No email'),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}
