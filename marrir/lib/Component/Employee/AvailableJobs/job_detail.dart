import 'package:flutter/material.dart';
import 'package:marrir/services/Employer/job_service.dart';
import 'package:marrir/services/Employer/get_comany_info.dart';
import 'package:marrir/services/Employee/job_application.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/user.dart'; // Make sure to import your ApiService

class JobDetailsPage extends StatefulWidget {
  const JobDetailsPage({super.key, required this.job});

  final Map<dynamic, dynamic> job;

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final CompanyService _companyService = CompanyService();
  final JobApplicationService _jobApplicationService = JobApplicationService();

  Map<String, dynamic> _companyInfo = {};
  bool _isLoadingCompanyInfo = true;
  bool _isCheckingApplication = true;
  bool _hasApplied = false;
  String? _applicationStatus;
  String? _currentUserId;
  bool _isProcessing = false;
  Map<String, dynamic>? _userData;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getCurrentUserAndToken();
    await _fetchCompanyInfo();
    await _checkApplicationStatus();
  }

  Future<void> _getCurrentUserAndToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString("user_email");
      _authToken = prefs.getString(
          "access_token"); // Assuming you store token as "auth_token"

      if (email == null || _authToken == null) {
        print('No stored email or token found');
        setState(() {
          _isCheckingApplication = false;
        });
        return;
      }

      // Fetch user data using your existing ApiService
      final userData =
          await ApiService.getUserInfo(email: email, Token: _authToken!);

      setState(() {
        _userData = userData;
        _currentUserId = userData['id']?.toString();
      });
    } catch (e) {
      print('Error getting current user: $e');
      setState(() {
        _isCheckingApplication = false;
      });
    }
  }

  Future<void> _fetchCompanyInfo() async {
    try {
      final postedBy = widget.job['posted_by']?.toString();
      if (postedBy != null && postedBy.isNotEmpty) {
        final companyInfo =
            await _companyService.getCompanyInfoByUserId(postedBy);
        setState(() {
          _companyInfo = companyInfo;
          _isLoadingCompanyInfo = false;
        });
      } else {
        setState(() {
          _isLoadingCompanyInfo = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching company info: $e');
      setState(() {
        _isLoadingCompanyInfo = false;
      });
    }
  }

  Future<void> _checkApplicationStatus() async {
    if (_currentUserId == null) {
      setState(() {
        _isCheckingApplication = false;
      });
      return;
    }

    try {
      final hasApplied = await _jobApplicationService.hasUserApplied(
        jobId: widget.job['id'],
        userId: _currentUserId!,
      );

      String? status;
      if (hasApplied) {
        status = await _jobApplicationService.getApplicationStatus(
          jobId: widget.job['id'],
          userId: _currentUserId!,
        );
      }

      setState(() {
        _hasApplied = hasApplied;
        _applicationStatus = status;
        _isCheckingApplication = false;
      });
    } catch (e) {
      print('Error checking application status: $e');
      setState(() {
        _isCheckingApplication = false;
      });
    }
  }

  Future<void> _applyForJob() async {
    if (_currentUserId == null) {
      _showSnackBar('Please login to apply for jobs');
      return;
    }

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _jobApplicationService.applyForJob(
        jobId: widget.job['id'],
        userId: _currentUserId!,
      );

      if (result['success'] == true) {
        _showSnackBar(
            result['message'] ?? 'Application submitted successfully!',
            isError: false);
        setState(() {
          _hasApplied = true;
          _applicationStatus = 'pending';
        });
      } else {
        _showSnackBar(result['message'] ?? 'Failed to apply for job',
            isError: true);
      }
    } catch (e) {
      _showSnackBar('Error applying for job: $e', isError: true);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _withdrawApplication() async {
    if (_currentUserId == null) return;

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _jobApplicationService.removeApplication(
        jobId: widget.job['id'],
        userId: _currentUserId!,
      );

      if (result['success'] == true) {
        _showSnackBar(
            result['message'] ?? 'Application withdrawn successfully!',
            isError: false);
        setState(() {
          _hasApplied = false;
          _applicationStatus = null;
        });
      } else {
        _showSnackBar(result['message'] ?? 'Failed to withdraw application',
            isError: true);
      }
    } catch (e) {
      _showSnackBar('Error withdrawing application: $e', isError: true);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getStatusDisplayText() {
    switch (_applicationStatus?.toLowerCase()) {
      case 'pending':
        return 'Application Pending';
      case 'accepted':
        return 'Application Accepted 🎉';
      case 'declined':
        return 'Application Declined';
      default:
        return 'Apply Now';
    }
  }

  Color _getStatusColor() {
    switch (_applicationStatus?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      default:
        return const Color(0xFF65B2C9);
    }
  }

  IconData _getStatusIcon() {
    switch (_applicationStatus?.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'accepted':
        return Icons.check_circle;
      case 'declined':
        return Icons.cancel;
      default:
        return Icons.work_outline;
    }
  }

  // Add user info display in the header (optional)
  Widget _buildUserInfo() {
    if (_userData == null) {
      return Container();
    }

    final fullName = "${_userData!['first_name']} ${_userData!['last_name']}";
    final role = _userData!['role'] ?? "";

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 24, color: Color(0xFF111111)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companyName = _companyService.getCompanyDisplayName(_companyInfo);
    final companyLocation = _companyService.getCompanyLocation(_companyInfo);
    final companyLogo = _companyInfo['company_logo'];
    final jobLocation = widget.job['location'] ?? 'Location not specified';
    final jobType = widget.job['type'] ?? 'Full-time';
    final jobAmount = widget.job['amount'] != null
        ? '\$${widget.job['amount']}'
        : 'Salary not specified';
    final jobDescription =
        widget.job['description'] ?? 'No description available';
    final jobRequirements =
        widget.job['requirements'] ?? 'No requirements specified';
    final jobOccupation = widget.job['occupation'] ?? 'Not specified';
    final experienceRequired =
        widget.job['experience_required'] ?? 'Not specified';
    final positionsAvailable = widget.job['positions'] ?? '1';

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
      body: _isLoadingCompanyInfo || _isCheckingApplication
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // User Info (optional - you can remove this if not needed)
                  // _buildUserInfo(),

                  // Job header
                  Column(
                    children: [
                      // Company Logo/Icon
                      if (companyLogo != null &&
                          companyLogo.toString().isNotEmpty)
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(companyLogo.toString()),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
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
                      // Job Title
                      Text(
                        widget.job['name']?.toString() ?? 'No title',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      // Company Name
                      Text(
                        companyName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 49, 49, 49),
                        ),
                      ),
                      // Location and Job Type
                      Text(
                        '$jobLocation • ${_getJobTypeDisplay(jobType)}',
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      // Salary and Job Type
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$jobAmount  ·  ',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF65B2C9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: _getJobTypeDisplay(jobType),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 49, 49, 49),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Application Status Badge (if applied)
                  if (_hasApplied && _applicationStatus != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor().withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(),
                            color: _getStatusColor(),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getStatusDisplayText(),
                            style: TextStyle(
                              color: _getStatusColor(),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_hasApplied && _applicationStatus != null)
                    const SizedBox(height: 16),

                  // Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoCard(Icons.access_time, "Posted",
                          _getTimeAgo(widget.job['created_at'])),
                      _infoCard(Icons.people, "Positions",
                          positionsAvailable.toString()),
                      _infoCard(Icons.star_border, "Experience",
                          experienceRequired.toString()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Job Description
                  _sectionCard(
                    title: "Job Description",
                    content: jobDescription,
                  ),
                  const SizedBox(height: 16),

                  // Occupation/Field
                  if (jobOccupation != 'Not specified')
                    _sectionCard(
                      title: "Field",
                      content:
                          JobService.getOccupationDisplayName(jobOccupation),
                    ),
                  const SizedBox(height: 16),

                  // Requirements
                  _sectionCard(
                    title: "Requirements",
                    content: jobRequirements,
                  ),
                  const SizedBox(height: 16),

                  // About Company
                  _sectionCard(
                    title: "About Company",
                    contentWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Company Logo/Icon
                            if (companyLogo != null &&
                                companyLogo.toString().isNotEmpty)
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(companyLogo.toString()),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.blueGrey.shade100.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.business,
                                  size: 28,
                                  color: Colors.grey,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    companyName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  if (_companyInfo['industry'] != null)
                                    Text(
                                      "${_companyInfo['industry']} • ${_companyInfo['company_size'] ?? ''}",
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                    ),
                                  if (_companyInfo['year_established'] != null)
                                    Text(
                                      "Est. ${_companyInfo['year_established']} • $companyLocation",
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_companyInfo['description'] != null)
                          Text(
                            _companyInfo['description'].toString(),
                            style: const TextStyle(fontSize: 14),
                          )
                        else
                          const Text(
                            "No company description available.",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Apply/Withdraw Button
                  SizedBox(
                    width: double.infinity,
                    child: _isProcessing
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: null,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Processing...",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          )
                        : _hasApplied
                            ? OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _withdrawApplication,
                                child: const Text(
                                  "Withdraw Application",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF65B2C9),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _applyForJob,
                                child: const Text(
                                  "Apply Now",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  String _getJobTypeDisplay(String jobType) {
    final typeMap = {
      'contractual': 'Contractual',
      'temporary': 'Temporary',
      'full_time': 'Full-time',
      'recruiting_worker': 'Recruiting Worker',
      'worker_transport_service': 'Worker Transport Service',
      'hiring_worker': 'Hiring Worker',
    };
    return typeMap[jobType] ?? jobType;
  }

  String _getTimeAgo(dynamic createdAt) {
    if (createdAt == null) return 'Recently';

    try {
      final date = DateTime.parse(createdAt.toString());
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
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
          textAlign: TextAlign.center,
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
            Text(
              content,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          if (contentWidget != null) contentWidget,
        ],
      ),
    );
  }
}
