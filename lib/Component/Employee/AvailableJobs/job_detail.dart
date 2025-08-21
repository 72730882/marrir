import 'package:flutter/material.dart';

class JobDetailsPage extends StatelessWidget {
  const JobDetailsPage({super.key, required this.job});

  final Map<String, dynamic> job;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Job Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Job header
            Column(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.business,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Senior iOS Developer",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Apple Inc.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 49, 49, 49),
                  ),
                ),
                const Text(
                  "Cupertino, CA · Remote",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "\$120k - \$180k  ·  ",
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF65B2C9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: "Full-time",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(
                            255,
                            49,
                            49,
                            49,
                          ), // 👈 Full-time in black
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoCard(Icons.access_time, "Posted", "2 days ago"),
                _infoCard(Icons.people, "Positions", "2"),
                _infoCard(Icons.star_border, "Experience", "5+ years"),
              ],
            ),
            const SizedBox(height: 16),

            // Job Description
            _sectionCard(
              title: "Job Description",
              content:
                  "We’re looking for a Senior iOS Developer to join our innovative team and help build the next generation of mobile applications that will be used by millions of users worldwide.\n\n"
                  "As a Senior iOS Developer, you'll work closely with our design and product teams to create exceptional user experiences using the latest iOS technologies and frameworks.",
            ),
            const SizedBox(height: 16),

            // Key Responsibilities
            _sectionCard(
              title: "Key Responsibilities",
              contentWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bulletText(
                    "Develop and maintain high-quality iOS applications using Swift and SwiftUI",
                  ),
                  _bulletText(
                    "Collaborate with cross-functional teams to define and implement new features",
                  ),
                  _bulletText(
                    "Write clean, maintainable, and well-documented code",
                  ),
                  _bulletText(
                    "Participate in code reviews and mentor junior developers",
                  ),
                  _bulletText(
                    "Stay up-to-date with the latest iOS development trends and technologies",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Requirements
            _sectionCard(
              title: "Requirements",
              contentWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _checkText("5+ years of iOS development experience"),
                  _checkText("Proficiency in Swift and SwiftUI"),
                  _checkText(
                    "Experience with Core Data, UIKit, and iOS frameworks",
                  ),
                  _checkText("Knowledge of RESTful APIs and JSON"),
                  _checkText(
                    "Strong understanding of Apple's design principles",
                  ),
                  _checkText("Experience with Git version control"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Skills Required
            _sectionCard(
              title: "Skills Required",
              contentWidget: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _skillChip("Swift"),
                  _skillChip("SwiftUI"),
                  _skillChip("UIKit"),
                  _skillChip("Core Data"),
                  _skillChip("REST APIs"),
                  _skillChip("Git"),
                  _skillChip("Xcode"),
                  _skillChip("iOS SDK"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // About Company
            _sectionCard(
              title: "About Apple Inc.",
              contentWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.apple,
                          size: 28,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Apple Inc.",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Technology • 10,000+ employees",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          Text(
                            "Founded 1976 • Cupertino, CA",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Apple is a multinational technology company that designs, develops, and sells consumer electronics, computer software, and online services.",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Apply Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF65B2C9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Apply Now",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF65B2C9), size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    String? content,
    Widget? contentWidget,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (content != null)
            Text(content, style: const TextStyle(fontSize: 15)),
          if (contentWidget != null) contentWidget,
        ],
      ),
    );
  }

  Widget _bulletText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 20, color: Colors.purple),
          ),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _checkText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color.fromARGB(255, 24, 194, 78),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _skillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
