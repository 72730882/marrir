import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  "Contact Us",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Do you have any questions? Please leave us a message",
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

          // ===== CONTACT FORM CARD (no rounded box, just underline inputs) =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Full Name Input with underline only
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Email Input with underline only
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Message Input with underline only (multiline)
                    TextField(
  maxLines: 3,
  decoration: const InputDecoration(
    labelText: 'Message',
    hintText: 'Message here...',
    alignLabelWithHint: true, // important for multiline so label aligns properly
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
  ),
),


                    // Submit Button full width
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF65b2c9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Handle "See All"
                          },
                          child: const Text(
                            "Submit",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Add padding below the card before footer
          const SizedBox(height: 40),

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
                "info@marrrir.com",
                style: TextStyle(
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
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
}
