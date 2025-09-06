import 'package:flutter/material.dart';
import 'package:marrir/Component/onboarding/onboarding_screen.dart';

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

    // First logo for 2 seconds
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        showFirstLogo = false;
      });

      // Second logo + text for 2 more seconds
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FB), // ✅ Matching background color
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
          ],
        ),
      ),
    );
  }
}
