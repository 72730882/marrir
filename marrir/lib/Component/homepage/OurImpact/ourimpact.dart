import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/auth/login_screen.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class OurImpact extends StatelessWidget {
  const OurImpact({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    // Check if current language is Arabic
    bool isArabic = lang.currentLang == 'ar';

    return SingleChildScrollView(
      child: Column(
        children: [
          // FULL-WIDTH BACKGROUND (Who we are)
          Container(
            width: double.infinity,
            height: 410,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF65b2c9),
                  Color(0xFF88C3D5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.t('welcome'),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: isArabic ? TextAlign.center : TextAlign.start,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lang.t('descriptions'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                    textAlign: isArabic ? TextAlign.center : TextAlign.start,
                  ),
                  const SizedBox(height: 20),

                  // Button - centered for Arabic
                  Align(
                    alignment:
                        isArabic ? Alignment.center : Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Text(
                        lang.t('get_started'),
                        style: const TextStyle(
                          color: Color(0xFF65b2c9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // OUR IMPACT (2x2 grid, full-width background)
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 13),
              child: Column(
                children: [
                  Text(
                    lang.t('our_impact'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    lang.t('impact_subtitle'),
                    style:
                        const TextStyle(fontSize: 15, color: Color(0xFF666666)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.2,
                    children: [
                      _buildStatCard('500K+', lang.t('employees')),
                      _buildStatCard('1K+', lang.t('agencies')),
                      _buildStatCard('1K+', lang.t('recruitment_firms')),
                      _buildStatCard('3K+', lang.t('employers')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 218, 244, 253),
            Color.fromARGB(255, 236, 237, 237),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 143, 62, 141),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromARGB(255, 102, 102, 102),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
