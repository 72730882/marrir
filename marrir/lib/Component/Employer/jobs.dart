import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:marrir/Component/Employee/AvailableJobs/job_detail.dart';
import 'package:marrir/services/Employer/job_service.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => JobsPageState();
}

class JobsPageState extends State<JobsPage> {
  final JobService _jobService = JobService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> jobs = [];
  List<dynamic> filteredJobs = [];
  bool isLoading = true;
  bool isSearching = false;
  int currentPage = 1;
  final int jobsPerPage = 5;
  String? errorMessage;
  String selectedTab = "All";
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    fetchJobs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isEmpty) {
        // If search is cleared, show all jobs
        setState(() {
          filteredJobs = jobs;
          isSearching = false;
        });
      } else {
        // Perform local search first
        _performLocalSearch();
      }
    });
  }

  void _performLocalSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      isSearching = true;
      filteredJobs = jobs.where((job) {
        final name = _getJobField(job, 'name').toLowerCase();
        final description = _getJobField(job, 'description').toLowerCase();
        final location = _getJobField(job, 'location').toLowerCase();
        final occupation = _getJobField(job, 'occupation').toLowerCase();

        return name.contains(query) ||
            description.contains(query) ||
            location.contains(query) ||
            occupation.contains(query);
      }).toList();
    });
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
        filteredJobs = jobList;
        isLoading = false;
        isSearching = false;
      });
    } on DioException catch (e) {
      final errorMsg = ApiErrorHandler.handleDioError(e);
      setState(() {
        isLoading = false;
        errorMessage = errorMsg;
        jobs = [];
        filteredJobs = [];
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Unexpected error: $e';
        jobs = [];
        filteredJobs = [];
      });
    }
  }

  Future<void> refreshJobs() async {
    setState(() {
      currentPage = 1;
      _searchController.clear();
    });
    await fetchJobs();
  }

  Future<void> createJob(Map<String, dynamic> jobData) async {
    try {
      setState(() => isLoading = true);
      await _jobService.createJob(jobData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job created successfully')),
      );
      await refreshJobs();
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating job: $e')),
      );
    }
  }

  Future<void> bulkUploadJobs() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );
      if (result != null) {
        setState(() => isLoading = true);
        await _jobService.bulkUploadJobs(result.files.single.path!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jobs uploaded successfully')),
        );
        await refreshJobs();
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading jobs: $e')),
      );
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
    final displayJobs = isSearching ? filteredJobs : jobs;
    int totalPages = (jobs.length / jobsPerPage).ceil();
    totalPages = totalPages == 0 ? 1 : totalPages;

    return Scaffold(
      backgroundColor: Colors.white,
      // REMOVED THE BOTTOM NAVIGATION BAR
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refreshJobs,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar with filter icon
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search jobs...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune, color: Colors.black54),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Create Job + Bulk Upload Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF65B2C9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => showCreateJobDialog(context),
                        child: const Text("Create Job"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF65B2C9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: bulkUploadJobs,
                        child: const Text("Bulk Upload"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tabs + Dropdown
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text("All"),
                      selected: selectedTab == "All",
                      selectedColor: const Color(0xFF65B2C9).withOpacity(0.2),
                      onSelected: (_) => setState(() => selectedTab = "All"),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("My Jobs"),
                      selected: selectedTab == "My Job Posts",
                      selectedColor: const Color(0xFF65B2C9).withOpacity(0.2),
                      onSelected: (_) =>
                          setState(() => selectedTab = "My Job Posts"),
                    ),
                    const Spacer(),
                    DropdownButton<int>(
                      value: jobsPerPage,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 5, child: Text("5")),
                        DropdownMenuItem(value: 10, child: Text("10")),
                        DropdownMenuItem(value: 20, child: Text("20")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            currentPage = 1;
                          });
                          fetchJobs();
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Search results indicator
                if (isSearching && _searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Found ${filteredJobs.length} results for "${_searchController.text}"',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),

                // Loading/Error States
                if (isLoading)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ))
                else if (errorMessage != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (displayJobs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          const Icon(Icons.work_outline,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? "No jobs found"
                                : "No jobs match your search",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                          if (_searchController.text.isNotEmpty)
                            const SizedBox(height: 8),
                          if (_searchController.text.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  isSearching = false;
                                });
                              },
                              child: const Text('Clear search'),
                            ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  for (var job in displayJobs) ...[
                    jobCard(job: job),
                    const SizedBox(height: 12),
                  ],

                  // Pagination controls (only show when not searching)
                  if (!isSearching && jobs.isNotEmpty)
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
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
          ),
        ),
      ),
    );
  }

  // ================= POPUPS ==================
  void showCreateJobDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final locationController = TextEditingController();
    final occupationController = TextEditingController();
    String? selectedJobType;
    String? selectedEducationStatus;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Job"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Job Name *"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description *"),
                maxLines: 3,
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: "Salary Amount *"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location *"),
              ),
              TextField(
                controller: occupationController,
                decoration: const InputDecoration(labelText: "Occupation"),
              ),
              DropdownButtonFormField<String>(
                value: selectedEducationStatus,
                decoration:
                    const InputDecoration(labelText: "Education Status"),
                items: const [
                  DropdownMenuItem(
                      value: 'high_school', child: Text('High School')),
                  DropdownMenuItem(value: 'diploma', child: Text('Diploma')),
                  DropdownMenuItem(value: 'bachelor', child: Text('Bachelor')),
                  DropdownMenuItem(value: 'master', child: Text('Master')),
                  DropdownMenuItem(value: 'phd', child: Text('PhD')),
                ],
                onChanged: (value) => selectedEducationStatus = value,
              ),
              DropdownButtonFormField<String>(
                value: selectedJobType,
                decoration: const InputDecoration(labelText: "Job Type *"),
                items: const [
                  DropdownMenuItem(
                      value: 'full_time', child: Text('Full Time')),
                  DropdownMenuItem(
                      value: 'contractual', child: Text('Contractual')),
                  DropdownMenuItem(
                      value: 'temporary', child: Text('Temporary')),
                  DropdownMenuItem(
                      value: 'recruiting_worker',
                      child: Text('Recruiting Worker')),
                  DropdownMenuItem(
                      value: 'worker_transport_service',
                      child: Text('Worker Transport Service')),
                  DropdownMenuItem(
                      value: 'hiring_worker', child: Text('Hiring Worker')),
                ],
                onChanged: (value) => selectedJobType = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  amountController.text.isEmpty ||
                  locationController.text.isEmpty ||
                  selectedJobType == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill all required fields')),
                );
                return;
              }

              final amount = int.tryParse(amountController.text);
              if (amount == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter a valid salary amount')),
                );
                return;
              }

              // Only send fields that backend accepts
              final jobData = {
                "name": nameController.text,
                "description": descriptionController.text,
                "amount": amount,
                "location": locationController.text,
                "type": selectedJobType,
                "is_open": true,
                // Optional fields
                if (occupationController.text.isNotEmpty)
                  "occupation": occupationController.text,
                if (selectedEducationStatus != null)
                  "education_status": selectedEducationStatus,
              };

              await createJob(jobData);
              Navigator.pop(context);
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  // ================= JOB CARD ==================
  Widget jobCard({required dynamic job}) {
    final occupation = _getJobField(job, 'occupation');
    final educationStatus = _getJobField(job, 'education_status');
    final jobType = _getJobField(job, 'type');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFEDF8FB),
                child: Icon(Icons.work_outline, color: Colors.black54),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getJobField(job, 'name'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    if (occupation != 'N/A')
                      Text(
                        occupation,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  jobType != 'N/A'
                      ? JobService.getOccupationDisplayName(jobType)
                      : 'N/A',
                  style: const TextStyle(fontSize: 12, color: Colors.purple),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // DESCRIPTION
          Text(
            _getJobField(job, 'description'),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // JOB META INFO
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildMetaInfo(Icons.place, _getJobField(job, 'location')),
              _buildMetaInfo(
                  Icons.attach_money,
                  _getJobField(job, 'amount') != 'N/A'
                      ? '\$${_getJobField(job, 'amount')}'
                      : 'Not specified'),
              if (educationStatus != 'N/A')
                _buildMetaInfo(Icons.school, educationStatus),
            ],
          ),
          const SizedBox(height: 12),

          // STATUS BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getJobField(job, 'is_open') == 'true'
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getJobField(job, 'is_open') == 'true' ? 'Open' : 'Closed',
              style: TextStyle(
                color: _getJobField(job, 'is_open') == 'true'
                    ? Colors.green
                    : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF65B2C9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JobDetailsPage(job: job),
                  ),
                );
              },
              child: const Text("View Job Details"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ================= Error Handler Helper =================
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
