import 'package:flutter/material.dart';
import 'package:marrir/Component/onboarding/SplashScreen/splash_screen.dart';

// Import your components from Component/Employer
import '../../Component/Employer/dashboard.dart';
import '../../Component/Employer/company_info.dart';
import '../../Component/Employer/employee.dart';
import '../../Component/Employer/promotion.dart';
import '../../Component/Employer/transfer_history.dart';
import '../../Component/Employer/reserve_profile.dart';
import '../../Component/Employer/transfer_profile.dart';
import '../../Component/Employer/payment.dart';
import '../../Component/Employer/reserve_history.dart';
import '../../Component/Employer/help.dart';
import '../../Component/Employer/employee_rating.dart';
import '../../Component/Employer/jobs.dart';

class EmployerPage extends StatefulWidget {
  const EmployerPage({super.key});

  @override
  State<EmployerPage> createState() => _EmployerPageState();
}

class _EmployerPageState extends State<EmployerPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    CompanyInfoPage(),
    EmployeePage(),
    EmployeeRatingPage(),
    PromotionPage(),
    TransferHistoryPage(),
    TransferProfilePage(),
    ReserveHistoryPage(),
    JobsPage(),
    PaymentPage(),
    ReserveProfilePage(),
    HelpPage(),
  ];

  final List<String> _menuTitles = [
    "Dashboard",
    "Company Info",
    "Employees",
    "Rating",
    "Promote",
    "Transfer History",
    "Transfer Profile",
    "Reserve History",
    "Jobs",
    "Payment",
    "Reserve Profile",
    "Help",
  ];

  final List<IconData> _menuIcons = [
    Icons.dashboard,
    Icons.business,
    Icons.people,
    Icons.star_rate,
    Icons.trending_up,
    Icons.swap_horiz,
    Icons.history,
    Icons.import_contacts,
    Icons.work,
    Icons.payment,
    Icons.bookmark,
    Icons.help_outline,
  ];

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "End Session",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(fontSize: 15, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          actionsPadding: const EdgeInsets.only(bottom: 8, right: 8, left: 8),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate back to login screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF65B2C9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Yes, End Session",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 248, 248, 248),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.person_outline,
                            size: 40, color: Colors.black87),
                        SizedBox(height: 8),
                        Text(
                          'Employer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFE5E5E5), thickness: 1),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _menuTitles.length + 1, // +1 for Logout
                  itemBuilder: (context, index) {
                    if (index < _menuTitles.length) {
                      return ListTile(
                        leading: Icon(
                          _menuIcons[index],
                          color: _selectedIndex == index
                              ? const Color(0xFF65b2c9)
                              : Colors.black54,
                        ),
                        title: Text(
                          _menuTitles[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: _selectedIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _selectedIndex == index
                                ? const Color(0xFF65b2c9)
                                : Colors.black87,
                          ),
                        ),
                        selected: _selectedIndex == index,
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                          Navigator.pop(context);
                        },
                      );
                    } else {
                      // Logout menu item like AgentPage
                      return ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.black54,
                        ),
                        title: const Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.black87,
                          ),
                        ),
                        onTap: () => _showLogoutDialog(context),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
}
