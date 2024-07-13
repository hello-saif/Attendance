import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Deawer.dart';


class Attendance_report extends StatefulWidget {
  const Attendance_report({super.key, required String subject});

  @override
  State<Attendance_report> createState() => _Attendance_reportState();
}

class _Attendance_reportState extends State<Attendance_report> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CollectionReference studentsCollection =
  FirebaseFirestore.instance.collection('students');

  DateTime _selectedDate = DateTime.now(); // Initialize with current date

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the scaffoldKey to the Scaffold
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        leading: IconButton(
          icon: const Icon(Icons.format_line_spacing),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Open the drawer
          },
        ),
        title: const Text('Attendance Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      drawer: const UserDrawer(), // Add your custom drawer if needed
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: studentsCollection
              .where('attendance.${_formattedDate(_selectedDate)}.isPresent',
              isEqualTo: true)
              .snapshots(),
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

            // Display the attendance data in a ListView or any appropriate widget
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
                final String name = data['name'] ?? 'Unnamed';

                // Check attendance for the selected date
                final bool isPresent = data['attendance'] != null &&
                    data['attendance'][_formattedDate(_selectedDate)] !=
                        null &&
                    data['attendance'][_formattedDate(_selectedDate)]
                    ['isPresent'] ??false;

                // Only show students who were present
                if (isPresent) {
                  return ListTile(
                    title: Text(name),
                    subtitle: const Text('Present'),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(data['imageUrl'] ?? ''),
                      backgroundColor: Colors.grey,
                    ),
                  );
                } else {
                  // Return an empty container if not present to avoid showing them
                  return Container();
                }
              },
            );
          },
        ),
      ),
    );
  }

  // Helper method to format date as Firestore document key
  String _formattedDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  // Method to show date picker and update selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
}
