import 'package:flutter/material.dart';

// import your components from Component/Agent
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
  State<EmployerPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<EmployerPage> {
  int _selectedIndex = 0;

final List<Widget> _pages = const [
  DashboardPage(),
  CompanyInfoPage(),
  EmployeePage(),
  EmployeeRatingPage(), // Rating
  PromotionPage(),      // Promote
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
  Icons.trending_up,       // Promote
  Icons.swap_horiz,
  Icons.history,           // Transfer History
  Icons.import_contacts,   // Reserve History
  Icons.work,              // Jobs
  Icons.payment,
  Icons.bookmark,          // Reserve Profile
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
                            ? Colors.blue
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
                              ? Colors.blue
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
