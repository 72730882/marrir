import 'package:flutter/material.dart';

class RecentlyPostedJobs extends StatelessWidget {
  const RecentlyPostedJobs({super.key});

  // Temporary dummy job list (replace with backend later)
  final List<Map<String, dynamic>> jobs = const [
    {
      'title': 'Senior Driver',
      'company': 'Marrir',
      'location': 'Addis Ababa, Eth',
      'type': 'Full-time',
      'workplace': 'On-Site',
      'salary': '\$120k - \$180k',
      'postedTime': '2h ago',
    },
    {
      'title': 'Senior Driver',
      'company': 'Marrir',
      'location': 'Addis Ababa, Eth',
      'type': 'Full-time',
      'workplace': 'On-Site',
      'salary': '\$120k - \$180k',
      'postedTime': '4h ago',
    },
    {
      'title': 'Senior Driver',
      'company': 'Marrir',
      'location': 'Addis Ababa, Eth',
      'type': 'Full-time',
      'workplace': 'On-Site',
      'salary': '\$120k - \$180k',
      'postedTime': '6h ago',
    },
  ];

  // Top horizontal slider data
  final List<Map<String, dynamic>> topCards = const [
    {
      'title': 'Build Your CV',
      'description': 'Generate a professional CV using your profile data.',
    },
    {
      'title': 'Search Jobs',
      'description': 'Find jobs that match your skills and location.',
    },
    {
      'title': 'Upgrade Skills',
      'description': 'Learn and improve your skills for better opportunities.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal scrollable top cards
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: topCards.length,
              itemBuilder: (context, index) {
                final card = topCards[index];
                return SizedBox(
                  width: 360, // Full width card
                  child: buildTopCard(
                    card['title'] as String,
                    card['description'] as String,
                    const Color(0xFF65b2c9), // Card color
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Section title
          const Text(
            "Recently Posted Jobs",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Job cards
          ...jobs.map(
            (job) => jobCard(
              job['title'] as String,
              job['company'] as String,
              job['location'] as String,
              job['type'] as String,
              job['workplace'] as String,
              job['salary'] as String,
              job['postedTime'] as String,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable top card widget
  Widget buildTopCard(String title, String description, Color color) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 240, 239, 239),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable job card widget
  Widget jobCard(
    String title,
    String company,
    String location,
    String type,
    String workplace,
    String salary,
    String postedTime,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Posted time
            Align(
              alignment: Alignment.topRight,
              child: Text(
                postedTime,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 4),

            // Job title
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),

            // Company & location
            Text(
              "$company\n$location",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),

            // Tags
            Row(
              children: [
                tag(
                  type,
                  Color.fromARGB(255, 151, 196, 210),
                  Color.fromARGB(255, 251, 252, 252),
                ),
                const SizedBox(width: 6),
                tag(
                  workplace,

                  const Color.fromARGB(255, 150, 99, 143),
                  const Color.fromARGB(255, 253, 252, 253),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Salary
            Text(
              salary,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable tag widget
  Widget tag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 12)),
    );
  }
}
