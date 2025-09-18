import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/providers/user_provider.dart';
import 'package:marrir/Component/auth/login_screen.dart';
import 'package:marrir/Component/onboarding/SplashScreen/splash_screen.dart';
import '../../services/api_service.dart';

// Import Employer components
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
  String? employerName;
  bool isLoading = true;

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

  @override
  void initState() {
    super.initState();
    _fetchEmployerProfile();
  }

  Future<void> _fetchEmployerProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token") ?? "";
      final userId = prefs.getString("user_id") ?? "";

      final data = await ApiService.getUserInfo(token: token, userId: userId);

      setState(() {
        employerName =
            "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}".trim();
        if (employerName!.isEmpty) employerName = "Employer";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        employerName = "Employer";
        isLoading = false;
      });
      print("Error fetching employer profile: $e");
    }
  }

  Widget _buildDrawerHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.person_outline, size: 40, color: Colors.black87),
              const SizedBox(height: 8),
              isLoading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : Text(
                      employerName ?? "Employer",
                      style: const TextStyle(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString("access_token");

        if (token != null && token.isNotEmpty) {
          // Logged-in -> close app
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        } else {
          // Logged-out -> go to SplashScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
          );
        }
        return false;
      },
      child: Scaffold(
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
                _buildDrawerHeader(),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFE5E5E5), thickness: 1),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuTitles.length + 1,
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
                        return ListTile(
                          leading: const Icon(Icons.logout, color: Colors.black54),
                          title: const Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black87,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                    "End Session",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: const Text(
                                    "Are you sure you want to log out?",
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                                        await userProvider.logout();

                                        Navigator.of(context).pop();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const LoginScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text("Yes"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text("Cancel"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
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
      ),
    );
  }
}
