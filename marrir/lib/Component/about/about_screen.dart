import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marrir/Component/Language/language_provider.dart'; // Import your LanguageProvider
import 'package:provider/provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF65b2c9),
                  Color(0xFF88C3D5),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  lang.t('about_us'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  lang.t('learn_more'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ===== WHO WE ARE =====
          _buildWhiteCard(
            icon: Icons.rocket_launch_outlined, // Slim Material outline
            title: lang.t('who_we_are'),
            titleStyle: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            centerTitle: true,
            content:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: lang.t('about_desc1'),
                    ),
                    TextSpan(
                      text: lang.t('company_name'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: lang.t('about_desc2'),
                    ),
                    TextSpan(
                      text: lang.t('company_name'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: lang.t('about_desc3'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ]),
          ),
          const SizedBox(height: 24),

          // ===== OUR MISSION =====
          _buildWhiteCard(
            icon: Icons.threesixty_outlined, // Slim 360-degree icon
            title: lang.t('our_mission'),

            titleStyle: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            centerTitle: true,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    lang.t('mission_statement'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      color: Color.fromARGB(255, 72, 155, 180),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lang.t('mission_statement1'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===== OUR VISION =====
          _buildWhiteCard(
            icon: Icons.lightbulb_outline, // Slim lightbulb
            title: lang.t('our_vision'),
            titleStyle: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            centerTitle: true,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    lang.t('vision_statement'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      color: Color.fromARGB(255, 72, 155, 180),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lang.t('vision_statement1'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===== CONTACT US FOOTER =====
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/splash_image/logo3.png', // your logo path
                height: 100,
              ),
              const SizedBox(height: 1),

              // Email
              Text(
                lang.t('office_name'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF65b2c9),
                ),
              ),

              const SizedBox(height: 15),

              // Address
              Text(
                lang.t('office_address'),
                style: const TextStyle(
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Social Media Icons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.linkedin,
                        color: Colors.blue),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.facebook,
                        color: Colors.blueAccent),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.twitter,
                        color: Colors.lightBlue),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.instagram,
                        color: Colors.purple),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.whatsapp,
                        color: Colors.green),
                    onPressed: () {},
                  ),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 2, 2, 2),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
          )
        ],
      ),
    );
  }

  // ===== REUSABLE WHITE CARD =====
  static Widget _buildWhiteCard({
    required String title,
    required Widget content,
    TextStyle? titleStyle,
    bool centerTitle = false,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Colors.white,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: centerTitle
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              // Icon at top of card, above title
              Icon(
                icon,
                size: 80, // bigger size
                color: const Color(0xFF72ABC1), // match your design
              ),
              const SizedBox(height: 30),

              // Title
              Text(
                title,
                style: titleStyle ??
                    const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B9A),
                    ),
                textAlign: centerTitle ? TextAlign.center : TextAlign.start,
              ),
              const SizedBox(height: 16),

              // Content
              content,
            ],
          ),
        ),
      ),
    );
  }
}
