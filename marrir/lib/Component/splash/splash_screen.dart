import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../providers/user_provider.dart';
import '../../Page/Agent/agent_page.dart';
import '../../Page/Employee/employee_page.dart';
import '../../Page/Employer/employer_page.dart';
import '../../Page/Recruitment/recruitment_page.dart';
import '../../Component/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showFirstLogo = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final role = prefs.getString('user_role');

    Widget nextPage;

    if (token != null && token.isNotEmpty && role != null && role.isNotEmpty) {
      // Token exists → navigate immediately based on role
      switch (role.toLowerCase()) {
        case "employee":
          nextPage = EmployeePage(token: token); // ✅ pass token
          break;
        case "agent":
          nextPage = const AgentPage();
          break;
        case "sponsor":
          nextPage = const EmployerPage();
          break;
        case "recruitment":
          nextPage = const RecruitmentPage();
          break;
        default:
          nextPage = const OnboardingScreen();
      }

      // Update Provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.login(role);

      // Navigate first
      setState(() => showFirstLogo = false);
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextPage),
      );

      // Then validate token in background
      _validateTokenInBackground(token, prefs);
    } else {
      // No token → Onboarding
      setState(() => showFirstLogo = false);
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  Future<void> _validateTokenInBackground(
      String token, SharedPreferences prefs) async {
    try {
      final userId = prefs.getString('user_id') ?? "";
      final res = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/v1/user/single'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "filters": {"id": userId} // Make sure backend accepts this
        }),
      );

      if (res.statusCode != 200) {
        // Token expired or invalid → logout user
        await prefs.clear();

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.logout();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      print("Token validation failed: $e");
      // Optional: ignore network errors and keep user logged in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              showFirstLogo
                  ? 'assets/images/splash_image/logo1.png'
                  : 'assets/images/splash_image/logo2.png',
              height: 150,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
