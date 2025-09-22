import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String firstName = "";
  String lastName = "";
  String createdAt = "";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token") ?? "";
      final userId = prefs.getString("user_id") ?? "";

      if (token.isEmpty || userId.isEmpty) return;

      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/v1/dashboard/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
       body: jsonEncode({
    "id": userId,   
  }),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);

        if (res["error"] == false && res["data"] != null) {
          setState(() {
            firstName = res["data"]["firstName"] ?? "";
            lastName = res["data"]["lastName"] ?? "";
            createdAt = res["data"]["createdAt"] ?? "";
          });
        } else {
          debugPrint("Error fetching user info: ${res['message'] ?? 'Unknown error'}");
        }
      } else {
        debugPrint("Server error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Failed to fetch user info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
              border: Border.all(color: const Color.fromARGB(255, 220, 220, 220)),
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
                    firstName.isNotEmpty ? firstName[0] : "M",
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
                      "Hi, ${firstName.isNotEmpty ? '$firstName $lastName' : 'Agency Firm Name'}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Date Created: ${createdAt.isNotEmpty ? createdAt : 'January 15, 2024'}",
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Dashboard Overview",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Chip(
                label: Text("This Month"),
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
              _buildStatCard("Profile views", "0", "Count - 0%"),
              _buildStatCard("Job count", "0", "Count - 0%"),
              _buildStatCard("Completed profiles male", "0", "Count - 0%"),
              _buildStatCard("Completed profiles female", "0", "Count - 0%"),
              _buildStatCard("Booked Profiles", "0", "Count - 0%"),
              _buildStatCard("Profile transfers", "0", "Count - 0%"),
              _buildStatCard("Job count", "0", "Count - 0%"),
              _buildStatCard("Transfer count", "0", "Count - 0%"),
            ],
          ),
          const SizedBox(height: 20),

          // ==== COMPANY REGISTRATION ====
          const Text(
            "Company Registration",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Document Required",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildProgressCard(
                  "Section 1",
                  "Company Information Progress",
                  0.45,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressCard(
                  "Section 2",
                  "Company License Progress",
                  0.30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==== Helper Widget for Overview Cards ====
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
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ==== Helper Widget for Progress Cards ====
  static Widget _buildProgressCard(String section, String title, double progress) {
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
          Text(
            section,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 9,
            width: 150,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE5E5E5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF65b2c9),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "${(progress * 100).toInt()}% Complete",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF65b2c9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
