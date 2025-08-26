import 'package:flutter/material.dart';

class PhotoAndLanguageForm extends StatefulWidget {
  const PhotoAndLanguageForm({super.key});

  @override
  _PhotoAndLanguageFormState createState() => _PhotoAndLanguageFormState();
}

class _PhotoAndLanguageFormState extends State<PhotoAndLanguageForm> {
  final List<String> languageLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Fluent',
  ];

  String? englishLevel;
  String? amharicLevel;
  String? arabicLevel;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF8EC6D6);
    const Color borderColor = Color(0xFFD1D1D6);
    const Color textColor = Color(0xFF111111);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Step 7: Photo and Language',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),

          // Upload Sections
          _buildUploadBox(
            icon: Icons.photo_camera_outlined,
            title: "Upload Head Photo",
          ),
          const SizedBox(height: 16),
          _buildUploadBox(
            icon: Icons.person_outline,
            title: "Upload Full Body Photo",
          ),
          const SizedBox(height: 16),
          _buildUploadBox(
            icon: Icons.videocam_outlined,
            title: "Upload Introductory Video",
          ),

          const SizedBox(height: 24),

          // Language dropdowns
          _buildDropdownField(
            'English',
            englishLevel,
            (value) => setState(() => englishLevel = value),
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            'Amharic',
            amharicLevel,
            (value) => setState(() => amharicLevel = value),
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            'Arabic',
            arabicLevel,
            (value) => setState(() => arabicLevel = value),
          ),

          const SizedBox(height: 20),

          // Add Language Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                  ),
                  child: const Text(
                    "Show another Language",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                  ),
                  child: const Text(
                    "Add another Language",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                print("English: $englishLevel");
                print("Amharic: $amharicLevel");
                print("Arabic: $arabicLevel");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUploadBox({required IconData icon, required String title}) {
    const Color borderColor = Color(0xFFD1D1D6);
    const Color primaryColor = Color(0xFF8EC6D6);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 140,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                "Choose File",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    const Color borderColor = Color(0xFFD1D1D6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            hintText: "Select Level",
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
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
          ),
          items: languageLevels
              .map((level) => DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
