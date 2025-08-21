import 'package:flutter/material.dart';

class AdditionalContactForm extends StatelessWidget {
  const AdditionalContactForm({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF111111);
    const Color buttonColor = Color.fromRGBO(142, 198, 214, 1);

    // List of social media platforms
    final socialPlatforms = [
      {'name': 'Facebook', 'icon': Icons.facebook},
      {'name': 'Twitter', 'icon': Icons.alternate_email},
      {'name': 'Telegram', 'icon': Icons.send},
      {'name': 'Tiktok', 'icon': Icons.music_note},
      {'name': 'Instagram', 'icon': Icons.camera_alt},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // Step indicator
        const Text(
          'Step 10: Additional Contact Information',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 30),

        // Social media input fields
        ...socialPlatforms.map((platform) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildSocialInput(
              platform['name'] as String,
              platform['icon'] as IconData,
            ),
          );
        }).toList(),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSocialInput(String label, IconData icon) {
    const Color borderColor = Color(0xFFD1D1D6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xFF111111)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }
}
