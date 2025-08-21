import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<Map<String, String>> _faqs = [
    {
      "q": "How do I add a new employee?",
      "a": "Go to Dashboard > Add Employee.",
    },
    {
      "q": "How can I promote an employee profile?",
      "a": "Navigate to Employee Profile > Promotion.",
    },
    {
      "q": "What is the difference between reserve and transfer?",
      "a": "Reserve keeps the slot, transfer reassigns it.",
    },
    {
      "q": "How do I track payments?",
      "a": "Go to Payment section for full history.",
    },
    {
      "q": "Can I export employee data?",
      "a": "Yes, from Settings > Export Data.",
    },
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
          "Help Center",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            const Text(
              "Help Center",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Find answers to your questions and get support",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Top Support Options
            Row(
              children: [
                _supportOption(
                  Icons.help_outline,
                  "FAQ",
                  "Find answers to common questions",
                  Colors.purple,
                ),
                const SizedBox(width: 12),
                _supportOption(
                  Icons.email_outlined,
                  "Email",
                  "Email Support",
                  Colors.pink,
                ),
                const SizedBox(width: 12),
                _supportOption(
                  Icons.phone_outlined,
                  "Phone",
                  "Phone Support",
                  Colors.deepPurple,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search box
            const Text(
              "Help Questions",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: "Search help articles...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
              ),
            ),
            const SizedBox(height: 20),

            // FAQ section
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ...List.generate(_faqs.length, (index) {
              return _buildFAQItem(
                index,
                _faqs[index]["q"]!,
                _faqs[index]["a"]!,
              );
            }),
            const SizedBox(height: 20),

            // Contact Support
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Still Need Help?",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Can’t find what you’re looking for? Our support team is here to help.",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Contact Support"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Info Cards
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    Icons.menu_book_outlined,
                    "Documentation",
                    "Detailed guides and API documentation",
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard(
                    Icons.play_circle_outline,
                    "Tutorials",
                    "Step-by-step video tutorials and guides",
                    Colors.pink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard(
                    Icons.people_outline,
                    "Community",
                    "Join our community forums for discussions and support",
                    Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Support Option Card ---
  Widget _supportOption(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // --- FAQ Item ---
  Widget _buildFAQItem(int index, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          question,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        iconColor: Colors.black,
        collapsedIconColor: Colors.black,
        onExpansionChanged: (expanded) {
          setState(() {});
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // --- Info Card ---
  Widget _infoCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
