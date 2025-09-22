import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/Employee/dashboard_service.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  // Store ratings for each question
  final Map<int, int> _ratings = {};
  bool _isSubmitting = false;
  bool _isSubmitted = false; // Add this flag to track submission state

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

  Future<void> _submitRatings() async {
    // Check if all questions are answered
    if (_ratings.length != _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer all questions")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Calculate average rating from all questions
      final totalRating = _ratings.values.reduce((a, b) => a + b);
      final averageRating = totalRating / _ratings.length;

      // Prepare rating data with SHORTENED description
      final ratingData = {
        "value": averageRating,
        "description":
            "Self-rating: ${averageRating.toStringAsFixed(1)}/5 average", // Short description
      };

      final response = await EmployeeDashboardService.submitRatings(ratingData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(response['message'] ?? "Ratings submitted successfully!")),
      );

      // REMOVED Navigator.pop(context) - Stay on this screen
      setState(() {
        _isSubmitted = true; // Mark as submitted
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit ratings: $e")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _resetRatings() {
    setState(() {
      _ratings.clear();
      _isSubmitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? token = prefs.getString("access_token");

            if (token != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeePage(token: token),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Token not found, please login again.")),
              );
            }
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
                  // Show success message if submitted
                  if (_isSubmitted)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            "Rating submitted successfully!",
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),

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

          // Submit Button or Reset Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: _isSubmitted
                ? ElevatedButton(
                    onPressed: _resetRatings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Submit New Rating",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRatings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Submit",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
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
                onPressed: _isSubmitted
                    ? null // Disable stars after submission
                    : () {
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
          if (_ratings[index] != null)
            Text(
              "Selected: ${_ratings[index]} stars",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
