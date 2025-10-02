import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.purple,
          unselectedItemColor: const Color(0xFF4DA8DA),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: languageProvider.t('home').contains('home')
                  ? (languageProvider.currentLang == 'ar'
                      ? 'الرئيسية'
                      : languageProvider.currentLang == 'am'
                          ? 'መነሻ'
                          : 'Home')
                  : languageProvider.t('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.mail_outline),
              label: languageProvider.t('about_us'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.format_list_bulleted),
              label: languageProvider.t('services_title'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.call),
              label: languageProvider.t('landing_contact_us'),
            ),
          ],
        );
      },
    );
  }
}
