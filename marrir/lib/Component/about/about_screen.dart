import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "About Us",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Learn more about our company and values",
                  style: TextStyle(
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
            title: "Who We Are",
            titleStyle: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            centerTitle: true,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text:
                            "MARRIR is an innovative technology solution as part of (LITARE PORTAL LLC) talent.com in a dedicated ONLINE PLATFORM to bridging workforce gaps through innovation technology-driven services to enhance recruitment, matching and talent search. ",
                      ),
                      TextSpan(
                        text: "MARRIR",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            ", connects Job Seekers, Employment Firms, International Recruitment Agencies and EMPLOYEES as highly connected parties. ",
                      ),
                      TextSpan(
                        text: "MARRIR",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            " enables its customers to simplify the hiring process for businesses across the GCC and beyond.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===== OUR MISSION =====
          _buildWhiteCard(
            icon: Icons.threesixty_outlined, // Slim 360-degree icon
            title: "Our Mission",
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
                  child: const Text(
                    "\"To revolutionize workforce recruitment by providing a seamless, technology-driven platform that connects Job Seekers, Employment Firms, International Recruitment Agencies and EMPLOYERS.\"",
                    style: TextStyle(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      color: Color.fromARGB(255, 72, 155, 180),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  " At Marrir we strive to enhance transparency, efficiency, and accessibility in the hiring process, ensuring that businesses across the GCC and beyond can easily find the right talent. Through innovation and strategic partnerships, we aim to simplify recruitment, empower job seekers, and create a more dynamic and inclusive job market",
                  style: TextStyle(
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
            title: "Our Vision",
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
                  child: const Text(
                    "\"To be the leading and most trusted solution for manpower acquisition, setting new industry standards through precision, innovation, and excellence while serving our customers.\"",
                    style: TextStyle(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      color: Color.fromARGB(255, 72, 155, 180),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "We aspire to transform the global recruitment landscape by leveraging cutting-edge technology to optimise hiring processes, foster long-term professional relationships, and bridge workforce gaps with unmarched efficiency. By continuously evolving and adapting to industry needs, we aim to drive a future hiring exclusive where recruitment is minute, faster, and more important for businesses and job seekers a like.",
                  style: TextStyle(
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
              const Text(
                "Concord Tower - 9th floor - AI Sufah\n - Dubai Media City - Dubai",
                style: TextStyle(
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
                    onPressed: () {
                      // TODO: Add LinkedIn link
                    },
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.facebook,
                        color: Colors.blueAccent),
                    onPressed: () {
                      // TODO: Add Facebook link
                    },
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.twitter,
                        color: Colors.lightBlue),
                    onPressed: () {
                      // TODO: Add Twitter link
                    },
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.instagram,
                        color: Colors.purple),
                    onPressed: () {
                      // TODO: Add Instagram link
                    },
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.whatsapp,
                        color: Colors.green),
                    onPressed: () {
                      // TODO: Add WhatsApp link
                    },
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
