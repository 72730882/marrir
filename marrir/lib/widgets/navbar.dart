import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

  const CustomNavbar({
    super.key,
    required this.onLoginTap,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return AppBar(
      backgroundColor: const Color(0xFFDAF1F9), // Light blue like your design
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Row(
          children: [
            Image.asset(
              'assets/images/splash_image/logo3.png', // your logo path
              height: 80,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: onLoginTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF65b2c9),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(languageProvider.t('login')),
            ),
            const SizedBox(width: 5),
            ElevatedButton(
              onPressed: onRegisterTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF65b2c9),
                side: const BorderSide(color: Color(0xFF65b2c9)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(languageProvider.t('register')),
            ),
            const SizedBox(width: 4),

            // === Language Dropdown ===
            PopupMenuButton<String>(
              tooltip: "Select Language",
              icon: const Icon(Icons.translate, color: Colors.purple),
              onSelected: (value) {
                Provider.of<LanguageProvider>(context, listen: false)
                    .changeLanguage(value);
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: "en", child: Text("English")),
                const PopupMenuItem(value: "ar", child: Text("العربية")),
                const PopupMenuItem(value: "am", child: Text("አማርኛ")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
