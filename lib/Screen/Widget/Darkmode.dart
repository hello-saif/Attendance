import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Deawer.dart'; // Ensure this is the correct path

class DarkModeApp extends StatefulWidget {
  @override
  _DarkModeAppState createState() => _DarkModeAppState();
}

class _DarkModeAppState extends State<DarkModeApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _toggleTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = isDarkMode;
    });
    prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.format_line_spacing),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        drawer: const UserDrawer(), // Ensure UserDrawer is properly defined

        body: Center(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0), // Adjust padding if needed
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isDarkMode ? Icons.toggle_on : Icons.toggle_off,
                      color: _isDarkMode ? Colors.green : Colors.grey, size: 90),
                  onPressed: () {
                    _toggleTheme(!_isDarkMode);
                    // Reload the DarkModeApp with the updated theme
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => DarkModeApp()),
                          (route) => false,
                    );
                  },
                ),
                // const SizedBox(width: 10), // Optional spacing
                // const Text('Mode'), // Adjust text if needed
              ],
            ),
            onTap: () {
              // Also toggles theme on tap
              _toggleTheme(!_isDarkMode);
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => DarkModeApp()),
                    (route) => false,
              );
            },
          ),
        ),
      ),
    );
  }
}
