import 'package:flutter/material.dart';
import 'package:marrir/services/Employee/cv_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class ReferencesForm extends StatefulWidget {
  final VoidCallback? onSuccess;
  const ReferencesForm({super.key, this.onSuccess});

  @override
  State<ReferencesForm> createState() => _ReferencesFormState();
}

class _ReferencesFormState extends State<ReferencesForm> {
  DateTime? selectedDate;
  String? selectedGender;
  String? selectedCountry;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController subCityController = TextEditingController();
  final TextEditingController poBoxController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController zoneController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();

  bool isLoading = false;

  // Design tokens
  static const _titleColor = Color(0xFF111111);
  static const _labelColor = Color(0xFF111111);
  static const _hintColor = Color(0xFF8E8E93);
  static const _borderColor = Color(0xFFD1D1D6);
  static const _fillColor = Colors.white;
  static const _buttonColor = Color.fromRGBO(142, 198, 214, 1);

  // Dropdown options
  static const List<String> _genderItems = ['Male', 'Female', 'Other'];
  static const List<String> _countryItems = ['Ethiopia', 'USA', 'Other'];

  // Get translated labels for display
  String _getTranslatedLabel(String value, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    // Gender translations
    if (value == "Male") {
      if (lang == 'ar') return "ذكر";
      if (lang == 'am') return "ወንድ";
      return "Male";
    }
    if (value == "Female") {
      if (lang == 'ar') return "أنثى";
      if (lang == 'am') return "ሴት";
      return "Female";
    }
    if (value == "Other") {
      if (lang == 'ar') return "أخرى";
      if (lang == 'am') return "ሌላ";
      return "Other";
    }

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

  Future<void> _pickDate(LanguageProvider languageProvider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
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
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // 🔹 Submit Reference Data via Service
  Future<void> _submitReference(LanguageProvider languageProvider) async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');
      final String? token = prefs.getString('access_token');

      if (token == null || userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getTranslatedNotLoggedIn(languageProvider))),
        );
        setState(() => isLoading = false);
        return;
      }

      final result = await CVService.submitReference(
        userId: userId,
        token: token,
        name: nameController.text,
        phoneNumber: phoneController.text,
        email: emailController.text.isNotEmpty ? emailController.text : null,
        birthDate: selectedDate?.toIso8601String(),
        gender: selectedGender,
        country: selectedCountry,
        city: cityController.text,
        subCity: subCityController.text,
        zone: zoneController.text,
        houseNo: houseNumberController.text,
        poBox: int.tryParse(poBoxController.text),
        summary: summaryController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTranslatedSuccessMessage(languageProvider))),
      );

      widget.onSuccess?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                _getTranslatedErrorMessage(e.toString(), languageProvider))),
      );
    }

    setState(() => isLoading = false);
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
          _fieldLabel(_getTranslatedNameLabel(languageProvider)),
          TextField(
            controller: nameController,
            decoration: _decoration(
              hint: _getTranslatedNameHint(languageProvider),
              languageProvider: languageProvider,
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel(_getTranslatedEmailLabel(languageProvider)),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _decoration(
              hint: _getTranslatedEmailHint(languageProvider),
              languageProvider: languageProvider,
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel(_getTranslatedPhoneLabel(languageProvider)),
          _buildPhoneField(languageProvider),
          const SizedBox(height: 16),
          _fieldLabel(_getTranslatedDobLabel(languageProvider)),
          _buildDatePicker(languageProvider),
          const SizedBox(height: 16),
          _dropdown<String>(
            label: _getTranslatedGenderLabel(languageProvider),
            value: selectedGender,
            items: _genderItems,
            labelOf: (value) => _getTranslatedLabel(value, languageProvider),
            onChanged: (v) => setState(() => selectedGender = v),
            languageProvider: languageProvider,
          ),
          const SizedBox(height: 16),
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
          TextField(
            controller: cityController,
            decoration: _decoration(
              hint: _getTranslatedCityHint(languageProvider),
              languageProvider: languageProvider,
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel(_getTranslatedSubCityLabel(languageProvider)),
          TextField(
            controller: subCityController,
            decoration: _decoration(
              hint: _getTranslatedSubCityHint(languageProvider),
              languageProvider: languageProvider,
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel(_getTranslatedZoneLabel(languageProvider)),
          TextField(
            controller: zoneController,
            decoration: _decoration(
              hint: _getTranslatedZoneHint(languageProvider),
              languageProvider: languageProvider,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(_getTranslatedPoBoxLabel(languageProvider)),
                    TextField(
                      controller: poBoxController,
                      keyboardType: TextInputType.number,
                      decoration: _decoration(
                        hint: _getTranslatedPoBoxHint(languageProvider),
                        languageProvider: languageProvider,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(
                        _getTranslatedHouseNumberLabel(languageProvider)),
                    TextField(
                      controller: houseNumberController,
                      decoration: _decoration(
                        hint: _getTranslatedHouseNumberHint(languageProvider),
                        languageProvider: languageProvider,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _fieldLabel(_getTranslatedSummaryLabel(languageProvider)),
          TextField(
            controller: summaryController,
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
              onPressed:
                  isLoading ? null : () => _submitReference(languageProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _getTranslatedSubmitButton(languageProvider),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(LanguageProvider languageProvider) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: _borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('+251'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: _decoration(
              hint: _getTranslatedPhoneHint(languageProvider),
              languageProvider: languageProvider,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(LanguageProvider languageProvider) {
    return GestureDetector(
      onTap: () => _pickDate(languageProvider),
      child: AbsorbPointer(
        child: TextField(
          decoration: _decoration(
            hint: selectedDate == null
                ? _getTranslatedDateHint(languageProvider)
                : "${selectedDate!.month.toString().padLeft(2, '0')}/"
                    "${selectedDate!.day.toString().padLeft(2, '0')}/"
                    "${selectedDate!.year}",
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: _hintColor,
              size: 18,
            ),
            languageProvider: languageProvider,
          ),
        ),
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedStepTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الخطوة 9: المراجع";
    if (lang == 'am') return "ደረጃ 9: ማጣቀሻዎች";
    return "Step 9: References";
  }

  String _getTranslatedNameLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الاسم";
    if (lang == 'am') return "ስም";
    return "Name";
  }

  String _getTranslatedNameHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل الاسم";
    if (lang == 'am') return "ስም ያስገቡ";
    return "Enter Name";
  }

  String _getTranslatedEmailLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "البريد الإلكتروني";
    if (lang == 'am') return "ኢሜል";
    return "Email";
  }

  String _getTranslatedEmailHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل البريد الإلكتروني";
    if (lang == 'am') return "ኢሜል ያስገቡ";
    return "Enter Email";
  }

  String _getTranslatedPhoneLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "رقم الهاتف";
    if (lang == 'am') return "ስልክ ቁጥር";
    return "Phone Number";
  }

  String _getTranslatedPhoneHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل رقم الهاتف";
    if (lang == 'am') return "ስልክ ቁጥር ያስገቡ";
    return "Enter Phone Number";
  }

  String _getTranslatedDobLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تاريخ الميلاد";
    if (lang == 'am') return "የትውልድ ቀን";
    return "Date of Birth";
  }

  String _getTranslatedDateHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "mm/dd/yyyy";
    if (lang == 'am') return "ወር/ቀን/ዓመት";
    return "mm/dd/yyyy";
  }

  String _getTranslatedGenderLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر الجنس";
    if (lang == 'am') return "ጾታ ይምረጡ";
    return "Select Gender";
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

  String _getTranslatedSubCityLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المدينة الفرعية";
    if (lang == 'am') return "ክፍለ ከተማ";
    return "Sub City";
  }

  String _getTranslatedSubCityHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل المدينة الفرعية";
    if (lang == 'am') return "ክፍለ ከተማ ያስገቡ";
    return "Enter Sub City";
  }

  String _getTranslatedZoneLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المنطقة";
    if (lang == 'am') return "ዞን";
    return "Zone";
  }

  String _getTranslatedZoneHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل المنطقة";
    if (lang == 'am') return "ዞን ያስገቡ";
    return "Enter Zone";
  }

  String _getTranslatedPoBoxLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "صندوق البريد";
    if (lang == 'am') return "ፖስታ ሳጥን";
    return "P.O. Box";
  }

  String _getTranslatedPoBoxHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل صندوق البريد";
    if (lang == 'am') return "ፖስታ ሳጥን ያስገቡ";
    return "Enter P.O.Box";
  }

  String _getTranslatedHouseNumberLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "رقم المنزل";
    if (lang == 'am') return "የቤት ቁጥር";
    return "House Number";
  }

  String _getTranslatedHouseNumberHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل رقم المنزل";
    if (lang == 'am') return "የቤት ቁጥር ያስገቡ";
    return "Enter House Number";
  }

  String _getTranslatedSummaryLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "ملخص المرجع";
    if (lang == 'am') return "የማጣቀሻ ማጠቃለያ";
    return "Reference Summary";
  }

  String _getTranslatedSummaryHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل الملخص";
    if (lang == 'am') return "ማጠቃለያ ያስገቡ";
    return "Enter summary";
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
    if (lang == 'ar') return "المستخدم غير مسجل الدخول!";
    if (lang == 'am') return "ተጠቃሚው አልገባም!";
    return "User not logged in!";
  }

  String _getTranslatedSuccessMessage(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم إرسال المرجع بنجاح!";
    if (lang == 'am') return "ማጣቀሻ በተሳካ ሁኔታ ቀርቧል!";
    return "Reference submitted successfully!";
  }

  String _getTranslatedErrorMessage(
      String error, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "فشل الإرسال: $error";
    if (lang == 'am') return "ማስገባት አልተሳካም: $error";
    return "Submission failed: $error";
  }
}
