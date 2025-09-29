import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class PromotedCVsScreen extends StatelessWidget {
  const PromotedCVsScreen({super.key});

  // Method to get translated CV data based on current language
  List<Map<String, String>> getTranslatedCVs(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    if (lang.currentLang == 'ar') {
      return [
        {
          "name": "حنان ناصر",
          "role": "سائق",
          "location": "أديس أبابا",
          "experience": "سنتين خبرة"
        },
        {
          "name": "أحمد يوسف",
          "role": "ميكانيكي",
          "location": "دير داوا",
          "experience": "٤ سنوات خبرة"
        },
      ];
    } else if (lang.currentLang == 'am') {
      return [
        {
          "name": "ሀናን ናሰር",
          "role": "ሹፌር",
          "location": "አዲስ አበባ",
          "experience": "2 ዓመት ልምድ"
        },
        {
          "name": "አህመድ ዩሱፍ",
          "role": "ሜካኒክ",
          "location": "ድሬ ዳዋ",
          "experience": "4 ዓመታት ልምድ"
        },
      ];
    } else {
      // English (default)
      return [
        {
          "name": "Hanan Nasser",
          "role": "Driver",
          "location": "Addis Ababa",
          "experience": "2 years experience"
        },
        {
          "name": "Ahmed Yusuf",
          "role": "Mechanic",
          "location": "Dire Dawa",
          "experience": "4 years experience"
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    final lang = Provider.of<LanguageProvider>(context);

    // Get translated CVs based on current language
    final List<Map<String, String>> cvs = getTranslatedCVs(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.t('promoted_cvs_title'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Show message if no CVs available
          if (cvs.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                lang.t('promoted_cvs_empty'),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            SizedBox(
              height: 400,
              child: PageView.builder(
                controller: controller,
                itemCount: cvs.length,
                itemBuilder: (context, index) {
                  final cv = cvs[index];
                  return Column(
                    children: [
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFFFFFFF)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 180,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 225, 225, 225),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    lang.t('profile_image'),
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                cv["name"]!,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                cv["role"]!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF65b2c9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cv["location"]!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 57, 57, 57),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cv["experience"]!,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF65b2c9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: Text(
                                    lang.t('reserve_now'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          // Pagination with buttons and circle indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  if (controller.hasClients && controller.page! > 0) {
                    controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  lang.t('previous'),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),

              // Circle indicators
              Row(
                children: List.generate(
                  cvs.length,
                  (index) => AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      double selectedness = 0.0;
                      if (controller.hasClients && controller.page != null) {
                        selectedness = controller.page! - index;
                        selectedness =
                            1.0 - (selectedness.abs().clamp(0.0, 1.0));
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedness > 0.5
                              ? const Color(0xFF65b2c9)
                              : Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  if (controller.hasClients &&
                      controller.page! < cvs.length - 1) {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  lang.t('next'),
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF65b2c9)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
