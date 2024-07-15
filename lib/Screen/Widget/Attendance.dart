import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Subject List/BanglaAttendanceScreen.dart';
import '../../Subject List/DataAttendanceScreen.dart';
import '../../Subject List/MathAttendanceScreen.dart';
import 'Deawer.dart'; // Import your UserDrawer widget file

class Attendance extends StatefulWidget {
  final String subject;

  const Attendance({Key? key, required this.subject}) : super(key: key);

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CollectionReference studentsCollection = FirebaseFirestore.instance.collection('students');
  final CollectionReference subjectsCollection = FirebaseFirestore.instance.collection('subject');
  late DateTime currentDate = DateTime.now(); // Initialize with current date
  List<String> subjects = [];

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    try {
      QuerySnapshot querySnapshot = await subjectsCollection.get();
      setState(() {
        subjects = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Error fetching subjects: $e');
    }
  }

  Future<void> addSubject(String newSubject) async {
    try {
      await subjectsCollection.add({'name': newSubject});
      setState(() {
        subjects.add(newSubject);
      });
    } catch (e) {
      print('Error adding subject: $e');
    }
  }

  void showAddSubjectDialog() {
    String newSubject = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Subject'),
          content: TextField(
            onChanged: (value) {
              newSubject = value;
            },
            decoration: const InputDecoration(hintText: "Enter subject name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newSubject.isNotEmpty) {
                  addSubject(newSubject);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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
        title: const Text('Class Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list), // Add your custom icon here
            onPressed: () {
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
                              Navigator.pop(context); // Close the dialog
                              navigateToSubjectScreen(subject);
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
          children: subjects.map((String subject) {
            return ListTile(
              title: Text(subject),
              onTap: () => navigateToSubjectScreen(subject),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddSubjectDialog,
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  void navigateToSubjectScreen(String subject) {
    switch (subject) {
      case 'Bangla':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BanglaAttendanceScreen(),
          ),
        );
        break;
      case 'Math':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MathAttendanceScreen(),
          ),
        );
        break;
      case 'Data':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DataAttendanceScreen(),
          ),
        );
        break;
    // Add other cases here for additional subjects
      default:
      // Handle unknown subject
        break;
    }
  }
}
