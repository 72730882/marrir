import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marrir/services/Employee/cv_service.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class PhotoAndLanguageForm extends StatefulWidget {
  const PhotoAndLanguageForm({super.key});

  @override
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

  // Design tokens
  static const _primaryColor = Color(0xFF8EC6D6);
  static const _textColor = Color(0xFF111111);
  static const _borderColor = Color(0xFFD1D1D6);
  static const _hintColor = Color(0xFF9AA3B2);

  // Get translated labels for display
  String _getTranslatedLabel(String value, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    // Language level translations
    if (value == "none") {
      if (lang == 'ar') return "لا شيء";
      if (lang == 'am') return "የለም";
      return "None";
    }
    if (value == "basic") {
      if (lang == 'ar') return "أساسي";
      if (lang == 'am') return "መሠረታዊ";
      return "Basic";
    }
    if (value == "intermediate") {
      if (lang == 'ar') return "متوسط";
      if (lang == 'am') return "መካከለኛ";
      return "Intermediate";
    }
    if (value == "fluent") {
      if (lang == 'ar') return "طلاقة";
      if (lang == 'am') return "ፈሳሽ";
      return "Fluent";
    }

    return value;
  }

  String _getTranslatedHint(String label, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر $label";
    if (lang == 'am') return "$label ይምረጡ";
    return "Select $label";
  }

  InputDecoration _decoration({
    String? hint,
    Widget? suffixIcon,
    Widget? prefixIcon,
    LanguageProvider? languageProvider,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _hintColor,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: _textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) labelOf,
    required void Function(T?) onChanged,
    required LanguageProvider languageProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(
                    labelOf(e),
                    style: const TextStyle(fontSize: 13, color: _textColor),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: _decoration(
            hint: _getTranslatedHint(
                _getTranslatedLevelLabel(languageProvider), languageProvider),
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _hintColor,
                size: 22,
              ),
            ),
            languageProvider: languageProvider,
          ),
          icon: const SizedBox.shrink(),
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(fontSize: 13, color: _textColor),
        ),
      ],
    );
  }

  Future<void> _pickFile(bool isHead, bool isFullBody, bool isVideo,
      LanguageProvider languageProvider) async {
    if (isVideo) {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() => introVideo = File(video.path));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_getTranslatedVideoSelected(languageProvider))),
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
                ? _getTranslatedHeadPhotoSelected(languageProvider)
                : _getTranslatedFullBodyPhotoSelected(languageProvider)),
          ),
        );
      }
    }
  }

  Future<void> _submitForm(LanguageProvider languageProvider) async {
    setState(() => isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final userId = prefs.getString("user_id");

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTranslatedMissingAuth(languageProvider))),
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
        SnackBar(content: Text(_getTranslatedSuccessMessage(languageProvider))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                _getTranslatedErrorMessage(e.toString(), languageProvider))),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            _getTranslatedStepTitle(languageProvider),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 20),

          // Upload Sections
          _buildUploadBox(
            icon: Icons.photo_camera_outlined,
            title: _getTranslatedHeadPhotoTitle(languageProvider),
            onPick: () => _pickFile(true, false, false, languageProvider),
            languageProvider: languageProvider,
          ),
          const SizedBox(height: 16),
          _buildUploadBox(
            icon: Icons.person_outline,
            title: _getTranslatedFullBodyPhotoTitle(languageProvider),
            onPick: () => _pickFile(false, true, false, languageProvider),
            languageProvider: languageProvider,
          ),
          const SizedBox(height: 16),
          _buildUploadBox(
            icon: Icons.videocam_outlined,
            title: _getTranslatedIntroVideoTitle(languageProvider),
            onPick: () => _pickFile(false, false, true, languageProvider),
            languageProvider: languageProvider,
          ),

          const SizedBox(height: 24),

          // Language dropdowns
          _dropdown<String>(
            label: _getTranslatedEnglishLabel(languageProvider),
            value: englishLevel,
            items: languageLevels,
            labelOf: (value) => _getTranslatedLabel(value, languageProvider),
            onChanged: (v) => setState(() => englishLevel = v),
            languageProvider: languageProvider,
          ),
          const SizedBox(height: 12),
          _dropdown<String>(
            label: _getTranslatedAmharicLabel(languageProvider),
            value: amharicLevel,
            items: languageLevels,
            labelOf: (value) => _getTranslatedLabel(value, languageProvider),
            onChanged: (v) => setState(() => amharicLevel = v),
            languageProvider: languageProvider,
          ),
          const SizedBox(height: 12),
          _dropdown<String>(
            label: _getTranslatedArabicLabel(languageProvider),
            value: arabicLevel,
            items: languageLevels,
            labelOf: (value) => _getTranslatedLabel(value, languageProvider),
            onChanged: (v) => setState(() => arabicLevel = v),
            languageProvider: languageProvider,
          ),

          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  isSubmitting ? null : () => _submitForm(languageProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _getTranslatedSubmitButton(languageProvider),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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
    required LanguageProvider languageProvider,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: _primaryColor, size: 32),
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
                backgroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                _getTranslatedChooseFile(languageProvider),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedStepTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الخطوة 7: الصورة واللغة";
    if (lang == 'am') return "ደረጃ 7: ፎቶ እና ቋንቋ";
    return "Step 7: Photo and Language";
  }

  String _getTranslatedHeadPhotoTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "رفع صورة الرأس";
    if (lang == 'am') return "የራስ ፎቶ ስቀል";
    return "Upload Head Photo";
  }

  String _getTranslatedFullBodyPhotoTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "رفع صورة كاملة للجسم";
    if (lang == 'am') return "ሙሉ አካል ፎቶ ስቀል";
    return "Upload Full Body Photo";
  }

  String _getTranslatedIntroVideoTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "رفع فيديو تعريفي";
    if (lang == 'am') return "መግቢያ ቪዲዮ ስቀል";
    return "Upload Introductory Video";
  }

  String _getTranslatedChooseFile(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر ملف";
    if (lang == 'am') return "ፋይል ይምረጡ";
    return "Choose File";
  }

  String _getTranslatedLevelLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المستوى";
    if (lang == 'am') return "ደረጃ";
    return "Level";
  }

  String _getTranslatedEnglishLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الإنجليزية";
    if (lang == 'am') return "እንግሊዝኛ";
    return "English";
  }

  String _getTranslatedAmharicLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الأمهرية";
    if (lang == 'am') return "አማርኛ";
    return "Amharic";
  }

  String _getTranslatedArabicLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "العربية";
    if (lang == 'am') return "ዐረብኛ";
    return "Arabic";
  }

  String _getTranslatedSubmitButton(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إرسال";
    if (lang == 'am') return "አስገባ";
    return "Submit";
  }

  // Success and error message translations
  String _getTranslatedVideoSelected(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم اختيار الفيديو التعريفي ✅";
    if (lang == 'am') return "መግቢያ ቪዲዮ ተመርጧል ✅";
    return "Introductory video selected ✅";
  }

  String _getTranslatedHeadPhotoSelected(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم اختيار صورة الرأس ✅";
    if (lang == 'am') return "የራስ ፎቶ ተመርጧል ✅";
    return "Head photo selected ✅";
  }

  String _getTranslatedFullBodyPhotoSelected(
      LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم اختيار صورة كاملة للجسم ✅";
    if (lang == 'am') return "ሙሉ አካል ፎቶ ተመርጧል ✅";
    return "Full body photo selected ✅";
  }

  String _getTranslatedMissingAuth(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "بيانات المصادقة مفقودة";
    if (lang == 'am') return "የማረጋገጫ መረጃ ጠፍቷል";
    return "Missing authentication";
  }

  String _getTranslatedSuccessMessage(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم إرسال السيرة الذاتية بنجاح";
    if (lang == 'am') return "ሲቪ በተሳካ ሁኔታ ቀርቧል";
    return "CV Submitted Successfully";
  }

  String _getTranslatedErrorMessage(
      String error, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "خطأ: $error";
    if (lang == 'am') return "ስህተት: $error";
    return "Error: $error";
  }
}
