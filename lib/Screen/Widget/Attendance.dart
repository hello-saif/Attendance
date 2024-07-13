import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Deawer.dart'; // Import your Attendance_report widget file

class Attendance extends StatefulWidget {
  const Attendance({Key? key}) : super(key: key);

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CollectionReference studentsCollection =
  FirebaseFirestore.instance.collection('students');
  late DateTime currentDate = DateTime.now(); // Initialize with current date

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
        title: const Text('Class Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.view_list), // Add your custom icon here
            onPressed: () {
              // Define your list of subjects (replace with your actual subject names)
              List<String> subjects = [
                'Bangla',
                'Math',
                'Data',
              ];

              // Show a dialog with a list of subjects
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Select a Subject'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: subjects.map((String subject) {
                          return ListTile(
                            title: Text(subject),
                            onTap: () {
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            },
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 50),
                Text(
                  'NAME',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(width: 50),
                Text(
                  'Present/Absent',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(width: 15),
                Text(
                  'IMAGE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(), // Divider to separate header from the list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: studentsCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

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

                    return Student(
                      id: doc.id,
                      name: name,
                      isPresent: data['attendance'] != null &&
                          data['attendance'][_formattedDate(currentDate)] !=
                              null &&
                          data['attendance'][_formattedDate(currentDate)]
                          ['isPresent'] ??
                          false,
                      imageUrl: imageUrl,
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Text(
                            '${index + 1}.',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: ListTile(
                              title: Text(students[index].name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: students[index].isPresent,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        students[index].isPresent = value!;
                                      });

                                      // Update Firestore
                                      studentsCollection
                                          .doc(students[index].id)
                                          .update({
                                        'attendance.${_formattedDate(currentDate)}.isPresent': value,
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      studentsCollection
                                          .doc(students[index].id)
                                          .delete();
                                    },
                                  ),
                                  CircleAvatar(
                                    backgroundImage:
                                    NetworkImage(students[index].imageUrl),
                                    backgroundColor:
                                    Colors.grey, // Optional: Background color for the avatar
                                    radius:
                                    20, // Adjust the size of the avatar as needed
                                  ),
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
                  decoration:
                  const InputDecoration(hintText: 'Enter student name'),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration:
                  const InputDecoration(hintText: 'Enter image URL'),
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
                  await studentsCollection.add({
                    'name': name,
                    'imageUrl': imageUrl,
                    'attendance': {
                      _formattedDate(currentDate): {'isPresent': false},
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
    studentsCollection.get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        print('${doc['name']} is ${doc['attendance'] != null && doc['attendance'][_formattedDate(currentDate)] != null && doc['attendance'][_formattedDate(currentDate)]['isPresent'] ? 'Present' : 'Absent'}');
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
    return '${date.year}-${date.month}-${date.day}';
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
