import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/lang.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class ServicesApp extends StatelessWidget {
  const ServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the language provider
    final languageProvider = Provider.of<LanguageProvider>(context);
    final strings = AppStrings.translations[languageProvider.currentLang] ??
        AppStrings.translations['en']!;

    final List<Map<String, dynamic>> services = [
      {
        "title": strings['job_posting']!,
        "desc": strings['job_posting_desc']!,
        "icon": const Icon(
          Icons.work_outline,
          color: Color(0xFF65b2c9),
          size: 28,
        ),
      },
      {
        "title": strings['profile_reservation']!,
        "desc": strings['profile_reservation_desc']!,
        "icon": const Icon(
          Icons.person_outline,
          color: Color(0xFF65b2c9),
          size: 28,
        ),
      },
      {
        "title": strings['transfer_profile_service']!,
        "desc": strings['transfer_profile_desc']!,
        "icon": const Icon(
          Icons.swap_horiz,
          color: Color(0xFF65b2c9),
          size: 28,
        ),
      },
      {
        "title": strings['profile_selection']!,
        "desc": strings['profile_selection_desc']!,
        "icon": const Icon(
          Icons.check_circle_outline,
          color: Color(0xFF65b2c9),
          size: 28,
        ),
      },
      {
        "title": strings['job_applications']!,
        "desc": strings['job_applications_desc']!,
        "icon": const Icon(
          Icons.assignment_outlined,
          color: Color(0xFF65b2c9),
          size: 28,
        ),
      },
      {
        "title": strings['profile_promotion']!,
        "desc": strings['profile_promotion_desc']!,
        "icon": const Icon(
          Icons.trending_up,
          color: Color(0xFF65b2c9),
          size: 28,
        ),
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            strings['services_title']!,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            strings['services_subtitle']!,
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 57, 57, 57),
              height: 1.4,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),

          // Grid of services
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 220,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    services[index]["icon"],
                    const SizedBox(height: 8),
                    Text(
                      services[index]["title"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      services[index]["desc"]!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 57, 57, 57),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
