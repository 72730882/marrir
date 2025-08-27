import 'package:flutter/material.dart';

// import your components from Component/Agent
import '../../Component/Recruitment/dashboard.dart';
import '../../Component/Recruitment/company_info.dart';
import '../../Component/Recruitment/employee.dart';
import '../../Component/Recruitment/promotion.dart';
import '../../Component/Recruitment/transfer.dart';
import '../../Component/Recruitment/reserve.dart';
import '../../Component/Recruitment/transfer_profile.dart';
import '../../Component/Recruitment/payment.dart';
import '../../Component/Recruitment/reserve_history.dart';
import '../../Component/Recruitment/help.dart';
import '../../Component/Recruitment/employee_rating.dart';

class RecruitmentPage extends StatefulWidget {
  const RecruitmentPage({super.key});

  @override
  State<RecruitmentPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<RecruitmentPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    CompanyInfoPage(),
    EmployeePage(),
    EmployeeRatingPage(), // <-- match order with menu
    PromotionPage(),
    TransferPage(),
    ReservePage(),
    TransferProfilePage(),
    PaymentPage(),
    ReserveHistoryPage(),
    HelpPage(),
  ];

  final List<String> _menuTitles = [
    "Dashboard",
    "Company Info",
    "Recruiter Employee",
    "Employee Rating", // <-- matches with _pages
    "Promotion",
    "Transfer",
    "Reserve",
    "Transfer Profile",
    "Payment",
    "Reserve History",
    "Help",
  ];

  final List<IconData> _menuIcons = [
    Icons.dashboard,
    Icons.business,
    Icons.people,
    Icons.star_rate, // <-- NEW icon for Employee Rating
    Icons.campaign,
    Icons.swap_horiz,
    Icons.book_online,
    Icons.person_search,
    Icons.payment,
    Icons.history,
    Icons.help_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Optional: match your Layout’s background
      appBar: AppBar(
        backgroundColor:
            Colors.white, // Optional: match your Layout’s background
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu), // ☰ sidebar toggle
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none), // 🔔 notification
            onPressed: () {
              // handle notification click
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor:
            Colors.white, // Optional: match your Layout’s background
        child: SafeArea(
          child: Column(
            children: [
              // ===== Custom Drawer Header =====
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile info
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.person_outline,
                            size: 40, color: Colors.black87),
                        SizedBox(height: 8),
                        Text(
                          'Recruitment Firm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Close button
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

              // ===== Sidebar Menu =====
              Expanded(
                child: ListView.builder(
                  itemCount: _menuTitles.length,
                  itemBuilder: (context, index) {
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
                        Navigator.pop(context); // close drawer
                      },
                    );
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
