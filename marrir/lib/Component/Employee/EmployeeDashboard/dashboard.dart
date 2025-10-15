import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/user.dart';
import 'package:marrir/services/Employee/dashboard_service.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String employeeName = "Loading...";
  String employeeInitials = "JD";
  Map<String, dynamic> cvProgress = {};
  Map<String, dynamic> processProgress = {};
  Map<String, dynamic> errors = {};
  bool isLoading = true;
  bool hasPartialData = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadEmployeeName();
  }

  Future<void> _loadDashboardData() async {
    try {
      final data = await EmployeeDashboardService.getDashboardData();

      setState(() {
        cvProgress = data['cv_progress'] ?? {};
        processProgress = data['process_progress'] ?? {};
        errors = data['errors'] ?? {};

        // Check if we have at least some data
        hasPartialData = cvProgress.isNotEmpty || processProgress.isNotEmpty;
        isLoading = false;
      });

      // Show error messages if any
      if (errors.isNotEmpty) {
        final languageProvider =
            Provider.of<LanguageProvider>(context, listen: false);
        errors.forEach((key, error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        hasPartialData = false;
      });

      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${_getTranslatedFailedToLoad(languageProvider)}: $e')),
      );
    }
  }

  Future<void> _loadEmployeeName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");
    String? email = prefs.getString("user_email");

    if (token != null && email != null) {
      try {
        final userData = await ApiService.getUserInfo(
          email: email,
          Token: token,
        );

        setState(() {
          final fullName =
              "${userData["first_name"] ?? ""} ${userData["last_name"] ?? ""}"
                  .trim();
          employeeName = fullName.isNotEmpty ? fullName : "Unknown";
          employeeInitials = _getInitials(employeeName);
        });
      } catch (e) {
        setState(() {
          employeeName = "Unknown";
          employeeInitials = "U";
        });
      }
    } else {
      setState(() {
        employeeName = "Unknown";
        employeeInitials = "U";
      });
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(" ");
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : "?";
  }

  // Helper methods to extract progress data
  int _getCVCompletedSections() {
    if (cvProgress.isEmpty) return 0;

    final completed = [
      cvProgress['id_progress'] ?? 0,
      cvProgress['personal_info_progress'] ?? 0,
      cvProgress['address_progress'] ?? 0,
      cvProgress['education_progress'] ?? 0,
      cvProgress['photo_and_language_progress'] ?? 0,
      cvProgress['experience_progress'] ?? 0,
      cvProgress['reference_progress'] ?? 0,
      cvProgress['contact_progress'] ?? 0,
    ].where((progress) => progress >= 100).length;

    return completed;
  }

  int _getProcessCompletedSections() {
    if (processProgress.isEmpty) return 0;

    final completed = [
      processProgress['acceptance_of_application_progress'] ?? 0,
      processProgress['signing_of_contract_progress'] ?? 0,
      processProgress['passport_progress'] ?? 0,
      processProgress['insurance_progress'] ?? 0,
      processProgress['medical_report_progress'] ?? 0,
      processProgress['certificate_of_freedom_progress'] ?? 0,
      processProgress['coc_progress'] ?? 0,
      processProgress['enjaz_slip_to_agents_progress'] ?? 0,
      processProgress['enjaz_slip_for_recruitment_progress'] ?? 0,
      processProgress['worker_file_to_embassy_progress'] ?? 0,
      processProgress['visa_progress'] ?? 0,
      processProgress['worker_file_in_labor_office_progress'] ?? 0,
      processProgress['receive_travel_authorization_code_progress'] ?? 0,
      processProgress['molsa_letter_progress'] ?? 0,
      processProgress['ticket_progress'] ?? 0,
      processProgress['arrive_progress'] ?? 0,
    ].where((progress) => progress >= 100).length;

    return completed;
  }

  double _getCVOverallProgress() {
    if (cvProgress.isEmpty) return 0.0;

    final progressValues = [
      cvProgress['id_progress'],
      cvProgress['personal_info_progress'],
      cvProgress['address_progress'],
      cvProgress['education_progress'],
      cvProgress['photo_and_language_progress'],
      cvProgress['experience_progress'],
      cvProgress['reference_progress'],
      cvProgress['contact_progress'],
    ].map((e) => (e != null ? e.toDouble() : 0.0)).toList();

    final total = progressValues.fold(0.0, (sum, value) => sum + value);
    return progressValues.isNotEmpty
        ? total / progressValues.length / 100
        : 0.0;
  }

  double _getProcessOverallProgress() {
    if (processProgress.isEmpty) return 0.0;

    final progressValues = [
      processProgress['acceptance_of_application_progress'],
      processProgress['signing_of_contract_progress'],
      processProgress['passport_progress'],
      processProgress['insurance_progress'],
      processProgress['medical_report_progress'],
      processProgress['certificate_of_freedom_progress'],
      processProgress['coc_progress'],
      processProgress['enjaz_slip_to_agents_progress'],
      processProgress['enjaz_slip_for_recruitment_progress'],
      processProgress['worker_file_to_embassy_progress'],
      processProgress['visa_progress'],
      processProgress['worker_file_in_labor_office_progress'],
      processProgress['receive_travel_authorization_code_progress'],
      processProgress['molsa_letter_progress'],
      processProgress['ticket_progress'],
      processProgress['arrive_progress'],
    ].map((e) => (e != null ? e.toDouble() : 0.0)).toList();

    final total = progressValues.fold(0.0, (sum, value) => sum + value);
    return progressValues.isNotEmpty
        ? total / progressValues.length / 100
        : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(_getTranslatedLoading(languageProvider)),
            ],
          ),
        ),
      );
    }

    if (!hasPartialData && errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${_getTranslatedError(languageProvider)}: $errorMessage'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadDashboardData,
                child: Text(_getTranslatedRetry(languageProvider)),
              ),
            ],
          ),
        ),
      );
    }

    final cvCompleted = _getCVCompletedSections();
    final processCompleted = _getProcessCompletedSections();
    final cvOverallProgress = _getCVOverallProgress();
    final processOverallProgress = _getProcessOverallProgress();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? token = prefs.getString("access_token");

            if (token != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeePage(token: token),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text(_getTranslatedTokenNotFound(languageProvider))),
              );
            }
          },
        ),
        title: Text(
          _getTranslatedDashboard(languageProvider),
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color.fromRGBO(142, 198, 214, 1), Color(0xFFEAF6FB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Text(
                      employeeInitials,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(142, 198, 214, 1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employeeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTranslatedCreatedDate(languageProvider),
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Show error messages if any
            if (errors.isNotEmpty) ...[
              ...errors.entries.map((error) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      error.value.toString(),
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  )),
              const SizedBox(height: 10),
            ],

            // CV & Process Cards
            Row(
              children: [
                Expanded(
                  child: _buildProgressCard(
                    icon: Icons.description_outlined,
                    title: _getTranslatedCV(languageProvider),
                    subtitle: cvProgress.isNotEmpty
                        ? "$cvCompleted/8 ${_getTranslatedSectionsCompleted(languageProvider)}"
                        : _getTranslatedDataNotAvailable(languageProvider),
                    progress: cvOverallProgress,
                    enabled: cvProgress.isNotEmpty,
                    languageProvider: languageProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProgressCard(
                    icon: Icons.settings_outlined,
                    title: _getTranslatedProcess(languageProvider),
                    subtitle: processProgress.isNotEmpty
                        ? "$processCompleted/16 ${_getTranslatedSectionsCompleted(languageProvider)}"
                        : _getTranslatedDataNotAvailable(languageProvider),
                    progress: processOverallProgress,
                    enabled: processProgress.isNotEmpty,
                    languageProvider: languageProvider,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Profile Statistics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _getTranslatedProfileStatistics(languageProvider),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _StatCard(
                    title: _getTranslatedProfileViews(languageProvider),
                    value: "0",
                    percent: "+0%",
                  ),
                  _StatCard(
                    title: _getTranslatedJobApplicationCount(languageProvider),
                    value: "0",
                    percent: "+0%",
                  ),
                  _StatCard(
                    title: _getTranslatedTransferCount(languageProvider),
                    value: "0",
                    percent: "+0%",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Progress Card with enabled state
  Widget _buildProgressCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required bool enabled,
    required LanguageProvider languageProvider,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 26,
              color: enabled ? Colors.grey.shade700 : Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
                fontSize: 12,
                color: enabled ? Colors.grey.shade600 : Colors.grey.shade400),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress.isNaN ? 0.0 : progress,
            minHeight: 6,
            color:
                enabled ? const Color.fromRGBO(142, 198, 214, 1) : Colors.grey,
            backgroundColor: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 4),
          Text(
            enabled
                ? "${(progress * 100).toStringAsFixed(0)}% ${_getTranslatedComplete(languageProvider)}"
                : _getTranslatedNotAvailable(languageProvider),
            style: TextStyle(
                fontSize: 12,
                color: enabled ? Colors.grey : Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedLoading(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "جاري التحميل...";
    if (lang == 'am') return "በመጫን ላይ...";
    return "Loading...";
  }

  String _getTranslatedFailedToLoad(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "فشل تحميل لوحة التحكم";
    if (lang == 'am') return "ዳሽቦርድ መጫን አልተሳካም";
    return "Failed to load dashboard";
  }

  String _getTranslatedError(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "خطأ";
    if (lang == 'am') return "ስህተት";
    return "Error";
  }

  String _getTranslatedRetry(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إعادة المحاولة";
    if (lang == 'am') return "እንደገና ሞክር";
    return "Retry";
  }

  String _getTranslatedTokenNotFound(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الرمز غير موجود، يرجى تسجيل الدخول مرة أخرى";
    if (lang == 'am') return "ቶከን አልተገኘም፣ እባክዎ እንደገና ይግቡ";
    return "Token not found, please login again";
  }

  String _getTranslatedDashboard(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "لوحة التحكم";
    if (lang == 'am') return "ዳሽቦርድ";
    return "Dashboard";
  }

  String _getTranslatedCreatedDate(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم الإنشاء: ١٥ مارس ٢٠٢٤";
    if (lang == 'am') return "የተፈጠረው: ማርች 15, 2024";
    return "Created: March 15, 2024";
  }

  String _getTranslatedCV(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "السيرة الذاتية";
    if (lang == 'am') return "ሲቪ";
    return "CV";
  }

  String _getTranslatedProcess(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "العملية";
    if (lang == 'am') return "ሂደት";
    return "Process";
  }

  String _getTranslatedSectionsCompleted(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الأقسام المكتملة";
    if (lang == 'am') return "የተጠናቀቁ ክፍሎች";
    return "sections completed";
  }

  String _getTranslatedDataNotAvailable(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "البيانات غير متاحة";
    if (lang == 'am') return "ውሂብ አይገኝም";
    return "Data not available";
  }

  String _getTranslatedComplete(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "مكتمل";
    if (lang == 'am') return "ተጠናቋል";
    return "Complete";
  }

  String _getTranslatedNotAvailable(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "غير متاح";
    if (lang == 'am') return "አይገኝም";
    return "N/A";
  }

  String _getTranslatedProfileStatistics(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إحصائيات الملف الشخصي";
    if (lang == 'am') return "የመገለጫ ስታቲስቲክስ";
    return "Profile Statistics";
  }

  String _getTranslatedProfileViews(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "مشاهدات الملف الشخصي";
    if (lang == 'am') return "የመገለጫ እይታዎች";
    return "Profile Views";
  }

  String _getTranslatedJobApplicationCount(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "عدد طلبات العمل";
    if (lang == 'am') return "የስራ ማመልከቻ ብዛት";
    return "Job Application Count";
  }

  String _getTranslatedTransferCount(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "عدد التحويلات";
    if (lang == 'am') return "የሽያጭ ብዛት";
    return "Transfer Count";
  }
}

// Statistics Card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String percent;

  const _StatCard({
    required this.title,
    required this.value,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            percent,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
