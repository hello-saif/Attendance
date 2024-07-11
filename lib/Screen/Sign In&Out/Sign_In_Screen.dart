import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Nav_Bar.dart';
import 'Email_Verify.dart';
import 'Sign_Up_Screen.dart';

class Sign_In_Screen extends StatefulWidget {
  const Sign_In_Screen({super.key, required this.title});
  final String title;

  @override
  State<Sign_In_Screen> createState() => _Sign_In_ScreenState();
}

class _Sign_In_ScreenState extends State<Sign_In_Screen> {
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoginInProgress = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Text(
                  'Get Started With',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _emailTEController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                  ),
                  validator: (String? value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _passwordTEController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                  validator: (String? value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Visibility(
                    visible: _isLoginInProgress == false,
                    replacement: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    child: ElevatedButton(
                      onPressed: _signInWithEmailAndPassword,
                      child: const Icon(Icons.g_mobiledata),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EmailVerificationScreen()));
                    },
                    child: const Text(
                      'Forgot Password?',
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Sign_Up_Screen()));
                      },
                      child: const Text(
                        'Sign up',
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoginInProgress = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailTEController.text.trim(),
        password: _passwordTEController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        print('User ID: ${user.uid}');
        print('User Email: ${user.email}');
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NavBar()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
    } finally {
      setState(() {
        _isLoginInProgress = false;
      });
    }
  }
}
