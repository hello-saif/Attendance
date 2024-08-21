import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For ImagePicker
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../App_Bar/Nav_Bar.dart'; // For Firebase Storage

class ProfileUpdate extends StatefulWidget {
  const ProfileUpdate({Key? key}) : super(key: key);

  @override
  State<ProfileUpdate> createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _imageFile; // To hold the selected image

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final ImagePicker _picker = ImagePicker(); // Create an instance of ImagePicker

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text('Update Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Update Profile',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Update your profile details here.',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : null,
                        child: _imageFile == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    hintText: 'First Name',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    hintText: 'Last Name',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        await _updateProfile();
                      }
                    },
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Update user profile
        if (_firstNameController.text.isNotEmpty || _lastNameController.text.isNotEmpty) {
          final fullName = '${_firstNameController.text} ${_lastNameController.text}';
          await user.updateProfile(displayName: fullName);
        }

        // Upload image to Firebase Storage and update user profile photo URL
        if (_imageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}.jpg');

          final uploadTask = storageRef.putFile(_imageFile!);

          // Wait for the upload to complete
          await uploadTask;

          final photoURL = await storageRef.getDownloadURL();
          await user.updatePhotoURL(photoURL);
        }

        await user.reload();
        user = FirebaseAuth.instance.currentUser;

        // Navigate back to the drawer screen and refresh it
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const NavBar()), (route) => false);
        // Use the appropriate route name for your drawer screen

      }
    } catch (e) {
      // Handle errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
