import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marrir/services/Employee/cv_service.dart';

class PhotoAndLanguageForm extends StatefulWidget {
  const PhotoAndLanguageForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PhotoAndLanguageFormState createState() => _PhotoAndLanguageFormState();
}

class _PhotoAndLanguageFormState extends State<PhotoAndLanguageForm> {
  final List<String> languageLevels = [
    "none",
    "basic",
    "intermediate",
    "fluent"
  ];

  String? englishLevel;
  String? amharicLevel;
  String? arabicLevel;

  File? headPhoto;
  File? fullBodyPhoto;
  File? introVideo;

  bool isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFile(bool isHead, bool isFullBody, bool isVideo) async {
    if (isVideo) {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() => introVideo = File(video.path));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Introductory video selected ✅")),
        );
      }
    } else {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (isHead) headPhoto = File(image.path);
          if (isFullBody) fullBodyPhoto = File(image.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isHead
                ? "Head photo selected ✅"
                : "Full body photo selected ✅"),
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    setState(() => isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    // ✅ use same keys as StepID
    final token = prefs.getString("access_token");
    final userId = prefs.getString("user_id");

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing authentication")),
      );
      setState(() => isSubmitting = false);
      return;
    }

    try {
      final res = await CVService.submitCVForm(
        nationalId: "",
        passportNumber: "",
        dateIssued: "",
        placeIssued: "",
        dateExpiry: "",
        nationality: "",
        userId: userId,
        token: token,
        headPhoto: headPhoto,
        fullBodyPhoto: fullBodyPhoto,
        introVideo: introVideo,
        english: englishLevel,
        amharic: amharicLevel,
        arabic: arabicLevel,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CV Submitted: ${res['id'] ?? 'Success'}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF8EC6D6);
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
            onPick: () => _pickFile(true, false, false),
          ),
          const SizedBox(height: 16),
          _buildUploadBox(
            icon: Icons.person_outline,
            title: "Upload Full Body Photo",
            onPick: () => _pickFile(false, true, false),
          ),
          const SizedBox(height: 16),
          _buildUploadBox(
            icon: Icons.videocam_outlined,
            title: "Upload Introductory Video",
            onPick: () => _pickFile(false, false, true),
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

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
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

  Widget _buildUploadBox({
    required IconData icon,
    required String title,
    required VoidCallback onPick,
  }) {
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
              onPressed: onPick,
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
