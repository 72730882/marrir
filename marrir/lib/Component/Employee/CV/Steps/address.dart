import 'package:flutter/material.dart';
import 'package:marrir/services/Employee/cv_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class AddressInformationStep extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onNextStep;
  const AddressInformationStep(
      {super.key, required this.onSuccess, required this.onNextStep});

  @override
  State<AddressInformationStep> createState() => _AddressInformationStepState();
}

class _AddressInformationStepState extends State<AddressInformationStep> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _regionCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _street2Ctrl = TextEditingController();
  final _street3Ctrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _houseNumberCtrl = TextEditingController();
  final _poBoxCtrl = TextEditingController();

  String? _country;

  bool _isLoading = false;

  @override
  void dispose() {
    _regionCtrl.dispose();
    _cityCtrl.dispose();
    _streetCtrl.dispose();
    _street2Ctrl.dispose();
    _street3Ctrl.dispose();
    _zipCtrl.dispose();
    _houseNumberCtrl.dispose();
    _poBoxCtrl.dispose();
    super.dispose();
  }

  static const _titleColor = Color(0xFF1D2433);
  static const _labelColor = Color(0xFF3C4555);
  static const _hintColor = Color(0xFF9AA3B2);
  static const _borderColor = Color(0xFFE6E9EF);
  static const _fillColor = Colors.white;
  static const _iconMuted = Color(0xFF667085);
  static const _buttonTeal = Color(0xFF8EC6D6);

  // Country options
  static const List<String> _countryItems = [
    "Ethiopia",
    "Kenya",
    "Eritrea",
    "Somalia",
    "Sudan"
  ];

  // Get translated labels for display
  String _getTranslatedLabel(String value, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    // Country translations
    if (value == "Ethiopia") {
      if (lang == 'ar') return "إثيوبيا";
      if (lang == 'am') return "ኢትዮጵያ";
      return "Ethiopia";
    }
    if (value == "Kenya") {
      if (lang == 'ar') return "كينيا";
      if (lang == 'am') return "ኬንያ";
      return "Kenya";
    }
    if (value == "Eritrea") {
      if (lang == 'ar') return "إريتريا";
      if (lang == 'am') return "ኤርትራ";
      return "Eritrea";
    }
    if (value == "Somalia") {
      if (lang == 'ar') return "الصومال";
      if (lang == 'am') return "ሶማሊያ";
      return "Somalia";
    }
    if (value == "Sudan") {
      if (lang == 'ar') return "السودان";
      if (lang == 'am') return "ሱዳን";
      return "Sudan";
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

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token") ?? "";
      final userId = prefs.getString("user_id") ?? "";

      if (token.isEmpty || userId.isEmpty) {
        throw Exception(_getTranslatedNotLoggedIn(languageProvider));
      }

      final data = await CVService.submitAddressInfo(
        userId: userId,
        token: token,
        country: _country ?? "",
        region: _regionCtrl.text,
        city: _cityCtrl.text,
        street: _streetCtrl.text,
        street2: _street2Ctrl.text.isNotEmpty ? _street2Ctrl.text : null,
        street3: _street3Ctrl.text.isNotEmpty ? _street3Ctrl.text : null,
        zipCode: _zipCtrl.text.isNotEmpty ? _zipCtrl.text : null,
        houseNumber:
            _houseNumberCtrl.text.isNotEmpty ? _houseNumberCtrl.text : null,
        poBox: _poBoxCtrl.text.isNotEmpty ? _poBoxCtrl.text : null,
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
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              _getTranslatedStepTitle(languageProvider),
              style: const TextStyle(
                fontSize: 16,
                color: _titleColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _getTranslatedSectionTitle(languageProvider),
              style: const TextStyle(
                fontSize: 13,
                color: _labelColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Country
            _dropdown<String>(
              label: _getTranslatedCountryLabel(languageProvider),
              value: _country,
              items: _countryItems,
              labelOf: (value) => _getTranslatedLabel(value, languageProvider),
              onChanged: (v) => setState(() => _country = v),
              languageProvider: languageProvider,
            ),
            const SizedBox(height: 12),

            // Region
            _fieldLabel(_getTranslatedRegionLabel(languageProvider)),
            TextFormField(
              controller: _regionCtrl,
              decoration: _decoration(
                hint: _getTranslatedRegionHint(languageProvider),
                languageProvider: languageProvider,
              ),
            ),
            const SizedBox(height: 12),

            // City
            _fieldLabel(_getTranslatedCityLabel(languageProvider)),
            TextFormField(
              controller: _cityCtrl,
              decoration: _decoration(
                hint: _getTranslatedCityHint(languageProvider),
                languageProvider: languageProvider,
              ),
            ),
            const SizedBox(height: 12),

            // Street
            _fieldLabel(_getTranslatedStreetLabel(languageProvider)),
            TextFormField(
              controller: _streetCtrl,
              decoration: _decoration(
                hint: _getTranslatedStreetHint(languageProvider),
                languageProvider: languageProvider,
              ),
            ),
            const SizedBox(height: 12),

            // Street 2
            _fieldLabel(_getTranslatedStreet2Label(languageProvider)),
            TextFormField(
              controller: _street2Ctrl,
              decoration: _decoration(
                hint: _getTranslatedStreet2Hint(languageProvider),
                languageProvider: languageProvider,
              ),
            ),
            const SizedBox(height: 12),

            // Street 3
            _fieldLabel(_getTranslatedStreet3Label(languageProvider)),
            TextFormField(
              controller: _street3Ctrl,
              decoration: _decoration(
                hint: _getTranslatedStreet3Hint(languageProvider),
                languageProvider: languageProvider,
              ),
            ),
            const SizedBox(height: 12),

            // Zip + House Number
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel(_getTranslatedZipLabel(languageProvider)),
                      TextFormField(
                        controller: _zipCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _decoration(
                          hint: _getTranslatedZipHint(languageProvider),
                          languageProvider: languageProvider,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel(
                          _getTranslatedHouseNumberLabel(languageProvider)),
                      TextFormField(
                        controller: _houseNumberCtrl,
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
            const SizedBox(height: 12),

            // P.O.Box
            _fieldLabel(_getTranslatedPoBoxLabel(languageProvider)),
            TextFormField(
              controller: _poBoxCtrl,
              keyboardType: TextInputType.number,
              decoration: _decoration(
                hint: _getTranslatedPoBoxHint(languageProvider),
                languageProvider: languageProvider,
              ),
            ),
            const SizedBox(height: 20),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
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
                onPressed: _isLoading ? null : _submitForm,
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
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedStepTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الخطوة 4: معلومات العنوان";
    if (lang == 'am') return "ደረጃ 4: የአድራሻ መረጃ";
    return "Step 4: Address Information";
  }

  String _getTranslatedSectionTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "معلومات العنوان";
    if (lang == 'am') return "የአድራሻ መረጃ";
    return "Address Information";
  }

  String _getTranslatedCountryLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الدولة";
    if (lang == 'am') return "አገር";
    return "Country";
  }

  String _getTranslatedRegionLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المنطقة";
    if (lang == 'am') return "ክልል";
    return "Region";
  }

  String _getTranslatedRegionHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل المنطقة";
    if (lang == 'am') return "ክልል ያስገቡ";
    return "Enter Region";
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

  String _getTranslatedStreetLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الشارع";
    if (lang == 'am') return "ጎዳና";
    return "Street";
  }

  String _getTranslatedStreetHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل اسم الشارع";
    if (lang == 'am') return "የጎዳና ስም ያስገቡ";
    return "Enter Street";
  }

  String _getTranslatedStreet2Label(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الشارع 2";
    if (lang == 'am') return "ጎዳና 2";
    return "Street 2";
  }

  String _getTranslatedStreet2Hint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل الشارع 2";
    if (lang == 'am') return "ጎዳና 2 ያስገቡ";
    return "Enter Street 2";
  }

  String _getTranslatedStreet3Label(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الشارع 3";
    if (lang == 'am') return "ጎዳና 3";
    return "Street 3";
  }

  String _getTranslatedStreet3Hint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل الشارع 3";
    if (lang == 'am') return "ጎዳና 3 ያስገቡ";
    return "Enter Street 3";
  }

  String _getTranslatedZipLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الرمز البريدي";
    if (lang == 'am') return "ፖስታ ኮድ";
    return "Zip Code";
  }

  String _getTranslatedZipHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل الرمز البريدي";
    if (lang == 'am') return "ፖስታ ኮድ ያስገቡ";
    return "Enter Zip Code";
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

  String _getTranslatedPoBoxLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "صندوق البريد";
    if (lang == 'am') return "ፖስታ ሳጥን";
    return "P.O.Box";
  }

  String _getTranslatedPoBoxHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل صندوق البريد";
    if (lang == 'am') return "ፖስታ ሳጥን ያስገቡ";
    return "Enter P.O.Box";
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
    if (lang == 'ar') return "تم إرسال معلومات العنوان بنجاح";
    if (lang == 'am') return "የአድራሻ መረጃ በተሳካ ሁኔታ ቀርቧል";
    return "Address information submitted successfully";
  }

  String _getTranslatedErrorMessage(
      String error, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "خطأ: $error";
    if (lang == 'am') return "ስህተት: $error";
    return "Error: $error";
  }
}
