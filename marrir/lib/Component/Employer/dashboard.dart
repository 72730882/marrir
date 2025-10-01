import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_info_provider.dart';
import '../../services/api_service.dart';
import 'package:marrir/Component/Language/language_provider.dart'; // Import LanguageProvider

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String createdAt = "";
  Map<String, dynamic>? dashboardStats;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  double section1Progress = 0.0; // 0 to 1
  double section2Progress = 0.0; // 0 to 1 (if needed)

  Future<void> _loadDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token") ?? "";
      final userId = prefs.getString("user_id") ?? "";
      final email = prefs.getString("email") ?? "";
      if (token.isEmpty || userId.isEmpty) return;

      final userInfo =
          await ApiService.getUserInfo(token: token, userId: userId);
      final firstName = userInfo["first_name"] ?? "";
      final lastName = userInfo["last_name"] ?? "";
      final createdAtDate = userInfo["created_at"] ?? "";

      if (!mounted) return;
      setState(() => createdAt = createdAtDate);
      Provider.of<UserInfoProvider>(context, listen: false)
          .setUserName(firstName: firstName, lastName: lastName);

      final stats =
          await ApiService.getDashboardInfo(token: token, userId: userId);
      if (!mounted) return;
      setState(() => dashboardStats = stats["data"] ?? {});

      final progressData = await ApiService.getCompanyInfoProgress(
        token: token,
        userId: userId,
        email: email,
      );

      if (!mounted) return;
      setState(() {
        section1Progress =
            (progressData["data"]?["company_info_progress"] ?? 0) / 100;
        section2Progress =
            (progressData["data"]?["company_document_progress"] ?? 0) / 100;
      });
    } catch (e) {
      debugPrint("Failed to load dashboard: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context); // <-- LanguageProvider
    final userInfoProvider = Provider.of<UserInfoProvider>(context);
    final userName = userInfoProvider.fullName ?? lang.t("agency_firm_name");
    final initials = (userInfoProvider.fullName ?? "AF")
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : "")
        .join();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==== PROFILE HEADER ====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border.all(color: const Color.fromARGB(255, 220, 220, 220)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFDDDDDD),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${lang.t("hi")}, $userName",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      " ${createdAt.isNotEmpty ? createdAt : 'January 15, 2024'}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ==== DASHBOARD OVERVIEW HEADER ====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lang.t("dashboard_overview"),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Chip(
                label: Text(lang.t("this_month")),
                backgroundColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ==== DASHBOARD CARDS ====
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                lang.t("profile_views"),
                "${dashboardStats?['profile_view']?['value'] ?? 0}",
                "${lang.t("change")}: ${dashboardStats?['profile_view']?['change'] ?? 0}%",
              ),
              _buildStatCard(
                lang.t("jobs_count"),
                "${dashboardStats?['jobs_posted_count']?['value'] ?? 0}",
                "${lang.t("change")}: ${dashboardStats?['jobs_posted_count']?['change'] ?? 0}%",
              ),
              _buildStatCard(
                lang.t("completed_profiles_male"),
                "${dashboardStats?['male_employees_count']?['value'] ?? 0}",
                "${lang.t("change")}: ${dashboardStats?['male_employees_count']?['change'] ?? 0}%",
              ),
              _buildStatCard(
                lang.t("completed_profiles_female"),
                "${dashboardStats?['female_employees_count']?['value'] ?? 0}",
                "${lang.t("change")}: ${dashboardStats?['female_employees_count']?['change'] ?? 0}%",
              ),
              _buildStatCard(
                lang.t("booked_profiles"),
                "${dashboardStats?['employees_count']?['value'] ?? 0}",
                "${lang.t("change")}: ${dashboardStats?['employees_count']?['change'] ?? 0}%",
              ),
              _buildStatCard(lang.t("profile_transfers"), "0", "${lang.t("count")} - 0%"),
              _buildStatCard(lang.t("job_count"), "0", "${lang.t("count")} - 0%"),
              _buildStatCard(
                lang.t("transfer_count"),
                "${dashboardStats?['transfers_count']?['value'] ?? 0}",
                "${lang.t("change")}: ${dashboardStats?['transfers_count']?['change'] ?? 0}%",
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ==== COMPANY REGISTRATION ====
          Text(
            lang.t("company_registration"),
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lang.t("document_required"),
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProgressCard(
                  lang.t("section_1"),
                  lang.t("company_information_progress"),
                  section1Progress,
                ),
              ),
              Expanded(
                child: _buildProgressCard(
                  lang.t("section_2"),
                  lang.t("company_license_progress"),
                  section2Progress,
                ),
              ),
            ],
          ),
          const Divider(
            color: Colors.grey,
            thickness: 0.1,
            height: 0.8,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  static Widget _buildStatCard(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            spreadRadius: 8,
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  static Widget _buildProgressCard(
      String section, String title, double progress) {
    return Builder(builder: (context) {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section,
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 12),
            SizedBox(
              height: 9,
              width: double.infinity,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFE5E5E5),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF65b2c9)),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 15),
            Text("${(progress * 100).toInt()}% ${lang.t("complete")}",
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF65b2c9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(lang.t("continue"),
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ],
        ),
      );
    });
  }
}
