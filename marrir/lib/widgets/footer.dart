import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart'; // Correct import

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo
        Image.asset(
          'assets/images/splash_image/logo3.png',
          height: 100,
        ),
        const SizedBox(height: 1),

        // Company Name
        const Text(
          "EJITIAZ PORTAL LLC",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF65b2c9),
          ),
        ),

        const SizedBox(height: 15),

        // Address
        Text(
          languageProvider.t('company_address'),
          style: const TextStyle(fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Social Media Icons Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon(FontAwesomeIcons.linkedin, Colors.blue, () {}),
            _socialIcon(FontAwesomeIcons.facebook, Colors.blueAccent, () {}),
            _socialIcon(FontAwesomeIcons.twitter, Colors.lightBlue, () {}),
            _socialIcon(FontAwesomeIcons.instagram, Colors.purple, () {}),
            _socialIcon(FontAwesomeIcons.whatsapp, Colors.green, () {}),
          ],
        ),
        const SizedBox(height: 10),

        // Divider line
        const Divider(
          color: Colors.black,
          thickness: 1.5,
          indent: 20,
          endIndent: 20,
        ),
        const SizedBox(height: 10),

        // Copyright
        Text(
          languageProvider.t('copyright'),
          style: const TextStyle(
              fontSize: 12, color: Color.fromARGB(255, 2, 2, 2)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  static Widget _socialIcon(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      icon: FaIcon(icon, color: color),
      onPressed: onTap,
    );
  }
}
