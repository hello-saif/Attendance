import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'Deawer.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final CollectionReference _chatCollection = FirebaseFirestore.instance.collection('chats');

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    setState(() {});
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      try {
        // Upload the image to Firebase Storage
        final UploadTask uploadTask = _storage.ref('chat_images/$fileName').putFile(imageFile);
        final TaskSnapshot taskSnapshot = await uploadTask;

        // Get the download URL of the uploaded image
        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Send the image URL as a message
        if (_currentUser != null) {
          String userName = _currentUser!.displayName ?? _currentUser!.uid;

          _chatCollection.add({
            'userId': userName,
            'message': '',
            'imageUrl': downloadUrl,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        // Handle errors
        print('Error uploading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        leading: IconButton(
          icon: const Icon(Icons.format_line_spacing),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_camera_back_outlined),
            onPressed: () {  },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {  },
          ),
        ],
      ),
      drawer: const UserDrawer(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatCollection
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final data = message.data() as Map<String, dynamic>;
                    final String userId = data['userId'];
                    final String text = data['message'];
                    final String? imageUrl = data.containsKey('imageUrl') ? data['imageUrl'] : null;

                    final bool isCurrentUser = userId == (_currentUser?.displayName ?? _currentUser?.uid);

                    return Column(
                      crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        // Display the name above the message box
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                          child: Text(
                            userId,
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ),
                        Align(
                          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Colors.blue.withOpacity(0.7)
                                  : Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imageUrl != null) Image.network(imageUrl),
                                if (text.isNotEmpty) Text(text),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickAndSendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final String message = _messageController.text.trim();

    if (message.isNotEmpty && _currentUser != null) {
      String userName = _currentUser!.displayName ?? _currentUser!.uid;

      _chatCollection.add({
        'userId': userName,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }
  }
}

