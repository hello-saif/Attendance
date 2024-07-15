import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  final GoogleSignIn googleSignIn = GoogleSignIn();

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
                const SizedBox(height: 80),

                ClipOval(
                  child: Image.network(
                    'https://static.vecteezy.com/system/resources/previews/004/903/201/original/cartoon-illustration-of-thai-female-teacher-holding-a-stick-in-front-of-blackboard-vector.jpg', // Replace with your image URL
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
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
                      child: const Text('Log In'),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 96,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Visibility(
                        replacement: const Center(
                          child: CircularProgressIndicator(),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            _signInWithGoogle(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                          ),
                          child: const Icon(
                            Icons.g_mobiledata_sharp,
                            color: Colors.amber, // Icon color
                            size: 50.0, // Icon size
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      child: Visibility(
                        replacement: const Center(
                          child: CircularProgressIndicator(),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            //_signInWithGoogle(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                          ),
                          child: const Icon(
                            Icons.facebook,
                            color: Colors.amber, // Icon color
                            size: 50.0, // Icon size
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      child: Visibility(
                        replacement: const Center(
                          child: CircularProgressIndicator(),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            //_signInWithGoogle(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: Colors.amber, // Icon color
                            size: 50.0, // Icon size
                          ),
                        ),
                      ),
                    ),


                  ],
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
                              builder: (context) =>
                                  const EmailVerificationScreen()));
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

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount == null) {
        // User canceled the Google Sign-In flow
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        if (kDebugMode) {
          if (kDebugMode) {
            print('User ID: ${user.uid}');
          }
        }
        if (kDebugMode) {
          print('User Email: ${user.email}');
        }

        // Navigate to NavBar screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NavBar()),
          (route) => false,
        );
      } else {
        if (kDebugMode) {
          print('Sign in failed: User is null');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
      // Handle specific types of exceptions if needed
      if (e is PlatformException) {
        if (kDebugMode) {
          print('PlatformException details: ${e.details}');
        }
        if (kDebugMode) {
          print('PlatformException code: ${e.code}');
        }
        // Handle specific error codes if necessary
        if (e.code == '10') {
          // Handle ApiException: 10 here
          if (kDebugMode) {
            print('Google Sign-In API Error: ApiException 10');
          }
        }
      }
    }
  }
}
