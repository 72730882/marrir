import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/Employee/cv_service.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class EducationalDataForm extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onNextStep;
  const EducationalDataForm(
      {super.key, required this.onSuccess, required this.onNextStep});

  @override
  _EducationalDataFormState createState() => _EducationalDataFormState();
}

class _EducationalDataFormState extends State<EducationalDataForm> {
  bool isGraduate = true;
  String formTitle = 'Graduate Form';

  // Controllers for editable fields
  final TextEditingController cityController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();

  // Dropdown selections
  String? selectedEducation;
  String? selectedInstitution;
  String? selectedCountry;
  String? selectedOccupationField;
  String? selectedOccupation;

  bool _isLoading = false;

  // Design tokens
  static const _titleColor = Color(0xFF1D2433);
  static const _labelColor = Color(0xFF3C4555);
  static const _hintColor = Color(0xFF9AA3B2);
  static const _borderColor = Color(0xFFE6E9EF);
  static const _fillColor = Colors.white;
  static const _iconMuted = Color(0xFF667085);
  static const _buttonTeal = Color(0xFF8EC6D6);
  static const _selectedColor = Color(0xFF65B2C9);

  // Dropdown options
  static const List<String> _educationOptions = ['Bachelor', 'Master', 'PhD'];
  static const List<String> _institutionOptions = [
    'University A',
    'University B'
  ];
  static const List<String> _countryOptions = ['USA', 'UK', 'Canada'];
  static const List<String> _occupationFieldOptions = [
    'IT',
    'Finance',
    'Engineering'
  ];
  static const List<String> _occupationOptions = [
    'Developer',
    'Analyst',
    'Manager'
  ];

  void _toggleForm() {
    setState(() {
      isGraduate = !isGraduate;
      formTitle = isGraduate ? 'Graduate Form' : 'Non-Graduate Form';
    });
  }

  // Get translated labels for display
  String _getTranslatedLabel(String value, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    // Education translations
    if (value == "Bachelor") {
      if (lang == 'ar') return "بكالوريوس";
      if (lang == 'am') return "ባችለር";
      return "Bachelor";
    }
    if (value == "Master") {
      if (lang == 'ar') return "ماجستير";
      if (lang == 'am') return "ማስተር";
      return "Master";
    }
    if (value == "PhD") {
      if (lang == 'ar') return "دكتوراه";
      if (lang == 'am') return "ዶክተር";
      return "PhD";
    }

    // Institution translations
    if (value == "University A") {
      if (lang == 'ar') return "الجامعة أ";
      if (lang == 'am') return "ዩኒቨርሲቲ አ";
      return "University A";
    }
    if (value == "University B") {
      if (lang == 'ar') return "الجامعة ب";
      if (lang == 'am') return "ዩኒቨርሲቲ ቢ";
      return "University B";
    }

    // Country translations
    if (value == "USA") {
      if (lang == 'ar') return "الولايات المتحدة";
      if (lang == 'am') return "አሜሪካ";
      return "USA";
    }
    if (value == "UK") {
      if (lang == 'ar') return "المملكة المتحدة";
      if (lang == 'am') return "እንግሊዝ";
      return "UK";
    }
    if (value == "Canada") {
      if (lang == 'ar') return "كندا";
      if (lang == 'am') return "ካናዳ";
      return "Canada";
    }

    // Occupation field translations
    if (value == "IT") {
      if (lang == 'ar') return "تكنولوجيا المعلومات";
      if (lang == 'am') return "አይቲ";
      return "IT";
    }
    if (value == "Finance") {
      if (lang == 'ar') return "المالية";
      if (lang == 'am') return "ፋይናንስ";
      return "Finance";
    }
    if (value == "Engineering") {
      if (lang == 'ar') return "الهندسة";
      if (lang == 'am') return "ኢንጂነሪንግ";
      return "Engineering";
    }

    // Occupation translations
    if (value == "Developer") {
      if (lang == 'ar') return "مطور";
      if (lang == 'am') return "ዲቬሎፐር";
      return "Developer";
    }
    if (value == "Analyst") {
      if (lang == 'ar') return "محلل";
      if (lang == 'am') return "አናላይስት";
      return "Analyst";
    }
    if (value == "Manager") {
      if (lang == 'ar') return "مدير";
      if (lang == 'am') return "ማኔጅር";
      return "Manager";
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
      fillColor: _fillColor,
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
            fontSize: 13,
            color: _labelColor,
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
        DropdownButtonFormField<T>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(
                    labelOf(e),
                    style: const TextStyle(fontSize: 13, color: _labelColor),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: _decoration(
            hint: _getTranslatedHint(label, languageProvider),
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _iconMuted,
                size: 22,
              ),
            ),
            languageProvider: languageProvider,
          ),
          icon: const SizedBox.shrink(),
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(fontSize: 13, color: _labelColor),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');
      final String? token = prefs.getString('access_token');

      if (userId == null || token == null) {
        throw Exception(_getTranslatedNotLoggedIn(languageProvider));
      }

      final res = await CVService.submitEducationInfo(
        userId: userId,
        token: token,
        highestLevel: selectedEducation,
        institutionName: selectedInstitution,
        country: selectedCountry,
        city: cityController.text.trim(),
        grade: gradeController.text.trim(),
        occupationCategory: selectedOccupationField,
        occupation: selectedOccupation,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTranslatedSuccessMessage(languageProvider))),
      );

      widget.onSuccess();
      widget.onNextStep();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                _getTranslatedErrorMessage(e.toString(), languageProvider))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    cityController.dispose();
    gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    const Color textColor = Color(0xFF111111);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            _getTranslatedStepTitle(languageProvider),
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 30),

          // Graduate / Non-Graduate Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToggleButton(_getTranslatedGraduate(languageProvider),
                  isGraduate, languageProvider),
              const SizedBox(width: 30),
              _buildToggleButton(_getTranslatedNonGraduate(languageProvider),
                  !isGraduate, languageProvider),
            ],
          ),
          const SizedBox(height: 30),

          Text(
            _getTranslatedFormTitle(isGraduate, languageProvider),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 20),

          _dropdown<String>(
            label: _getTranslatedEducationLabel(languageProvider),
            value: selectedEducation,
            items: _educationOptions,
            labelOf: (value) => _getTranslatedLabel(value, languageProvider),
            onChanged: (val) => setState(() => selectedEducation = val),
            languageProvider: languageProvider,
          ),
          const SizedBox(height: 12),

          _dropdown<String>(
            label: _getTranslatedInstitutionLabel(languageProvider),
            value: selectedInstitution,
            items: _institutionOptions,
            labelOf: (value) => _getTranslatedLabel(value, languageProvider),
            onChanged: (val) => setState(() => selectedInstitution = val),
            languageProvider: languageProvider,
          ),
          const SizedBox(height: 12),

          _dropdown<String>(
            label: _getTranslatedCountryLabel(languageProvider),
            value: selectedCountry,
            items: _countryOptions,
            labelOf: (value) => _getTranslatedLabel(value, languageProvider),
            onChanged: (val) => setState(() => selectedCountry = val),
            languageProvider: languageProvider,
          ),
          const SizedBox(height: 12),

          _fieldLabel(_getTranslatedCityLabel(languageProvider)),
          TextFormField(
            controller: cityController,
            decoration: _decoration(
              hint: _getTranslatedCityHint(languageProvider),
              languageProvider: languageProvider,
            ),
          ),
          const SizedBox(height: 12),

          _fieldLabel(_getTranslatedGradeLabel(languageProvider)),
          TextFormField(
            controller: gradeController,
            decoration: _decoration(
              hint: _getTranslatedGradeHint(languageProvider),
              languageProvider: languageProvider,
            ),
          ),
          const SizedBox(height: 12),

          _dropdown<String>(
            label: _getTranslatedOccupationFieldLabel(languageProvider),
            value: selectedOccupationField,
            items: _occupationFieldOptions,
            labelOf: (value) => _getTranslatedLabel(value, languageProvider),
            onChanged: (val) => setState(() => selectedOccupationField = val),
            languageProvider: languageProvider,
          ),
          const SizedBox(height: 12),

          _dropdown<String>(
            label: _getTranslatedOccupationLabel(languageProvider),
            value: selectedOccupation,
            items: _occupationOptions,
            labelOf: (value) => _getTranslatedLabel(value, languageProvider),
            onChanged: (val) => setState(() => selectedOccupation = val),
            languageProvider: languageProvider,
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )
                  : Text(_getTranslatedSubmitButton(languageProvider)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
      String label, bool isSelected, LanguageProvider languageProvider) {
    return GestureDetector(
      onTap: _toggleForm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : _titleColor,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedStepTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الخطوة 6: البيانات التعليمية";
    if (lang == 'am') return "ደረጃ 6: የትምህርት መረጃ";
    return "Step 6: Educational Data";
  }

  String _getTranslatedGraduate(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "خريج";
    if (lang == 'am') return "ተመራቂ";
    return "Graduate";
  }

  String _getTranslatedNonGraduate(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "غير خريج";
    if (lang == 'am') return "አልተመረቀም";
    return "Non-Graduate";
  }

  String _getTranslatedFormTitle(
      bool isGraduate, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (isGraduate) {
      if (lang == 'ar') return "نموذج الخريج";
      if (lang == 'am') return "የተመራቂ ቅጽ";
      return "Graduate Form";
    } else {
      if (lang == 'ar') return "نموذج غير الخريج";
      if (lang == 'am') return "ያልተመረቀ ቅጽ";
      return "Non-Graduate Form";
    }
  }

  String _getTranslatedEducationLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أعلى مستوى تعليمي تم الحصول عليه";
    if (lang == 'am') return "ያገኘሁት ከፍተኛ የትምህርት ደረጃ";
    return "Highest Level of Education Received";
  }

  String _getTranslatedInstitutionLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اسم المؤسسة التعليمية";
    if (lang == 'am') return "የትምህርት ተቋም ስም";
    return "Institution Name";
  }

  String _getTranslatedCountryLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الدولة";
    if (lang == 'am') return "አገር";
    return "Country";
  }

  String _getTranslatedCityLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المدينة";
    if (lang == 'am') return "ከተማ";
    return "City";
  }

  String _getTranslatedCityHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المدينة";
    if (lang == 'am') return "ከተማ";
    return "City";
  }

  String _getTranslatedGradeLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "التقدير";
    if (lang == 'am') return "ደረጃ";
    return "Grade";
  }

  String _getTranslatedGradeHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "التقدير";
    if (lang == 'am') return "ደረጃ";
    return "Grade";
  }

  String _getTranslatedOccupationFieldLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "مجال العمل";
    if (lang == 'am') return "የሥራ መስክ";
    return "Occupation Field";
  }

  String _getTranslatedOccupationLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المهنة";
    if (lang == 'am') return "ሙያ";
    return "Occupation";
  }

  String _getTranslatedSubmitButton(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إرسال";
    if (lang == 'am') return "አስገባ";
    return "Submit";
  }

  // Error and success message translations
  String _getTranslatedNotLoggedIn(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المستخدم غير مسجل الدخول";
    if (lang == 'am') return "ተጠቃሚው አልገባም";
    return "User not logged in";
  }

  String _getTranslatedSuccessMessage(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم إرسال معلومات التعليم بنجاح";
    if (lang == 'am') return "የትምህርት መረጃ በተሳካ ሁኔታ ቀርቧል";
    return "Education info submitted successfully";
  }

  String _getTranslatedErrorMessage(
      String error, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "خطأ: $error";
    if (lang == 'am') return "ስህተት: $error";
    return "Error: $error";
  }
}
