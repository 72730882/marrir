import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo
        Image.asset(
          'assets/images/splash_image/logo3.png',
          height: 100,
        ),
        const SizedBox(height: 1),

        // Email
        const Text(
          "info@marrrir.com",
          style: TextStyle(fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),

        // Address
        const Text(
          "Concord Tower - 9th floor - AI Sufah\n - Dubai Media City - Dubai",
          style: TextStyle(fontSize: 13),
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
        const Text(
          "© 2025 Marrir.com. All rights reserved.",
          style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 2, 2, 2)),
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
