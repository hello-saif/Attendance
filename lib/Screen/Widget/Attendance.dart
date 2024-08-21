import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendance/Subject%20List/BanglaAttendanceScreen.dart';
import 'package:attendance/Subject%20List/DataAttendanceScreen.dart';
import 'package:attendance/Subject%20List/MathAttendanceScreen.dart';
import 'package:attendance/Subject%20List/ICTAttendanceScreen.dart';
import '../../Subject List/C+AttendanceScreen.dart';
import 'Deawer.dart';

class Attendance extends StatefulWidget {
  final String subject;

  const Attendance({super.key, required this.subject});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CollectionReference subjectsCollection =
  FirebaseFirestore.instance.collection('subject');
  late DateTime currentDate = DateTime.now();
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
        subjects =
            querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching subjects: $e');
      }
    }
  }

  Future<void> addSubject(String newSubject) async {
    try {
      await subjectsCollection.add({'name': newSubject});
      setState(() {
        subjects.add(newSubject);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding subject: $e');
      }
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
            icon: const Icon(Icons.view_list),
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
                              Navigator.pop(context);
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
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
                onTap: () => navigateToSubjectScreen(subject),
              ),
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
    Widget subjectScreen;

    switch (subject) {
      case 'Bangla':
        subjectScreen = const BanglaAttendanceScreen();
        break;
      case 'C+':
        subjectScreen = const CAttendanceScreen();
        break;
      case 'Math':
        subjectScreen = const MathAttendanceScreen();
        break;
      case 'Data':
        subjectScreen = const DataAttendanceScreen();
        break;
      case 'ICT':
        subjectScreen = const ICTAttendanceScreen();
        break;
      default:
        subjectScreen = const BanglaAttendanceScreen(); // Default screen if subject not found
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => subjectScreen,
      ),
    );
  }
}
