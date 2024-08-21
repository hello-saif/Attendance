import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ClassInfo extends StatelessWidget {
  final String title;
  final String description;
  final String instructor;

  const ClassInfo({
    super.key,
    required this.title,
    required this.description,
    required this.instructor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4), // Space between title and description
        Text(
          description,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4), // Space between description and instructor
        Text(
          'Instructor: $instructor',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
