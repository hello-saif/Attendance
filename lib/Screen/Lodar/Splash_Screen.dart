import 'package:flutter/material.dart';

import '../Sign In&Out/Sign_In_Screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _moveToNextScreen();
  }

  Future<void> _moveToNextScreen() async {
    await Future.delayed(const Duration(seconds: 5));
    // Get.off(() => const Messenger());
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const Sign_In_Screen(title: 'Demo',)), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            //SvgPicture.asset('images/facebook-messenger (1).png', width: 100),
            Center(
              child: Image.network(
                'https://t3.ftcdn.net/jpg/01/25/05/50/360_F_125055050_loLfRxF2fJi5Ge0t49jmaIMBUhlmchwE.jpg',
                width: 300,
                // You can also specify height, fit, etc. according to your requirements
              ),
            ),
            const Spacer(),
            const CircularProgressIndicator(),
            const Spacer(),
            const SizedBox(height: 16),
            const Text('Version 1.0.0'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}