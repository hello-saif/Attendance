import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'Widget/Video_Player.dart';

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  final List<String> imgList = [
    'https://thumbs.dreamstime.com/b/school-building-vector-illustration-83905184.jpg',
    'https://thumbs.dreamstime.com/b/school-building-vector-illustration-83905184.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4hmaR24UgKLCzSc48TPZD2lsQzzvDAI7R1w&s',
    'https://images.ctfassets.net/hrltx12pl8hq/28ECAQiPJZ78hxatLTa7Ts/2f695d869736ae3b0de3e56ceaca3958/free-nature-images.jpg?fit=fill&w=1200&h=630',
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<Teacher>> _teachersFuture;

  @override
  void initState() {
    super.initState();
    _teachersFuture = _fetchTeachers();
  }

  Future<List<Teacher>> _fetchTeachers() async {
    final snapshot = await _firestore.collection('teachers').get();
    return snapshot.docs.map((doc) {
      return Teacher(
        imageUrl: doc['imageUrl'],
        name: doc['name'],
        description: doc['description'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.8,
              ),
              items: imgList
                  .map((item) => Center(
                child: Image.network(item, fit: BoxFit.cover, width: 1000),
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8.0), // Padding around the container
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding for the Row
                    child: Row(
                      children: [
                        const Text(
                          'Learn Video',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            // Handle the tap event
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MyHomePage()), // Replace MyHomePage with your target page
                            );
                          },
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), // Space between title and content
                  // Add class information below
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClassInfo(
                          title: 'Introduction to Video Editing',
                          description: 'Learn the basics of video editing with Adobe Premiere Pro.',
                          instructor: 'John Doe',
                        ),
                        SizedBox(height: 10), // Space between items
                        ClassInfo(
                          title: 'Advanced Video Production',
                          description: 'Master advanced techniques in video production and post-production.',
                          instructor: 'Jane Smith',
                        ),
                        SizedBox(height: 10), // Space between items
                        ClassInfo(
                          title: 'Cinematography Essentials',
                          description: 'Understand the principles of cinematography and how to apply them.',
                          instructor: 'Alex Johnson',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), // Space between title and content
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding for the Row
                    child: Row(
                      children: [
                        Text(
                          'Teacher Name',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), // Space between title and content
                  FutureBuilder<List<Teacher>>(
                    future: _teachersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No teachers found.'));
                      } else {
                        final teachers = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: teachers
                                .map((teacher) => Column(
                              children: [
                                TeacherInfo(
                                  imageUrl: teacher.imageUrl,
                                  name: teacher.name,
                                  description: teacher.description,
                                ),
                                const SizedBox(height: 10), // Space between items
                              ],
                            ))
                                .toList(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

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

class Teacher {
  final String imageUrl;
  final String name;
  final String description;

  Teacher({
    required this.imageUrl,
    required this.name,
    required this.description,
  });
}
