import 'package:flutter/material.dart';

class ServicesApp extends StatelessWidget {
  const ServicesApp({super.key});

  final List<Map<String, String>> services = const [
    {
      "title": "Job Posting",
      "desc":
          "Efficient and swift selection of candidates based on employers' specified job descriptions.",
    },
    {
      "title": "Profile Reservation",
      "desc":
          "Securing candidate profiles for personal interviews and future considerations.",
    },
    {
      "title": "Transfer Profile",
      "desc":
          "Enabling seamless transfer of data among relevant parties with utmost security and ease.",
    },
    {
      "title": "Profile Selection",
      "desc":
          "Selecting the most suitable applied profiles that closely match the requirements of the available vacancies.",
    },
    {
      "title": "Job Applications",
      "desc":
          "Employees can apply directly to job postings or users like RECRUITMENT FIRMS can submit applications on behalf of candidates.",
    },
    {
      "title": "Profile Promotion",
      "desc":
          "Facilitating the effective promotion of individual professional profiles, enhancing visibility and potential.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Services",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Empowering RECRUITMENT FIRMS, agents, and EMPLOYER with streamlined tools to manage job postings, profiles, and talent acquisition processes efficiently.",
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 57, 57, 57),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Grid of services
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 220,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.work_outline,
                      color: Color(0xFF5AC8FA),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      services[index]["title"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      services[index]["desc"]!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 57, 57, 57),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
