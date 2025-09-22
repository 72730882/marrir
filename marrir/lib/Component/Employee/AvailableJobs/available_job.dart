import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/AvailableJobs/job_detail.dart';
import 'package:marrir/services/Employer/job_service.dart';
import 'package:dio/dio.dart';

class AvailableJob extends StatefulWidget {
  const AvailableJob({super.key});

  @override
  State<AvailableJob> createState() => _AvailableJobState();
}

class _AvailableJobState extends State<AvailableJob> {
  final JobService _jobService = JobService();
  int currentPage = 1;
  final int jobsPerPage = 5;
  bool isLoading = true;
  String? errorMessage;
  List<dynamic> jobs = [];

  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final jobList = await _jobService.getJobs(
        skip: (currentPage - 1) * jobsPerPage,
        limit: jobsPerPage,
      );

      setState(() {
        jobs = jobList;
        isLoading = false;
      });
    } on DioException catch (e) {
      final errorMsg = ApiErrorHandler.handleDioError(e);
      setState(() {
        isLoading = false;
        errorMessage = errorMsg;
        jobs = [];
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Unexpected error: $e';
        jobs = [];
      });
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

  @override
  Widget build(BuildContext context) {
    int totalPages = (jobs.length / jobsPerPage).ceil();
    totalPages = totalPages == 0 ? 1 : totalPages;
    int startIndex = (currentPage - 1) * jobsPerPage;
    int endIndex = (startIndex + jobsPerPage).clamp(0, jobs.length);
    List<dynamic> jobsToShow = jobs.sublist(startIndex, endIndex);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Date Filter Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "From",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: fromDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => fromDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fromDate == null
                                  ? "dd-mm-yyyy"
                                  : "${fromDate!.day.toString().padLeft(2, '0')}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.year}",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                            const Icon(Icons.calendar_today_outlined,
                                size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "To",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: toDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => toDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              toDate == null
                                  ? "dd-mm-yyyy"
                                  : "${toDate!.day.toString().padLeft(2, '0')}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.year}",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                            const Icon(Icons.calendar_today_outlined,
                                size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            "Available Jobs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          else if (jobs.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.work_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No jobs found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          else ...[
            // Jobs list
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
                          ? () {
                              setState(() => currentPage--);
                              fetchJobs();
                            }
                          : null,
                      child: const Text("← Previous"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Page $currentPage of $totalPages"),
                    ),
                    TextButton(
                      onPressed: currentPage < totalPages
                          ? () {
                              setState(() => currentPage++);
                              fetchJobs();
                            }
                          : null,
                      child: const Text("Next →"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget jobCard({required dynamic job}) {
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
                            _getJobField(job, 'name'),
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
                            _getJobField(job, 'type'),
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
                      _getJobField(job, 'company') != 'N/A'
                          ? _getJobField(job, 'company')
                          : 'Unknown Company',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getJobField(job, 'description'),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _getJobField(job, 'location'),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.attach_money, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _getJobField(job, 'amount') != 'N/A'
                    ? '\$${_getJobField(job, 'amount')}'
                    : 'Salary not specified',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.people_alt_outlined,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              const Text(
                "1 Position", // Default since positions_available isn't in backend
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              if (_getJobField(job, 'occupation') != 'N/A')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getJobField(job, 'occupation'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple,
                    ),
                  ),
                ),
              if (_getJobField(job, 'education_status') != 'N/A')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getJobField(job, 'education_status'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
            ],
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
