import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart' show CarouselSlider, CarouselOptions;
import 'package:carousel_slider/carousel_controller.dart' as carousel;
import '../screens/training_detail_screen.dart';

class TrainingCarousel extends StatefulWidget {
  const TrainingCarousel({super.key});

  @override
  State<TrainingCarousel> createState() => _TrainingCarouselState();
}

class _TrainingCarouselState extends State<TrainingCarousel> {
  final carousel.CarouselController _controller = carousel.CarouselController();
  List<dynamic> trainingItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrainingData();
  }

  Future<void> fetchTrainingData() async {
    final response = await http.get(Uri.parse('https://mocki.io/v1/15ae7ae2-e454-423c-a738-16209cfdddb8'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        trainingItems = data['trending'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🔥 Popular Drills",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 12),
        CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
          ),
          items: trainingItems.map((item) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrainingDetailScreen(item: item),
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      item['image'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      child: Text(
                        item['title'],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
