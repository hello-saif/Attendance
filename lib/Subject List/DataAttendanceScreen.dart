import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../Screen/Widget/Deawer.dart';

class DataAttendanceScreen extends StatefulWidget {
  const DataAttendanceScreen({super.key});

  @override
  State<DataAttendanceScreen> createState() => _DataAttendanceScreenState();
}

class _DataAttendanceScreenState extends State<DataAttendanceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CollectionReference studentsDataCollection = FirebaseFirestore.instance.collection('studentsData');
  DateTime currentDate = DateTime.now(); // Initialize with current date

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
        title: const Text('Data Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      drawer: const UserDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row as a Column
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'No',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: Text(
                    'NAME',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Present/Absent',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

              ],
            ),
            const Divider(), // Divider to separate header from the list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: studentsDataCollection.snapshots(),
                builder: (context, snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return const Center(child: CircularProgressIndicator());
                  // }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No students found'));
                  }

                  final List<Student> students = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final imageUrl = data['imageUrl'] ?? '';
                    final name = data['name'] ?? 'Unnamed';
                    final attendance = data['attendance'] ?? {};
                    final isPresent = attendance[_formattedDate(currentDate)]?['Data']?['isPresent'] ?? false;

                    return Student(
                      id: doc.id,
                      name: name,
                      isPresent: isPresent,
                      imageUrl: imageUrl,
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Index number
                            Text(
                              '${index + 1}.',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8), // Add some spacing between number and image
                            // Student image
                            CircleAvatar(
                              backgroundImage: NetworkImage(students[index].imageUrl),
                              backgroundColor: Colors.grey, // Optional: Background color for the avatar
                              radius: 20, // Adjust the size of the avatar as needed
                            ),
                          ],
                        ),
                        title: Text('${students[index].name}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: students[index].isPresent,
                              onChanged: (bool? value) {
                                setState(() {
                                  students[index].isPresent = value ?? false;
                                });

                                // Update Firestore
                                studentsDataCollection.doc(students[index].id).update({
                                  'attendance.${_formattedDate(currentDate)}.Data.isPresent': students[index].isPresent,
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                studentsDataCollection.doc(students[index].id).delete();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitAttendance,
              child: const Text('Submit Attendance'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddStudentDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Student'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Enter student name'),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(hintText: 'Enter image URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                final String name = nameController.text;
                final String imageUrl = imageUrlController.text;

                if (name.isNotEmpty && imageUrl.isNotEmpty) {
                  // Add student to Firestore
                  await studentsDataCollection.add({
                    'name': name,
                    'imageUrl': imageUrl,
                    'attendance': {
                      _formattedDate(currentDate): {'Data': {'isPresent': false}},
                    },
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _submitAttendance() {
    // Process the attendance data
    studentsDataCollection.get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Unnamed';
        final attendance = data['attendance'] ?? {};
        final isPresent = attendance[_formattedDate(currentDate)]?['Data']?['isPresent'] ?? false;

        if (kDebugMode) {
          print('$name is ${isPresent ? 'Present' : 'Absent'} on ${_formattedDate(currentDate)}');
        }
      }

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance submitted successfully')),
      );
    });
  }

  // Method to show date picker and update selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        currentDate = pickedDate;
      });
    }
  }

  // Helper method to format date as Firestore document key
  String _formattedDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class Student {
  String id;
  String name;
  bool isPresent;
  String imageUrl;

  Student({
    required this.id,
    required this.name,
    required this.isPresent,
    required this.imageUrl,
  });
}