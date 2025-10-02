import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/about/about_screen.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class Clienttalk extends StatefulWidget {
  const Clienttalk({super.key});

  @override
  State<Clienttalk> createState() => _ClienttalkState();
}

class _ClienttalkState extends State<Clienttalk> {
  late PageController pageController;
  late ValueNotifier<int> activePage;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    activePage = ValueNotifier<int>(0);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (pageController.hasClients) {
        int nextPage = activePage.value + 1;
        if (nextPage >= _getTestimonials(context).length) nextPage = 0;
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        activePage.value = nextPage;
      }
    });
  }

  List<Map<String, String>> _getTestimonials(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return [
      {
        "quote": languageProvider.t('testimonial_1_quote'),
        "name": languageProvider.t('testimonial_1_name'),
        "position": languageProvider.t('testimonial_1_position'),
        "company": languageProvider.t('testimonial_1_company'),
      },
      {
        "quote": languageProvider.t('testimonial_2_quote'),
        "name": languageProvider.t('testimonial_2_name'),
        "position": languageProvider.t('testimonial_2_position'),
        "company": languageProvider.t('testimonial_2_company'),
      },
      {
        "quote": languageProvider.t('testimonial_3_quote'),
        "name": languageProvider.t('testimonial_3_name'),
        "position": languageProvider.t('testimonial_3_position'),
        "company": languageProvider.t('testimonial_3_company'),
      },
    ];
  }

  @override
  void dispose() {
    _timer?.cancel();
    pageController.dispose();
    activePage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final testimonials = _getTestimonials(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Blue Info Card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF65b2c9),
                  Color(0xFF88C3D5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(97, 223, 237, 240),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.rocket_launch,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  languageProvider.t('easily_accessible'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  languageProvider.t('better_workflow'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  languageProvider.t('workflow_description'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF65b2c9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 35,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        languageProvider.t('learn_more'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Text(
            languageProvider.t('what_clients_say'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 250,
            child: PageView.builder(
              controller: pageController,
              itemCount: testimonials.length,
              onPageChanged: (index) {
                activePage.value = index;
              },
              itemBuilder: (context, index) {
                final client = testimonials[index];
                return Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(203, 255, 255, 255),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color.fromARGB(255, 239, 249, 239),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0F0F0),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star,
                            size: 16,
                            color: Color(0xFFFFC107),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        client["quote"]!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        client["name"]!,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        client["position"]!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 129, 204, 226),
                        ),
                      ),
                      Text(
                        client["company"]!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 57, 57, 57),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          ValueListenableBuilder<int>(
            valueListenable: activePage,
            builder: (context, value, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: testimonials.asMap().entries.map((entry) {
                  int idx = entry.key;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          value == idx ? const Color(0xFF65b2c9) : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
