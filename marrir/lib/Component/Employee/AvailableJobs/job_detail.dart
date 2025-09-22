import 'package:flutter/material.dart';
import 'package:marrir/services/Employer/job_service.dart';
import 'package:marrir/services/Employer/get_comany_info.dart';

class JobDetailsPage extends StatefulWidget {
  const JobDetailsPage({super.key, required this.job});

  final Map<dynamic, dynamic> job;

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final CompanyService _companyService = CompanyService();
  Map<String, dynamic> _companyInfo = {};
  bool _isLoadingCompanyInfo = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanyInfo();
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
      body: _isLoadingCompanyInfo
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                      onPressed: () {
                        // Handle apply logic
                      },
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
