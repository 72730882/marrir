import 'package:flutter/material.dart';
import '../../app.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Use the logo color for the overlay (example: #A03C8B, adjust as needed)
  final Color _marrirBlue = const Color(0xFF65ADC3);

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/onboarding_images/ob2.jpg',
      'title': 'Welcome',
      'desc':
          'Empowering recruiters, agents, and sponsors with streamlined tools to manage job postings, profiles, and talent acquisition processes efficiently.',
      'button': 'Get Started',
    },
    {
      'image': 'assets/images/onboarding_images/ob1.jpg',
      'title': 'Job Posting',
      'desc':
          'Efficient and swift selection of candidates based on employers\' specified job descriptions.',
      'button': 'Enter',
    },
    {
      'image': 'assets/images/onboarding_images/onb3.png',
      'title': 'Profile Reservation',
      'desc':
          'Securing candidate profiles for personal interviews and future considerations.',
      'button': 'Enter',
    },
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
       // Navigate to home (replace onboarding so user can't go back)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (context, index) {
          final item = _pages[index];

          return Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                item['image']!,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),

              // Bottom gradient overlay
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        _marrirBlue,
                        _marrirBlue.withOpacity(0.8),
                        _marrirBlue.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Title
                    Text(
                      item['title']!,
                      style: const TextStyle(
                        fontFamily:
                            'Montserrat', // Use a modern sans-serif font
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    // Description
                    Text(
                      item['desc']!,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        color: Colors.white70, // Softer white for description
                        height: 1.6,
                        fontWeight: FontWeight.w500, // Slightly bolder
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Add the divider indicator for 2nd and 3rd page
                    if (_currentPage == 1 || _currentPage == 2) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (dotIndex) {
                            bool isActive =
                                (_currentPage == 1 && dotIndex == 0) ||
                                    (_currentPage == 2 && dotIndex == 1);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3.0),
                              child: Container(
                                width: isActive ? 24 : 8,
                                height: isActive ? 6 : 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                  borderRadius:
                                      BorderRadius.circular(isActive ? 3 : 4),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                    // Button
                    Center(
                      child: SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            item['button']!,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Logo at the bottom left
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0, bottom: 10.0),
                        child: Image.asset(
                          'assets/images/onboarding_images/logo2.png',
                          width: 70,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
