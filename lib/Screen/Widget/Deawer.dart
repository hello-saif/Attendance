import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../App_Bar/Nav_Bar.dart';
import 'Attendance.dart';
import 'Attendance_report.dart';
import '../Chat/Chat.dart';
import 'Profile_Update.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({super.key});

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final darkModeNotifier = Provider.of<DarkModeNotifier>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          FutureBuilder<User?>(
            future: _getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue, // Set background color
                  ),
                  accountName: Text('Loading...'),
                  accountEmail: Text('Loading...'),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue, // Set background color
                  ),
                  accountName: Text('Guest'),
                  accountEmail: Text('Not logged in'),
                  currentAccountPicture: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                );
              }
              User user = snapshot.data!;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileUpdate(),
                    ),
                  );
                },
                child: UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple, // Set background color
                  ),
                  accountName: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        radius: 30, // Set the radius size here
                        child: user.photoURL == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(
                          width: 5), // Add space between avatar and text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName ?? 'No name',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Text color
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              user.email ?? 'No email',
                              style: TextStyle(
                                color: Colors.grey[300], // Text color
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                          height: 46), // Add space between avatar and text
                    ],
                  ),
                  currentAccountPicture: null,
                  accountEmail: null,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const NavBar()),
                  (route) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Attendance'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Attendance(
                            subject: '',
                          )),
                  (route) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem_outlined),
            title: const Text('Attendance Report'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AttendanceReport(
                            subject: '',
                          )),
                  (route) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_outlined),
            title: const Text('Chat'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Chat()),
                  (route) => false);
            },
          ),
          ListTile(
            leading: Icon(
              darkModeNotifier.isDarkMode ? Icons.toggle_on : Icons.toggle_off,
              color: darkModeNotifier.isDarkMode ? Colors.green : Colors.grey,
            ),
            title: const Text('Mode'),
            onTap: () {
              darkModeNotifier.toggleDarkMode();
            },
          ),
        ],
      ),
    );
  }
}
