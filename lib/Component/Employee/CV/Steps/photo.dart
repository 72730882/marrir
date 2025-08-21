import 'package:flutter/material.dart';

class PhotoAndLanguageForm extends StatefulWidget {
  const PhotoAndLanguageForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PhotoAndLanguageFormState createState() => _PhotoAndLanguageFormState();
}

class _PhotoAndLanguageFormState extends State<PhotoAndLanguageForm> {
  final List<String> languageLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Fluent',
  ];

  // Selected levels for languages
  String? englishLevel;
  String? amharicLevel;
  String? arabicLevel;

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF111111);
    const Color borderColor = Color(0xFFD1D1D6);
    const Color dividerColor = Color(0xFFE5E5EA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const Text(
          'Step 7: Photo and Language',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),

        const SizedBox(height: 30),

        // Photo Upload Section
        _buildUploadSection('Upload Head Photo'),
        const SizedBox(height: 16),
        _buildUploadSection('Upload Full Body Photo'),
        const SizedBox(height: 16),
        _buildUploadSection('Upload Introductory Video'),

        const SizedBox(height: 24),
        const Divider(color: dividerColor, thickness: 1, height: 1),
        const SizedBox(height: 24),

        // Language Section
        _buildDropdownField(
          'English',
          languageLevels,
          englishLevel,
          (value) => setState(() => englishLevel = value),
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          'Amharic',
          languageLevels,
          amharicLevel,
          (value) => setState(() => amharicLevel = value),
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          'Arabic',
          languageLevels,
          arabicLevel,
          (value) => setState(() => arabicLevel = value),
        ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: () {
            // Handle add another language logic
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Add another Language',
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(142, 198, 214, 1),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              print('English Level: $englishLevel');
              print('Amharic Level: $amharicLevel');
              print('Arabic Level: $arabicLevel');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
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

  Widget _buildUploadSection(String title) {
    const Color borderColor = Color(0xFFD1D1D6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose File',
                style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(142, 198, 214, 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Browse',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String language,
    List<String> options,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    const Color borderColor = Color(0xFFD1D1D6);
    const Color mutedText = Color(0xFF8E8E93);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            hintText: 'Select Level',
            hintStyle: const TextStyle(color: mutedText),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
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
          items: options
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
