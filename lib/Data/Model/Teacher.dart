import 'package:flutter/cupertino.dart';

class TeacherInfo extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;

  const TeacherInfo({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80, // Set the width of the image container
          height: 80, // Set the height of the image container
          decoration: BoxDecoration(
            shape: BoxShape.rectangle, // Make it square
            borderRadius: BorderRadius.circular(10), // Optional: rounded corners
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10), // Space between image and text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4), // Space between name and description
              Text(
                description,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
