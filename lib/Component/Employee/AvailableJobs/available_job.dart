import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/AvailableJobs/job_detail.dart';

class AvailableJob extends StatefulWidget {
  const AvailableJob({super.key});

  @override
  State<AvailableJob> createState() => _AvailableJobState();
}

class _AvailableJobState extends State<AvailableJob> {
  int currentPage = 1;
  final int jobsPerPage = 5;

  final List<Map<String, dynamic>> jobs = [
    {
      "title": "Mobile App Designer",
      "company": "Google LLC",
      "jobType": "Contract",
      "description":
          "Design intuitive and beautiful mobile experiences for our next-generation apps",
      "location": "Remote",
      "salary": "\$80k-100k",
      "positions": "3 Positions",
      "tags": ["Figma", "UI/UX", "Mobile"],
    },
    {
      "title": "Product Manager",
      "company": "Microsoft Corp",
      "jobType": "Part-time",
      "description":
          "Lead product strategy for mobile applications, ensuring optimal performance.",
      "location": "On-Site",
      "salary": "\$80k-100k",
      "positions": "3 Positions",
      "tags": ["Strategy", "Analytics", "Mobile"],
    },
    {
      "title": "UI Designer",
      "company": "Adobe Inc",
      "jobType": "Full-time",
      "description": "Craft engaging user interfaces for creative tools.",
      "location": "Remote",
      "salary": "\$90k-110k",
      "positions": "2 Positions",
      "tags": ["Design", "UX", "Creativity"],
    },
    {
      "title": "Backend Developer",
      "company": "Amazon Web Services",
      "jobType": "Full-time",
      "description": "Build robust and scalable backend APIs.",
      "location": "Remote",
      "salary": "\$100k-130k",
      "positions": "4 Positions",
      "tags": ["Java", "AWS", "Microservices"],
    },
    {
      "title": "Data Scientist",
      "company": "Netflix",
      "jobType": "Contract",
      "description": "Analyze viewer data to improve recommendations.",
      "location": "Remote",
      "salary": "\$110k-140k",
      "positions": "1 Position",
      "tags": ["Python", "Machine Learning", "Data"],
    },
    {
      "title": "QA Engineer",
      "company": "Spotify",
      "jobType": "Full-time",
      "description": "Test and ensure quality across all platforms.",
      "location": "On-Site",
      "salary": "\$70k-90k",
      "positions": "2 Positions",
      "tags": ["Testing", "Automation", "Quality"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    int totalPages = (jobs.length / jobsPerPage).ceil();
    int startIndex = (currentPage - 1) * jobsPerPage;
    int endIndex = (startIndex + jobsPerPage).clamp(0, jobs.length);
    List<Map<String, dynamic>> jobsToShow = jobs.sublist(startIndex, endIndex);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Available Jobs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Loop through jobsToShow and pass each job to jobCard
          for (var job in jobsToShow) ...[
            jobCard(job: job),
            const SizedBox(height: 12),
          ],

          // Pagination controls
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: currentPage > 1
                        ? () => setState(() => currentPage--)
                        : null,
                    child: const Text("← Previous"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("Page $currentPage of $totalPages"),
                  ),
                  TextButton(
                    onPressed: currentPage < totalPages
                        ? () => setState(() => currentPage++)
                        : null,
                    child: const Text("Next →"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget jobCard({required Map<String, dynamic> job}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.work_outline, color: Colors.grey),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            job['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            job['jobType'],
                            style: const TextStyle(
                              color: Colors.purple,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job['company'],
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(job['description'], style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(job['location'], style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 12),
              const Icon(Icons.attach_money, size: 16, color: Colors.grey),
              Text(job['salary'], style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 12),
              const Icon(
                Icons.people_alt_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(job['positions'], style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: job['tags'].map<Widget>((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF65B2C9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JobDetailsPage(job: job)),
                );
              },
              child: const Text("View Job Details"),
            ),
          ),
        ],
      ),
    );
  }
}
