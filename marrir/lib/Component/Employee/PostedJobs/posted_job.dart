import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marrir/services/Employer/job_service.dart';
import 'package:dio/dio.dart';
// import 'package:intl/intl.dart';

class RecentlyPostedJobs extends StatefulWidget {
  const RecentlyPostedJobs({super.key});

  @override
  State<RecentlyPostedJobs> createState() => _RecentlyPostedJobsState();
}

class _RecentlyPostedJobsState extends State<RecentlyPostedJobs> {
  final ScrollController _scrollController = ScrollController();
  final JobService _jobService = JobService();
  int _currentIndex = 0;
  Timer? _timer;
  bool isLoading = true;
  String? errorMessage;
  List<dynamic> recentJobs = [];

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
  void initState() {
    super.initState();
    _startAutoSlide();
    fetchRecentJobs();
  }

  Future<void> fetchRecentJobs() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final allJobs = await _jobService.getJobs(
        skip: 0,
        limit: 50, // Get more jobs to filter recent ones
      );

      // Filter jobs from last 24 hours
      final now = DateTime.now();
      final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

      setState(() {
        recentJobs = allJobs.where((job) {
          final createdAt = _parseJobDate(job);
          return createdAt != null && createdAt.isAfter(twentyFourHoursAgo);
        }).toList();

        isLoading = false;
      });
    } on DioException catch (e) {
      final errorMsg = ApiErrorHandler.handleDioError(e);
      setState(() {
        isLoading = false;
        errorMessage = errorMsg;
        recentJobs = [];
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Unexpected error: $e';
        recentJobs = [];
      });
    }
  }

  DateTime? _parseJobDate(dynamic job) {
    try {
      final createdAt = job['created_at'];
      if (createdAt is String) {
        return DateTime.parse(createdAt);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _getJobField(dynamic job, String fieldName) {
    try {
      final value = job[fieldName];
      return value?.toString() ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentIndex < topCards.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      _scrollController.animateTo(
        _currentIndex * 360,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

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
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: topCards.length,
              itemBuilder: (context, index) {
                final card = topCards[index];
                return SizedBox(
                  width: 360,
                  child: buildTopCard(
                    card['title'] as String,
                    card['description'] as String,
                    const Color(0xFF65b2c9),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Section title
          const Text(
            "Recently Posted Jobs (Last 24h)",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Loading/Error States
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            Center(
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            )
          else if (recentJobs.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.work_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No recent jobs found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    "Jobs posted in the last 24 hours will appear here",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            // Job cards
            ...recentJobs.map(
              (job) => jobCard(job: job),
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
  Widget jobCard({required dynamic job}) {
    final title = _getJobField(job, 'name');
    final company = _getJobField(job, 'company') != 'N/A'
        ? _getJobField(job, 'company')
        : 'Unknown Company';
    final location = _getJobField(job, 'location');
    final jobType = _getJobField(job, 'type');
    final salary = _getJobField(job, 'amount') != 'N/A'
        ? '\$${_getJobField(job, 'amount')}'
        : 'Salary not specified';

    final createdAt = _parseJobDate(job);
    final postedTime = createdAt != null ? _getTimeAgo(createdAt) : 'Recently';

    // Determine workplace type based on location or other criteria
    final workplace =
        location.toLowerCase().contains('remote') ? 'Remote' : 'On-Site';

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
            Align(
              alignment: Alignment.topRight,
              child: Text(
                postedTime,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              "$company\n$location",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                tag(
                  jobType != 'N/A'
                      ? JobService.getOccupationDisplayName(jobType)
                      : 'General',
                  const Color.fromARGB(255, 151, 196, 210),
                  const Color.fromARGB(255, 251, 252, 252),
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
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// Error Handler Helper
class ApiErrorHandler {
  static String handleDioError(DioException e) {
    if (e.response != null) {
      final responseData = e.response?.data;
      String? serverMessage;
      if (responseData is Map<String, dynamic>) {
        serverMessage = responseData['message'] ??
            responseData['detail'] ??
            responseData['error'];
      }
      switch (e.response?.statusCode) {
        case 400:
          return serverMessage ?? 'Bad request. Please check your input.';
        case 401:
          return serverMessage ?? 'Unauthorized. Please login again.';
        case 403:
          return serverMessage ?? 'Forbidden.';
        case 404:
          return serverMessage ?? 'Not found.';
        case 422:
          return serverMessage ?? 'Validation error.';
        case 500:
          return serverMessage ?? 'Server error.';
        default:
          return serverMessage ?? 'Unexpected error: ${e.response?.statusCode}';
      }
    } else {
      return 'Network error: ${e.message}';
    }
  }
}
