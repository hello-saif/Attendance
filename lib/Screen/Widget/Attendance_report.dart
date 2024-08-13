import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Deawer.dart';

class AttendanceReport extends StatefulWidget {
  const AttendanceReport({super.key, required this.subject});
  final String subject;

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CollectionReference subjectsCollection = FirebaseFirestore.instance.collection('subject');

  List<String> subjects = [];
  DateTime selectedDate = DateTime.now();

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
      if (kDebugMode) {
        print('Error fetching subjects: $e');
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
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
        title: const Text('Attendance Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              _selectDate(context);
            },
          ),
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
                        children: subjects.map<Widget>((String subject) {
                          return ListTile(
                            title: Text(subject),
                            onTap: () {
                              Navigator.pop(context, subject);
                              navigateToSubjectReport(subject);
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
                onTap: () => navigateToSubjectReport(subject),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void navigateToSubjectReport(String subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectReportScreen(
          subject: subject,
          selectedDate: selectedDate,
        ),
      ),
    );
  }
}

class SubjectReportScreen extends StatelessWidget {
  final String subject;
  final DateTime selectedDate;

  const SubjectReportScreen({
    super.key,
    required this.subject,
    required this.selectedDate,
  });

  String _formattedDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text('Report for $subject'),
      ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchPresentStudents(subject),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No students found for the selected date.'));
            }

            List<Map<String, dynamic>> presentStudents = snapshot.data!;

            return ListView.builder(
              itemCount: presentStudents.length,
              itemBuilder: (context, index) {
                var student = presentStudents[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(student['imageUrl'] ?? ''),
                    backgroundColor: Colors.grey,
                  ),
                  title: Text('${student['name'] ?? 'Unnamed'}'),
                );
              },
            );
          },
        )
    );
  }

  Future<List<Map<String, dynamic>>> fetchPresentStudents(String subject) async {
    String formattedDate = _formattedDate(selectedDate);

    // Determine the collection to use based on the subject
    CollectionReference studentsCollection;

    if (subject == 'Bangla') {
      studentsCollection = FirebaseFirestore.instance.collection('studentsBangla');
    } else if (subject == 'Math') {
      studentsCollection = FirebaseFirestore.instance.collection('studentsMath');
    } else if (subject == 'C+') {
      studentsCollection = FirebaseFirestore.instance.collection('studentsC');
    }
    else if (subject == 'Data') {
      studentsCollection = FirebaseFirestore.instance.collection('studentsData');
    } else {
      // Default collection if subject does not match any known subjects
      studentsCollection = FirebaseFirestore.instance.collection('studentsICT');
    }

    QuerySnapshot querySnapshot = await studentsCollection.get();
    List<Map<String, dynamic>> presentStudents = [];

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      // Debugging: Print the document ID and the data
      if (kDebugMode) {
        print('Document ID: ${doc.id}');
        print('Student Data: $data');
      }

      // Check for attendance data
      if (data.containsKey('attendance')) {
        Map<String, dynamic> attendance = data['attendance'] as Map<String, dynamic>;

        // Debugging: Print attendance data
        if (kDebugMode) {
          print('Attendance Data: $attendance');
        }

        if (attendance.containsKey(formattedDate)) {
          var subjectAttendance = attendance[formattedDate] as Map<String, dynamic>;

          // Debugging: Print subject-specific attendance data
          if (kDebugMode) {
            print('Subject Attendance: $subjectAttendance');
          }

          if (subjectAttendance.containsKey(subject) && subjectAttendance[subject]['isPresent'] == true) {
            presentStudents.add(data);
            if (kDebugMode) {
              print('Student ${data['name']} is present on $formattedDate for subject $subject.');
            }
          } else {
            if (kDebugMode) {
              print('Student ${data['name']} is not present on $formattedDate for subject $subject.');
            }
          }
        } else {
          if (kDebugMode) {
            print('No attendance record found for ${data['name']} on $formattedDate.');
          }
        }
      } else {
        if (kDebugMode) {
          print('No attendance field found for student: ${data['name']}');
        }
      }
    }

    if (kDebugMode) {
      print('Present Students List for $subject: $presentStudents');
    }

    return presentStudents;
  }
}
