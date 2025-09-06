import 'dart:async';
import 'package:flutter/material.dart';

class Clienttalk extends StatelessWidget {
  const Clienttalk({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> testimonials = [
      {
        "quote":
            '"This platform revolutionized our hiring process. We found exceptional talent in record time!"',
        "name": "John Doe",
        "position": "HR Director",
        "company": "Marir",
      },
      {
        "quote":
            '"Using this service saved us weeks of recruitment time and we hired the best candidates!"',
        "name": "Jane Smith",
        "position": "Talent Manager",
        "company": "TechCorp",
      },
      {
        "quote":
            '"The system is intuitive, efficient, and makes hiring so much easier for our HR team."',
        "name": "Robert Brown",
        "position": "HR Manager",
        "company": "Global Solutions",
      },
    ];

    final PageController pageController = PageController();
    final ValueNotifier<int> activePage = ValueNotifier<int>(0);

    // Auto-slide every 3 seconds
    Timer.periodic(const Duration(seconds: 3), (timer) {
      int nextPage = activePage.value + 1;
      if (nextPage >= testimonials.length) nextPage = 0;
      pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      activePage.value = nextPage;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Blue Info Card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF65b2c9),
                  Color(0xFF88C3D5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(97, 223, 237, 240),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.rocket_launch,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Easily Accessible",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "A Better Workflow",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Discover a seamless digital experience designed to simplify your workflow. Our web app portal offers an intuitive interface, enabling you to access a wide array of features and tools that enhance productivity and connectivity",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF65b2c9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 35,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Learn More",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "What Our Clients Say",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 250,
            child: PageView.builder(
              controller: pageController,
              itemCount: testimonials.length,
              onPageChanged: (index) {
                activePage.value = index;
              },
              itemBuilder: (context, index) {
                final client = testimonials[index];
                return Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(203, 255, 255, 255),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color.fromARGB(255, 239, 249, 239),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0F0F0),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star,
                            size: 16,
                            color: Color(0xFFFFC107),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        client["quote"]!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        client["name"]!,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        client["position"]!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 129, 204, 226),
                        ),
                      ),
                      Text(
                        client["company"]!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 57, 57, 57),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          ValueListenableBuilder<int>(
            valueListenable: activePage,
            builder: (context, value, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: testimonials.asMap().entries.map((entry) {
                  int idx = entry.key;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          value == idx ? const Color(0xFF65b2c9) : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
