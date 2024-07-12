// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
//
// import 'Set_Password.dart';
// import 'Sign_In_Screen.dart';
//
// class PinVerificationScreen extends StatefulWidget {
//   final String email;
//
//   const PinVerificationScreen({Key? key, required this.email}) : super(key: key);
//
//
//   @override
//   State<PinVerificationScreen> createState() => _PinVerificationScreenState();
// }
//
// class _PinVerificationScreenState extends State<PinVerificationScreen> {
//   final TextEditingController _pinTEController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 100),
//                 Text(
//                   'OTP Verification',
//                   style: Theme.of(context).textTheme.headline6,
//                 ),
//                 const SizedBox(
//                   height: 4,
//                 ),
//                 const Text(
//                   'Enter the OTP sent to your email',
//                   style: TextStyle(color: Colors.grey, fontSize: 15),
//                 ),
//                 const SizedBox(
//                   height: 24,
//                 ),
//                 PinCodeTextField(
//                   controller: _pinTEController,
//                   length: 6,
//                   obscureText: false,
//                   animationType: AnimationType.fade,
//                   keyboardType: TextInputType.number,
//                   pinTheme: PinTheme(
//                     shape: PinCodeFieldShape.box,
//                     borderRadius: BorderRadius.circular(5),
//                     fieldHeight: 50,
//                     fieldWidth: 40,
//                     activeFillColor: Colors.white,
//                     inactiveFillColor: Colors.white,
//                     inactiveColor: Colors.cyan,
//                     selectedFillColor: Colors.white,
//                   ),
//                   animationDuration: const Duration(milliseconds: 300),
//                   backgroundColor: Colors.transparent,
//                   enableActiveFill: true,
//                   onCompleted: (v) {
//                   },
//                   onChanged: (value) {},
//                   appContext: context,
//                 ),
//                 const SizedBox(
//                   height: 16,
//                 ),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Verify OTP when the button is pressed
//                     },
//                     child: const Text('Verify'),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 32,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Have an account?',
//                       style: TextStyle(fontSize: 16, color: Colors.black54),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const Sign_In_Screen(title: ''),
//                           ),
//                               (route) => false,
//                         );
//                       },
//                       child: const Text('Sign in'),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   @override
//   void dispose() {
//     _pinTEController.dispose();
//     super.dispose();
//   }
//
//
// }
