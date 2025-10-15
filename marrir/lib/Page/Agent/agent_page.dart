import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marrir/Component/Agent/promotion.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../Component/auth/login_screen.dart';

// Import your Agent components
import '../../Component/Agent/dashboard.dart';
import '../../Component/Agent/company_info.dart';
import '../../Component/Agent/agency_employee.dart';
// import '../../Component/Agent/promotion.dart';
import '../../Component/Agent/transfer.dart';
import '../../Component/Agent/reserve.dart';
import '../../Component/Agent/transfer_profile.dart';
import '../../Component/Agent/payment.dart';
import '../../Component/Agent/reserve_history.dart';
import '../../Component/Agent/help.dart';
import '../../Component/Agent/employee_rating.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class AgentPage extends StatefulWidget {
  const AgentPage({super.key});

  @override
  State<AgentPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> {
  int _selectedIndex = 0;
  String? agentName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginAndFetchProfile();
  }

  Future<void> _checkLoginAndFetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    if (token == null || token.isEmpty) {
      // No token -> redirect to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // Token exists -> fetch profile
      _fetchAgentProfile();
    }
  }

  Future<void> _fetchAgentProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token") ?? "";
      final userId = prefs.getString("user_id") ?? "";

      final data = await ApiService.getUserInfo(token: token, userId: userId);

      setState(() {
        agentName =
            "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}".trim();
        if (agentName!.isEmpty) agentName = "Agent";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        agentName = "Agent";
        isLoading = false;
      });
      print("Error fetching agent profile: $e");
    }
  }

  Widget _buildDrawerHeader() {
    final lang = Provider.of<LanguageProvider>(context);
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
                      agentName ?? "Agent",
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
    final lang = Provider.of<LanguageProvider>(context);

    const List<Widget> pages = [
      DashboardPage(),
      CompanyInfoPage(),
      AgencyEmployeePage(),
      EmployeeRatingPage(),
      AgentPromotionPage(),
      TransferHistoryPage(),
      ReserveProfilePage(),
      TransferProfilePage(),
      AgentPaymentPage(),
      ReserveHistoryPage(),
      HelpPage(),
    ];

    final List<String> menuTitles = [
      lang.t('dashboard'),
      lang.t('company_info'),
      lang.t('agency_employee'),
      lang.t('employee_rating'),
      lang.t('promotion'),
      lang.t('transfer'),
      lang.t('reserve'),
      lang.t('transfer_profile'),
      lang.t('payment'),
      lang.t('reserve_history'),
      lang.t('help'),
    ];

    final List<IconData> menuIcons = [
      Icons.dashboard,
      Icons.business,
      Icons.people,
      Icons.star_rate,
      Icons.campaign,
      Icons.swap_horiz,
      Icons.book_online,
      Icons.person_search,
      Icons.payment,
      Icons.history,
      Icons.help_outline,
    ];
    return WillPopScope(
      onWillPop: () async {
        // Back button closes app if logged in
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString("access_token");

        if (token != null && token.isNotEmpty) {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        } else {
          // Logged out -> go to LoginScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
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
            PopupMenuButton<String>(
              tooltip: "Select Language",
              icon: const Icon(Icons.translate, color: Colors.purple),
              onSelected: (value) {
                Provider.of<LanguageProvider>(context, listen: false)
                    .changeLanguage(value);
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: "en", child: Text("English")),
                const PopupMenuItem(value: "ar", child: Text("العربية")),
                const PopupMenuItem(value: "am", child: Text("አማርኛ")),
              ],
            ),
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
                    itemCount: menuTitles.length + 1,
                    itemBuilder: (context, index) {
                      if (index < menuTitles.length) {
                        return ListTile(
                          leading: Icon(
                            menuIcons[index],
                            color: _selectedIndex == index
                                ? const Color(0xFF65b2c9)
                                : Colors.black54,
                          ),
                          title: Text(
                            menuTitles[index],
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
                          leading:
                              const Icon(Icons.logout, color: Colors.black54),
                          title: Text(
                            lang.t('logout'),
                            style: const TextStyle(
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
                                  title: Text(
                                    lang.t('end_session'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    lang.t('logout_confirmation'),
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        final userProvider =
                                            Provider.of<UserProvider>(context,
                                                listen: false);
                                        await userProvider.logout();

                                        Navigator.of(context).pop();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(lang.t('yes')),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text(lang.t('cancel')),
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
          children: pages,
        ),
      ),
    );
  }
}
