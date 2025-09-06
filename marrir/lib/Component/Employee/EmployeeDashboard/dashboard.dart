import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EmployeePage()),
            );
          },
        ),
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      // Body
      body: SingleChildScrollView(
        // padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header with Gradient
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
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Text(
                      "JD",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(142, 198, 214, 1),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hanan N",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Created: March 15, 2024",
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CV & Process Cards
            Row(
              children: [
                Expanded(
                  child: _buildProgressCard(
                    icon: Icons.description_outlined,
                    title: "CV",
                    subtitle: "0/8 sections completed",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProgressCard(
                    icon: Icons.settings_outlined,
                    title: "Process",
                    subtitle: "0/5 sections completed",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Profile Statistics
            const Text(
              "Profile Statistics",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: const [
                _StatCard(title: "Profile Views", value: "0", percent: "+0%"),
                _StatCard(
                  title: "Job Application Count",
                  value: "0",
                  percent: "+0%",
                ),
                _StatCard(title: "Transfer Count", value: "0", percent: "+0%"),
                _StatCard(title: "Saved Jobs", value: "0", percent: "+0%"),
              ],
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profile tab active (matches screenshot)
        selectedItemColor: const Color.fromRGBO(142, 198, 214, 1),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: "Job"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: "Saved",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // Progress Card
  Widget _buildProgressCard({
    required IconData icon,
    required String title,
    required String subtitle,
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
          Icon(icon, size: 26, color: Colors.grey.shade700),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.0,
            minHeight: 6,
            color: const Color.fromRGBO(142, 198, 214, 1),
            backgroundColor: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 4),
          const Text(
            "0% Complete",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
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
