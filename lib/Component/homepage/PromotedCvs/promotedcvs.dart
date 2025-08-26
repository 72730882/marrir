import 'package:flutter/material.dart';

class PromotedCVsScreen extends StatelessWidget {
  const PromotedCVsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();

    // Hardcoded CVs list for demo
    final List<Map<String, String>> cvs = [
      {
        "name": "Hanan Nasser",
        "role": "Driver",
        "location": "Addis Ababa",
        "experience": "2 years experience"
      },
      {
        "name": "Ahmed Yusuf",
        "role": "Mechanic",
        "location": "Dire Dawa",
        "experience": "4 years experience"
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hurry Up and Reserve These Promoted CVs",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 400, // height to allow PageView scrolling
            child: PageView.builder(
              controller: controller,
              itemCount: cvs.length,
              itemBuilder: (context, index) {
                final cv = cvs[index];
                return Column(
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFFFFFFF)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 225, 225, 225),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  "Profile Image",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              cv["name"]!,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              cv["role"]!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF65b2c9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cv["location"]!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 57, 57, 57),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cv["experience"]!,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF65b2c9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  "Reserve Now",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Pagination with buttons and circle indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text(
                  "← Previous",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),

              // Circle indicators
              Row(
                children: List.generate(
                  cvs.length,
                  (index) => AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      double selectedness = 0.0;
                      if (controller.hasClients) {
                        selectedness = (controller.page ?? 0) - index;
                        selectedness =
                            1.0 - (selectedness.abs().clamp(0.0, 1.0));
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedness > 0.5
                              ? const Color(0xFF65b2c9)
                              : Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text(
                  "Next →",
                  style: TextStyle(fontSize: 14, color: Color(0xFF65b2c9)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
