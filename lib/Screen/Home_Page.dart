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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 16/9,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              viewportFraction: 0.8,
            ),
            items: imgList.map((item) => Center(
              child: Image.network(item, fit: BoxFit.cover, width: 1000),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(8.0), // Padding around the container
            child: Padding(
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
                        MaterialPageRoute(builder: (context) => MyHomePage()), // Replace SeeAllPage with your target page
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
          ),


        ],
      ),


    );
  }
}