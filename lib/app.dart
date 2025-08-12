import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'screens/about/about_screen.dart';
import 'screens/services/services_screen.dart';
import 'screens/contact/contact_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'widgets/navbar.dart';
import 'widgets/bottom_navbar.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomeScreen(),
    const AboutScreen(),
    const ServicesScreen(),
    const ContactScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: CustomNavbar(
          onLoginTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          onRegisterTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: CustomBottomNavbar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
