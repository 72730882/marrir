import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marrir/services/Employer/job_service.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';
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
  List<dynamic> filteredJobs = [];
  TextEditingController searchController = TextEditingController();

  static const _hint = Color(0xFF9BA0A6);
  static const _searchBg = Color(0xFFF2F2F7);
  static const _ink = Color(0xFF111111);

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
    searchController.addListener(_filterJobs);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _filterJobs() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredJobs = List.from(recentJobs);
      } else {
        filteredJobs = recentJobs.where((job) {
          final name = _getJobField(job, 'name').toLowerCase();
          final company = _getJobField(job, 'company').toLowerCase();
          final location = _getJobField(job, 'location').toLowerCase();
          final occupation = _getJobField(job, 'occupation').toLowerCase();
          final description = _getJobField(job, 'description').toLowerCase();
          final jobType = _getJobField(job, 'type').toLowerCase();

          return name.contains(query) ||
              company.contains(query) ||
              location.contains(query) ||
              occupation.contains(query) ||
              description.contains(query) ||
              jobType.contains(query);
        }).toList();
      }
    });
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
        filteredJobs = List.from(recentJobs);
        isLoading = false;
      });
    } on DioException catch (e) {
      final errorMsg = ApiErrorHandler.handleDioError(e);
      setState(() {
        isLoading = false;
        errorMessage = errorMsg;
        recentJobs = [];
        filteredJobs = [];
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Unexpected error: $e';
        recentJobs = [];
        filteredJobs = [];
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

  String _getTimeAgo(DateTime date, BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (languageProvider.currentLang == 'ar') {
      // Arabic translation
      if (difference.inMinutes < 60) {
        return 'قبل ${difference.inMinutes} دقيقة';
      } else if (difference.inHours < 24) {
        return 'قبل ${difference.inHours} ساعة';
      } else {
        return 'قبل ${difference.inDays} يوم';
      }
    } else if (languageProvider.currentLang == 'am') {
      // Amharic translation
      if (difference.inMinutes < 60) {
        return 'ከ${difference.inMinutes} ደቂቃ በፊት';
      } else if (difference.inHours < 24) {
        return 'ከ${difference.inHours} ሰዓት በፊት';
      } else {
        return 'ከ${difference.inDays} ቀን በፊት';
      }
    } else {
      // English (default)
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    }
  }

  String _getTranslatedWorkplace(String location, BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isRemote = location.toLowerCase().contains('remote');

    if (languageProvider.currentLang == 'ar') {
      return isRemote ? 'عن بُعد' : 'في الموقع';
    } else if (languageProvider.currentLang == 'am') {
      return isRemote ? 'ርቀት' : 'በቦታ';
    } else {
      return isRemote ? 'Remote' : 'On-Site';
    }
  }

  String _getTranslatedSalary(String amount, BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final salaryText = amount != 'N/A' ? '\$$amount' : '';

    if (languageProvider.currentLang == 'ar') {
      return amount != 'N/A' ? '\$$amount' : 'الراتب غير محدد';
    } else if (languageProvider.currentLang == 'am') {
      return amount != 'N/A' ? '\$$amount' : 'ደሞዝ አልተገለጸም';
    } else {
      return amount != 'N/A' ? '\$$amount' : 'Salary not specified';
    }
  }

  String _getTranslatedCompany(String company, BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    if (languageProvider.currentLang == 'ar') {
      return company != 'N/A' ? company : 'شركة غير معروفة';
    } else if (languageProvider.currentLang == 'am') {
      return company != 'N/A' ? company : 'ያልታወቀ ኩባንያ';
    } else {
      return company != 'N/A' ? company : 'Unknown Company';
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
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final displayJobs = filteredJobs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Search Bar
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
                    context,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Section title
          Text(
            languageProvider.currentLang == 'ar'
                ? "الوظائف المنشورة حديثاً (آخر 24 ساعة)"
                : languageProvider.currentLang == 'am'
                    ? "በቅርብ ጊዜ የቀረቡ ስራዎች (ባለፈው 24 ሰዓት)"
                    : "Recently Posted Jobs (Last 24h)",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    searchController.text.isEmpty
                        ? (languageProvider.currentLang == 'ar'
                            ? "لا توجد وظائف حديثة"
                            : languageProvider.currentLang == 'am'
                                ? "ቅርብ ጊዜ የቀረቡ ስራዎች አልተገኙም"
                                : "No recent jobs found")
                        : (languageProvider.currentLang == 'ar'
                            ? "لا توجد وظائف مطابقة"
                            : languageProvider.currentLang == 'am'
                                ? "የሚጣጣሙ ስራዎች አልተገኙም"
                                : "No matching jobs found"),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    searchController.text.isEmpty
                        ? (languageProvider.currentLang == 'ar'
                            ? "الوظائف المنشورة في آخر 24 ساعة ستظهر هنا"
                            : languageProvider.currentLang == 'am'
                                ? "ባለፈው 24 ሰዓት ውስጥ የቀረቡ ስራዎች እዚህ ይታያሉ"
                                : "Jobs posted in the last 24 hours will appear here")
                        : (languageProvider.currentLang == 'ar'
                            ? "حاول تعديل مصطلحات البحث الخاصة بك"
                            : languageProvider.currentLang == 'am'
                                ? "የፍለጋ ቃላትዎን ይለውጡ"
                                : "Try adjusting your search terms"),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            // Job cards
            ...displayJobs.map(
              (job) => jobCard(job: job, context: context),
            ),
        ],
      ),
    );
  }

  // Reusable top card widget
  Widget buildTopCard(
      String title, String description, Color color, BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    // Translate top card content based on current language
    String translatedTitle = title;
    String translatedDescription = description;

    if (languageProvider.currentLang == 'ar') {
      if (title == 'Build Your CV') translatedTitle = 'بناء سيرتك الذاتية';
      if (title == 'Search Jobs') translatedTitle = 'البحث عن وظائف';
      if (title == 'Upgrade Skills') translatedTitle = 'تطوير المهارات';

      if (description == 'Generate a professional CV using your profile data.')
        translatedDescription =
            'قم بإنشاء سيرة ذاتية احترافية باستخدام بيانات ملفك الشخصي.';
      if (description == 'Find jobs that match your skills and location.')
        translatedDescription =
            'ابحث عن الوظائف التي تتطابق مع مهاراتك وموقعك.';
      if (description ==
          'Learn and improve your skills for better opportunities.')
        translatedDescription = 'تعلم وحسن مهاراتك للحصول على فرص أفضل.';
    } else if (languageProvider.currentLang == 'am') {
      if (title == 'Build Your CV') translatedTitle = 'CV ይገንቡ';
      if (title == 'Search Jobs') translatedTitle = 'ስራዎችን ፈልግ';
      if (title == 'Upgrade Skills') translatedTitle = 'ችሎታዎችን አሻሽል';

      if (description == 'Generate a professional CV using your profile data.')
        translatedDescription = 'የግል መረጃዎን በመጠቀም ብቃት ያለው CV ይፍጠሩ።';
      if (description == 'Find jobs that match your skills and location.')
        translatedDescription = 'ከችሎታዎችዎ እና ከአካባቢዎ ጋር የሚጣጣሙ ስራዎችን ያግኙ።';
      if (description ==
          'Learn and improve your skills for better opportunities.')
        translatedDescription = 'ለተሻለ እድሎች ችሎታዎችዎን ይማሩ እና ያሻሽሉ።';
    }

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
            translatedTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            translatedDescription,
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
  Widget jobCard({required dynamic job, required BuildContext context}) {
    final title = _getJobField(job, 'name');
    final company =
        _getTranslatedCompany(_getJobField(job, 'company'), context);
    final location = _getJobField(job, 'location');
    final jobType = _getJobField(job, 'type');
    final salary = _getTranslatedSalary(_getJobField(job, 'amount'), context);

    final createdAt = _parseJobDate(job);
    final postedTime = createdAt != null
        ? _getTimeAgo(createdAt, context)
        : (Provider.of<LanguageProvider>(context, listen: false).currentLang ==
                'ar'
            ? 'مؤخراً'
            : Provider.of<LanguageProvider>(context, listen: false)
                        .currentLang ==
                    'am'
                ? 'በቅርብ ጊዜ'
                : 'Recently');

    final workplace = _getTranslatedWorkplace(location, context);

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
                      : (Provider.of<LanguageProvider>(context, listen: false)
                                  .currentLang ==
                              'ar'
                          ? 'عام'
                          : Provider.of<LanguageProvider>(context,
                                          listen: false)
                                      .currentLang ==
                                  'am'
                              ? 'አጠቃላይ'
                              : 'General'),
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

class TwoLineFilterIcon extends StatelessWidget {
  final Color color;
  final double width;
  final double lineThickness;
  final double gap;
  final double knobRadius;

  const TwoLineFilterIcon({
    super.key,
    required this.color,
    this.width = 26,
    this.lineThickness = 2.0,
    this.gap = 8.0,
    this.knobRadius = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final height = lineThickness * 2 + gap;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _TwoLineFilterPainter(
          color: color,
          t: lineThickness,
          gap: gap,
          knobR: knobRadius,
        ),
      ),
    );
  }
}

class _TwoLineFilterPainter extends CustomPainter {
  final Color color;
  final double t;
  final double gap;
  final double knobR;

  _TwoLineFilterPainter({
    required this.color,
    required this.t,
    required this.gap,
    required this.knobR,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = color
      ..strokeWidth = t
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final yTop = t / 2;
    final yBot = yTop + t + gap;

    canvas.drawLine(Offset(0, yTop), Offset(size.width, yTop), paintLine);
    canvas.drawLine(Offset(0, yBot), Offset(size.width, yBot), paintLine);

    canvas.drawCircle(Offset(size.width - knobR - 1, yTop), knobR, paintFill);
    canvas.drawCircle(Offset(knobR + 1, yBot), knobR, paintFill);
  }

  @override
  bool shouldRepaint(covariant _TwoLineFilterPainter oldDelegate) {
    return color != oldDelegate.color ||
        t != oldDelegate.t ||
        gap != oldDelegate.gap ||
        knobR != oldDelegate.knobR;
  }
}
