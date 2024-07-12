import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Sign_In_Screen.dart';

class SetPasswordScreen extends StatefulWidget {
  final String email; // Add email parameter to get email from previous screen
  final String oobCode; // Add oobCode parameter to get the password reset code

  const SetPasswordScreen({Key? key, required this.email, required this.oobCode}) : super(key: key);

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final TextEditingController _passwordTEController = TextEditingController();
  final TextEditingController _confirmPasswordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Text(
                  'Set Password',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(
                  height: 4,
                ),
                const Text(
                  'Minimum 8 characters with letters and numbers combination',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFormField(
                  controller: _passwordTEController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    if (!containsLettersAndNumbers(value)) {
                      return 'Password must contain both letters and numbers';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _confirmPasswordTEController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Confirm Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordTEController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _resetPassword();
                      }
                    },
                    child: const Text('Confirm'),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Have an account?',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Sign_In_Screen(title: ''),
                          ),
                              (route) => false,
                        );
                      },
                      child: const Text('Sign in'),
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

  bool containsLettersAndNumbers(String value) {
    final RegExp letterRegex = RegExp(r'[a-zA-Z]');
    final RegExp digitRegex = RegExp(r'[0-9]');
    return letterRegex.hasMatch(value) && digitRegex.hasMatch(value);
  }

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.oobCode,
        newPassword: _passwordTEController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password has been reset successfully.'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Sign_In_Screen(title: ''),
        ),
            (route) => false,
      );
    } catch (e) {
      print('Error resetting password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reset password: $e'),
        ),
      );
    }
  }


  @override
  void dispose() {
    _passwordTEController.dispose();
    _confirmPasswordTEController.dispose();
    super.dispose();
  }
}
