import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/AvailableJobs/available_job.dart';
import 'package:marrir/Component/Employee/CV/cv.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/employee_profile.dart';
import 'package:marrir/Component/Employee/PostedJobs/posted_job.dart';
import 'package:marrir/Component/Employee/layout/layout.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:marrir/providers/user_provider.dart';
// import 'package:marrir/Component/onboarding/SplashScreen/splash_screen.dart';
// import '../../services/api_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Component/auth/login_screen.dart'; // <-- make sure this import is correct

class EmployeePage extends StatefulWidget {
  final String token; // 👈 Add token

  const EmployeePage({super.key, required this.token}); // 👈 require token

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  int _currentIndex = 0;
  Widget? _childPage; // currently active child page

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const RecentlyPostedJobs(),
      const AvailableJob(),
      CVMain(token: widget.token), // 👈 Pass token to CVMain
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _childPage = null; // reset child when switching tabs
    });
  }

  void _openChildPage(Widget page) {
    setState(() {
      _childPage = page; // show child page in same layout
    });
  }

  @override
  Widget build(BuildContext context) {
    return EmployeeLayout(
      token: widget.token, // 👈 Pass token to EmployeeLayout
      currentIndex: _currentIndex,
      onTabSelected: _onTabSelected,
      // Hide header for ProfilePage (index 3) and CVMain (index 2)
      showHeader: !(_currentIndex == 2 || _currentIndex == 3),
      child: _childPage ??
          (_currentIndex == 3
              ? ProfilePage(onChildSelected: _openChildPage) // Profile tab
              : _pages[_currentIndex]),
    );
  }
}
