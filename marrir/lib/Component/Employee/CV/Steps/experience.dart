import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/Employee/cv_service.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class PreviousExperienceForm extends StatefulWidget {
  const PreviousExperienceForm({super.key});

  @override
  State<PreviousExperienceForm> createState() => _PreviousExperienceFormState();
}

class _PreviousExperienceFormState extends State<PreviousExperienceForm> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  String? selectedCountry;
  bool isSubmitting = false;

  // Design tokens
  static const _titleColor = Color(0xFF111111);
  static const _labelColor = Color(0xFF111111);
  static const _hintColor = Color(0xFF8E8E93);
  static const _borderColor = Color(0xFFD1D1D6);
  static const _fillColor = Colors.white;
  static const _buttonColor = Color.fromRGBO(142, 198, 214, 1);

  // Country options
  static const List<String> _countryItems = [
    "Ethiopia",
    "USA",
    "UK",
    "Canada",
    "Germany",
    "UAE",
    "Other",
  ];

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    _cityController.dispose();
    _companyController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  // Get translated labels for display
  String _getTranslatedLabel(String value, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    // Country translations
    if (value == "Ethiopia") {
      if (lang == 'ar') return "إثيوبيا";
      if (lang == 'am') return "ኢትዮጵያ";
      return "Ethiopia";
    }
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
    if (value == "Germany") {
      if (lang == 'ar') return "ألمانيا";
      if (lang == 'am') return "ጀርመን";
      return "Germany";
    }
    if (value == "UAE") {
      if (lang == 'ar') return "الإمارات";
      if (lang == 'am') return "የተባበሩት ዓረብ ኤምሬትስ";
      return "UAE";
    }
    if (value == "Other") {
      if (lang == 'ar') return "أخرى";
      if (lang == 'am') return "ሌላ";
      return "Other";
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
            fontSize: 16,
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
        const SizedBox(height: 8),
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
                color: _hintColor,
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

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
    LanguageProvider languageProvider,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _buttonColor,
              onPrimary: Colors.white,
              onSurface: _titleColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      controller.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _submitExperience(LanguageProvider languageProvider) async {
    if (selectedCountry == null ||
        _cityController.text.isEmpty ||
        _companyController.text.isEmpty ||
        _fromDateController.text.isEmpty ||
        _toDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTranslatedFillAllFields(languageProvider))),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');
      final String? token = prefs.getString('access_token');

      if (token == null || userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getTranslatedAuthRequired(languageProvider))),
        );
        return;
      }

      final res = await CVService.submitWorkExperience(
        userId: userId,
        token: token,
        companyName: _companyController.text,
        country: selectedCountry!,
        city: _cityController.text,
        startDate: _fromDateController.text,
        endDate: _toDateController.text,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            _getTranslatedStepTitle(languageProvider),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _titleColor,
            ),
          ),
          const SizedBox(height: 30),
          _dropdown<String>(
            label: _getTranslatedCountryLabel(languageProvider),
            value: selectedCountry,
            items: _countryItems,
            labelOf: (value) => _getTranslatedLabel(value, languageProvider),
            onChanged: (v) => setState(() => selectedCountry = v),
            languageProvider: languageProvider,
          ),
          const SizedBox(height: 16),
          _fieldLabel(_getTranslatedCityLabel(languageProvider)),
          const SizedBox(height: 8),
          TextField(
            controller: _cityController,
            decoration: _decoration(
              hint: _getTranslatedCityHint(languageProvider),
              languageProvider: languageProvider,
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel(_getTranslatedCompanyLabel(languageProvider)),
          const SizedBox(height: 8),
          TextField(
            controller: _companyController,
            decoration: _decoration(
              hint: _getTranslatedCompanyHint(languageProvider),
              languageProvider: languageProvider,
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel(_getTranslatedFromLabel(languageProvider)),
          const SizedBox(height: 8),
          TextField(
            controller: _fromDateController,
            readOnly: true,
            onTap: () =>
                _pickDate(context, _fromDateController, languageProvider),
            decoration: _decoration(
              hint: _getTranslatedDateHint(languageProvider),
              suffixIcon: IconButton(
                onPressed: () =>
                    _pickDate(context, _fromDateController, languageProvider),
                icon: const Icon(
                  Icons.calendar_today,
                  color: _hintColor,
                  size: 18,
                ),
              ),
              languageProvider: languageProvider,
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel(_getTranslatedToLabel(languageProvider)),
          const SizedBox(height: 8),
          TextField(
            controller: _toDateController,
            readOnly: true,
            onTap: () =>
                _pickDate(context, _toDateController, languageProvider),
            decoration: _decoration(
              hint: _getTranslatedDateHint(languageProvider),
              suffixIcon: IconButton(
                onPressed: () =>
                    _pickDate(context, _toDateController, languageProvider),
                icon: const Icon(
                  Icons.calendar_today,
                  color: _hintColor,
                  size: 18,
                ),
              ),
              languageProvider: languageProvider,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isSubmitting
                  ? null
                  : () => _submitExperience(languageProvider),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: _buttonColor,
                side: const BorderSide(color: _buttonColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _getTranslatedAddExperience(languageProvider),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          _fieldLabel(_getTranslatedPreviousWorkLabel(languageProvider)),
          const SizedBox(height: 8),
          TextField(
            controller: _summaryController,
            maxLines: 4,
            decoration: _decoration(
              hint: _getTranslatedSummaryHint(languageProvider),
              languageProvider: languageProvider,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () => _submitExperience(languageProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _getTranslatedSubmitButton(languageProvider),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedStepTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الخطوة 8: الخبرة السابقة والمستندات";
    if (lang == 'am') return "ደረጃ 8: ቀደምት ልምድ እና ሰነዶች";
    return "Step 8: Previous Experience and Documents";
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
    if (lang == 'ar') return "أدخل المدينة";
    if (lang == 'am') return "ከተማ ያስገቡ";
    return "Enter City";
  }

  String _getTranslatedCompanyLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الشركة";
    if (lang == 'am') return "ኩባንያ";
    return "Company";
  }

  String _getTranslatedCompanyHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل اسم الشركة";
    if (lang == 'am') return "የኩባንያ ስም ያስገቡ";
    return "Enter Company Name";
  }

  String _getTranslatedFromLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "من";
    if (lang == 'am') return "ከ";
    return "From";
  }

  String _getTranslatedToLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إلى";
    if (lang == 'am') return "ወደ";
    return "To";
  }

  String _getTranslatedDateHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر التاريخ";
    if (lang == 'am') return "ቀን ይምረጡ";
    return "Select Date";
  }

  String _getTranslatedAddExperience(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إضافة خبرة";
    if (lang == 'am') return "ልምድ ያክሉ";
    return "Add Experience";
  }

  String _getTranslatedPreviousWorkLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "العمل السابق";
    if (lang == 'am') return "ቀደምት ሥራ";
    return "Previous Work";
  }

  String _getTranslatedSummaryHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل ملخص للمدخلات أعلاه";
    if (lang == 'am') return "ከላይ ለገቡት ማጠቃለያ ያስገቡ";
    return "Enter summary of the above input";
  }

  String _getTranslatedSubmitButton(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إرسال";
    if (lang == 'am') return "አስገባ";
    return "Submit";
  }

  // Error and success message translations
  String _getTranslatedFillAllFields(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "يرجى ملء جميع الحقول";
    if (lang == 'am') return "እባክዎ ሁሉንም ሕዋሶች ይሙሉ";
    return "Please fill all fields";
  }

  String _getTranslatedAuthRequired(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المصادقة مطلوبة";
    if (lang == 'am') return "ማረጋገጫ ያስፈልጋል";
    return "Authentication required";
  }

  String _getTranslatedSuccessMessage(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم إرسال الخبرة بنجاح";
    if (lang == 'am') return "ልምድ በተሳካ ሁኔታ ቀርቧል";
    return "Experience submitted successfully";
  }

  String _getTranslatedErrorMessage(
      String error, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "خطأ: $error";
    if (lang == 'am') return "ስህተት: $error";
    return "Error: $error";
  }
}
