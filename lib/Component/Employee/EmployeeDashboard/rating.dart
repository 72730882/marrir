import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  // Store ratings for each question
  final Map<int, int> _ratings = {};

  // Questions list
  final List<String> _questions = [
    "Rate your ability to work under pressure",
    "Rate your time management skills",
    "Rate your communication skills",
    "Rate your teamwork and collaboration ability",
    "Rate your flexibility and adaptability to change",
    "Rate your problem-solving skills",
    "Rate your willingness to learn new skills and technologies",
    "Rate your attention to detail",
    "Rate your ability to follow instructions",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EmployeePage()),
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          "Rating",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Please answer the questions asked below to get your rating",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),

                  // Render each question with stars
                  ...List.generate(
                    _questions.length,
                    (index) => _buildRatingQuestion(index, _questions[index]),
                  ),
                ],
              ),
            ),
          ),

          // Submit Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // Example: print collected ratings
                debugPrint("Ratings: $_ratings");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Ratings submitted successfully!"),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget for a single rating question
  Widget _buildRatingQuestion(int index, String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (starIndex) {
              final rating = _ratings[index] ?? 0;
              return IconButton(
                onPressed: () {
                  setState(() {
                    _ratings[index] = starIndex + 1;
                  });
                },
                icon: Icon(
                  Icons.star,
                  color: starIndex < rating ? Colors.red : Colors.grey,
                  size: 28,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
