import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/AvailableJobs/job_detail.dart';
import 'package:marrir/Component/Employee/layout/employee_header.dart';
import 'package:marrir/services/Employer/job_service.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

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
  List<dynamic> filteredJobs = [];
  TextEditingController searchController = TextEditingController();

  DateTime? fromDate;
  DateTime? toDate;

  static const _hint = Color(0xFF9BA0A6);
  static const _searchBg = Color(0xFFF2F2F7);
  static const _ink = Color(0xFF111111);

  // Translation mappings based on your JobService constants
  final Map<String, Map<String, String>> _jobTypeTranslations = {
    'contractual': {'en': 'Contractual', 'ar': 'تعاقدي', 'am': 'ኮንትራት'},
    'temporary': {'en': 'Temporary', 'ar': 'مؤقت', 'am': 'ጊዜያዊ'},
    'full_time': {'en': 'Full Time', 'ar': 'دوام كامل', 'am': 'ሙሉ ጊዜ'},
    'recruiting_worker': {
      'en': 'Recruiting Worker',
      'ar': 'توظيف عامل',
      'am': 'ሰራተኛ መቅጠር'
    },
    'worker_transport_service': {
      'en': 'Worker Transport',
      'ar': 'نقل العمال',
      'am': 'ሰራተኛ መጓጓዣ'
    },
    'hiring_worker': {
      'en': 'Hiring Worker',
      'ar': 'تعيين عامل',
      'am': 'ሰራተኛ መቀጠር'
    },
  };

  final Map<String, Map<String, String>> _occupationTranslations = {
    'mobile': {'en': 'Mobile', 'ar': 'موبايل', 'am': 'ሞባይል'},
    'web': {'en': 'Web', 'ar': 'ويب', 'am': 'ድር'},
    'design': {'en': 'Design', 'ar': 'تصميم', 'am': 'ዲዛይን'},
    'marketing': {'en': 'Marketing', 'ar': 'تسويق', 'am': 'ግብይት'},
    'strategy': {'en': 'Strategy', 'ar': 'إستراتيجية', 'am': 'ስትራቴጂ'},
    'analytics': {'en': 'Analytics', 'ar': 'تحليلات', 'am': 'ትንታኔ'},
    'engineering': {'en': 'Engineering', 'ar': 'هندسة', 'am': 'ኢንጂነሪንግ'},
    'sales': {'en': 'Sales', 'ar': 'مبيعات', 'am': 'ሽያጭ'},
  };

  final Map<String, Map<String, String>> _educationTranslations = {
    'high_school': {
      'en': 'High School',
      'ar': 'ثانوية عامة',
      'am': 'ሁለተኛ ደረጃ ትምህርት'
    },
    'diploma': {'en': 'Diploma', 'ar': 'دبلوم', 'am': 'ዲፕሎማ'},
    'associate': {
      'en': 'Associate Degree',
      'ar': 'دبلوم جامعي',
      'am': 'አሶሺዬት ዲግሪ'
    },
    'bachelor': {
      'en': 'Bachelor\'s Degree',
      'ar': 'بكالوريوس',
      'am': 'ባችለር ዲግሪ'
    },
    'master': {'en': 'Master\'s Degree', 'ar': 'ماجستير', 'am': 'ማስተር ዲግሪ'},
    'phd': {'en': 'PhD', 'ar': 'دكتوراه', 'am': 'ዶክተር ዲግሪ'},
    'none': {
      'en': 'No Formal Education',
      'ar': 'بدون تعليم رسمي',
      'am': 'መሠረታዊ ትምህርት የለም'
    },
  };

  final Map<String, Map<String, String>> _locationTranslations = {
    'addis_ababa': {'en': 'Addis Ababa', 'ar': 'أديس أبابا', 'am': 'አዲስ አበባ'},
    'dubai': {'en': 'Dubai', 'ar': 'دبي', 'am': 'ዱባይ'},
    'riyadh': {'en': 'Riyadh', 'ar': 'الرياض', 'am': 'ሪያድ'},
    'cairo': {'en': 'Cairo', 'ar': 'القاهرة', 'am': 'ካርማ'},
    'remote': {'en': 'Remote', 'ar': 'عن بُعد', 'am': 'ርቀት'},
    'hybrid': {'en': 'Hybrid', 'ar': 'هجين', 'am': 'ሃይብሪድ'},
    'on_site': {'en': 'On-site', 'ar': 'في الموقع', 'am': 'በቦታ'},
  };

  @override
  void initState() {
    super.initState();
    fetchJobs();
    searchController.addListener(_filterJobs);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterJobs() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredJobs = List.from(jobs);
      } else {
        filteredJobs = jobs.where((job) {
          final name = _getJobField(job, 'name').toLowerCase();
          final company = _getJobField(job, 'company').toLowerCase();
          final location = _getJobField(job, 'location').toLowerCase();
          final occupation = _getJobField(job, 'occupation').toLowerCase();
          final description = _getJobField(job, 'description').toLowerCase();

          return name.contains(query) ||
              company.contains(query) ||
              location.contains(query) ||
              occupation.contains(query) ||
              description.contains(query);
        }).toList();
      }
      currentPage = 1;
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
        filteredJobs = List.from(jobs);
        isLoading = false;
      });

      // Debug: Print backend data structure
      _debugBackendData();
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

  String _getJobField(dynamic job, String fieldName) {
    try {
      final value = job[fieldName];
      if (value == null) return 'N/A';

      // Handle nested company data
      if (fieldName == 'company' && value is Map) {
        return value['name']?.toString() ?? 'N/A';
      }

      return value.toString();
    } catch (e) {
      return 'N/A';
    }
  }

  // Debug function to see actual backend structure
  void _debugBackendData() {
    if (jobs.isNotEmpty) {
      print('=== BACKEND DATA STRUCTURE DEBUG ===');
      print('Total jobs: ${jobs.length}');

      for (var i = 0; i < jobs.length; i++) {
        final job = jobs[i];
        print('Job ${i + 1}:');
        print('  ID: ${job['id']}');
        print('  Name: ${job['name']}');
        print('  Type: ${job['type']} (raw: ${job['type']?.runtimeType})');
        print(
            '  Occupation: ${job['occupation']} (raw: ${job['occupation']?.runtimeType})');
        print(
            '  Education: ${job['education_status']} (raw: ${job['education_status']?.runtimeType})');
        print(
            '  Location: ${job['location']} (raw: ${job['location']?.runtimeType})');
        print(
            '  Company: ${job['company']} (raw: ${job['company']?.runtimeType})');
        print(
            '  Description: ${job['description']?.toString().substring(0, min(50, job['description']?.toString().length ?? 0))}...');
        print('  Amount: ${job['amount']}');
        print('  Created At: ${job['created_at']}');
        print('  Updated At: ${job['updated_at']}');

        // Print all keys to see what's available
        print('  All keys: ${job.keys.toList()}');
        print('---');
      }
    }
  }

  int min(int a, int b) => a < b ? a : b;

  // Generic translation function
  String _translateBackendValue(String value,
      Map<String, Map<String, String>> translationMap, BuildContext context) {
    if (value == 'N/A' || value.isEmpty) return value;

    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final langCode = languageProvider.currentLang;

    // Clean the value for matching
    final cleanValue = value.trim().toLowerCase();

    // Try exact match first
    var translated = translationMap[cleanValue]?[langCode];
    if (translated != null) {
      print('✅ Translated "$value" to "$translated"');
      return translated;
    }

    // Try partial matches
    for (var key in translationMap.keys) {
      if (cleanValue.contains(key) || key.contains(cleanValue)) {
        translated = translationMap[key]?[langCode];
        if (translated != null) {
          print('✅ Translated "$value" to "$translated" (partial match)');
          return translated;
        }
      }
    }

    print('❌ No translation found for "$value"');
    return value;
  }

  String _getTranslatedJobType(String jobType, BuildContext context) {
    return _translateBackendValue(jobType, _jobTypeTranslations, context);
  }

  String _getTranslatedOccupation(String occupation, BuildContext context) {
    // First try our translation map
    var translated =
        _translateBackendValue(occupation, _occupationTranslations, context);
    if (translated != occupation) return translated;

    // Fallback to JobService if available
    try {
      final displayName = JobService.getOccupationDisplayName(occupation);
      if (displayName != occupation) {
        print('✅ Translated "$occupation" to "$displayName" (via JobService)');
        return displayName;
      }
    } catch (e) {
      print('⚠️ JobService translation failed for "$occupation": $e');
    }

    return occupation;
  }

  String _getTranslatedEducationStatus(
      String educationStatus, BuildContext context) {
    return _translateBackendValue(
        educationStatus, _educationTranslations, context);
  }

  String _getTranslatedLocation(String location, BuildContext context) {
    return _translateBackendValue(location, _locationTranslations, context);
  }

  String _getTranslatedCompany(String company, BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    if (company == 'N/A') {
      if (languageProvider.currentLang == 'ar') {
        return 'شركة غير معروفة';
      } else if (languageProvider.currentLang == 'am') {
        return 'ያልታወቀ ኩባንያ';
      } else {
        return 'Unknown Company';
      }
    }

    return company;
  }

  String _getTranslatedSalary(String amount, BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    if (amount == 'N/A') {
      if (languageProvider.currentLang == 'ar') {
        return 'الراتب غير محدد';
      } else if (languageProvider.currentLang == 'am') {
        return 'ደሞዝ አልተገለጸም';
      } else {
        return 'Salary not specified';
      }
    }

    // Handle numeric amounts
    if (amount.isNotEmpty && amount != 'N/A') {
      return '\$$amount';
    }

    return amount;
  }

  String _getTranslatedPositions(String positions, BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    if (languageProvider.currentLang == 'ar') {
      return '$positions منصب';
    } else if (languageProvider.currentLang == 'am') {
      return '$positions የስራ ቦታ';
    } else {
      return '$positions Position${positions != "1" ? "s" : ""}';
    }
  }

  String _getTranslatedDatePlaceholder(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    if (languageProvider.currentLang == 'ar') {
      return 'يوم-شهر-سنة';
    } else if (languageProvider.currentLang == 'am') {
      return 'ቀን-ወር-ዓመት';
    } else {
      return 'dd-mm-yyyy';
    }
  }

  String _formatDateForDisplay(DateTime date, BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    if (languageProvider.currentLang == 'ar' ||
        languageProvider.currentLang == 'am') {
      return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    } else {
      return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    }
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      if (searchController.text.isEmpty) {
        fetchJobs();
      }
    }
  }

  void _goToNextPage() {
    if (currentPage < _calculateTotalPages()) {
      setState(() {
        currentPage++;
      });
      if (searchController.text.isEmpty) {
        fetchJobs();
      }
    }
  }

  int _calculateTotalPages() {
    final totalItems =
        searchController.text.isEmpty ? jobs.length : filteredJobs.length;
    final totalPages = (totalItems / jobsPerPage).ceil();
    return totalPages == 0 ? 1 : totalPages;
  }

  List<dynamic> _getJobsToShow() {
    final itemsToPaginate = searchController.text.isEmpty ? jobs : filteredJobs;
    final startIndex = (currentPage - 1) * jobsPerPage;
    final endIndex =
        (startIndex + jobsPerPage).clamp(0, itemsToPaginate.length);
    return itemsToPaginate.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    final totalPages = _calculateTotalPages();
    final jobsToShow = _getJobsToShow();
    final displayJobs = searchController.text.isEmpty ? jobs : filteredJobs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: _searchBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: searchController,
                    cursorColor: _ink,
                    style: const TextStyle(fontSize: 15, color: _ink),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      prefixIcon:
                          const Icon(Icons.search, color: _hint, size: 20),
                      hintText: languageProvider.t('search_jobs'),
                      hintStyle: const TextStyle(
                        color: _hint,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const TwoLineFilterIcon(
                color: _ink,
                width: 26,
                lineThickness: 2.0,
                gap: 8,
                knobRadius: 3.0,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date Filter Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.currentLang == 'ar'
                          ? "من"
                          : languageProvider.currentLang == 'am'
                              ? "ከ"
                              : "From",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
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
                                  ? _getTranslatedDatePlaceholder(context)
                                  : _formatDateForDisplay(fromDate!, context),
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
                    Text(
                      languageProvider.currentLang == 'ar'
                          ? "إلى"
                          : languageProvider.currentLang == 'am'
                              ? "እስከ"
                              : "To",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
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
                                  ? _getTranslatedDatePlaceholder(context)
                                  : _formatDateForDisplay(toDate!, context),
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

          Text(
            languageProvider.currentLang == 'ar'
                ? "الوظائف المتاحة"
                : languageProvider.currentLang == 'am'
                    ? "የሚገኙ ስራዎች"
                    : "Available Jobs",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          else if (displayJobs.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.work_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    languageProvider.currentLang == 'ar'
                        ? "لا توجد وظائف"
                        : languageProvider.currentLang == 'am'
                            ? "ምንም ስራ አልተገኙም"
                            : "No jobs found",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          else ...[
            // Jobs list
            for (var job in jobsToShow) ...[
              jobCard(job: job, context: context),
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
                      onPressed: currentPage > 1 ? _goToPreviousPage : null,
                      child: Text(
                        languageProvider.currentLang == 'ar'
                            ? "← السابق"
                            : languageProvider.currentLang == 'am'
                                ? "← ቀዳሚ"
                                : "← Previous",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        languageProvider.currentLang == 'ar'
                            ? "صفحة $currentPage من $totalPages"
                            : languageProvider.currentLang == 'am'
                                ? "ገጽ $currentPage ከ $totalPages"
                                : "Page $currentPage of $totalPages",
                      ),
                    ),
                    TextButton(
                      onPressed:
                          currentPage < totalPages ? _goToNextPage : null,
                      child: Text(
                        languageProvider.currentLang == 'ar'
                            ? "التالي →"
                            : languageProvider.currentLang == 'am'
                                ? "ቀጣይ →"
                                : "Next →",
                      ),
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

  Widget jobCard({required dynamic job, required BuildContext context}) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    // Get the raw values for debugging
    final rawType = _getJobField(job, 'type');
    final rawOccupation = _getJobField(job, 'occupation');
    final rawEducation = _getJobField(job, 'education_status');
    final rawLocation = _getJobField(job, 'location');

    print('🎯 Rendering job card with:');
    print('  - Type: $rawType');
    print('  - Occupation: $rawOccupation');
    print('  - Education: $rawEducation');
    print('  - Location: $rawLocation');

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
                            _getTranslatedJobType(rawType, context),
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
                      _getTranslatedCompany(
                          _getJobField(job, 'company'), context),
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
                _getTranslatedLocation(rawLocation, context),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.attach_money, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _getTranslatedSalary(_getJobField(job, 'amount'), context),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.people_alt_outlined,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _getTranslatedPositions("1", context),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              if (rawOccupation != 'N/A')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getTranslatedOccupation(rawOccupation, context),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple,
                    ),
                  ),
                ),
              if (rawEducation != 'N/A')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getTranslatedEducationStatus(rawEducation, context),
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
              child: Text(
                languageProvider.currentLang == 'ar'
                    ? "عرض تفاصيل الوظيفة"
                    : languageProvider.currentLang == 'am'
                        ? "የስራ ዝርዝሮችን እይ"
                        : "View Job Details",
              ),
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

// TwoLineFilterIcon and _TwoLineFilterPainter classes remain the same...
