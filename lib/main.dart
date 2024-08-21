import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Screen/Lodar/Splash_Screen.dart';
import 'Screen/Sign In&Out/Sign_In_Screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => DarkModeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DarkModeNotifier>(
      builder: (context, darkModeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: darkModeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: const SplashScreen(),
          routes: {
            '/Sign_In_Screen': (context) => const Sign_In_Screen(title: 'Fail'),
            // Add more routes as needed
          },
        );
      },
    );
  }
}

class DarkModeNotifier with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

