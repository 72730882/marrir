import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/Employee/cv_service.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class PersonalInformationStep extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onNextStep;
  const PersonalInformationStep(
      {super.key, required this.onSuccess, required this.onNextStep});

  @override
  State<PersonalInformationStep> createState() =>
      _PersonalInformationStepState();
}

class _PersonalInformationStepState extends State<PersonalInformationStep> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _amhNameCtrl = TextEditingController();
  final _engNameCtrl = TextEditingController();
  final _arbNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _childrenCtrl = TextEditingController(text: "0");
  final _dobCtrl = TextEditingController();

  // Dropdown values
  String? _sex;
  String _countryCode = "+251";
  String? _maritalStatus;
  String? _skinTone;
  String? _placeOfBirth = "Ethiopia (ETH)";
  String? _religion;

  bool _isLoading = false;

  @override
  void dispose() {
    _amhNameCtrl.dispose();
    _engNameCtrl.dispose();
    _arbNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _childrenCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  // Design tokens
  static const _titleColor = Color(0xFF1D2433);
  static const _labelColor = Color(0xFF3C4555);
  static const _hintColor = Color(0xFF9AA3B2);
  static const _borderColor = Color(0xFFE6E9EF);
  static const _fillColor = Colors.white;
  static const _iconMuted = Color(0xFF667085);
  static const _buttonTeal = Color(0xFF8EC6D6);

  // Canonical items for dropdowns
  static const List<String> _sexItems = ["male", "female"];
  static const List<String> _maritalItems = [
    "single",
    "married",
    "divorced",
    "widowed",
    "separated",
  ];
  static const List<String> _skinToneItems = [
    "very_light",
    "light",
    "medium",
    "dark",
    "very_dark",
  ];
  static const List<String> _birthPlaceItems = [
    "Ethiopia (ETH)",
    "Kenya (KEN)",
    "Eritrea (ERI)",
    "Somalia (SOM)",
  ];
  static const List<String> _religionItems = [
    "none",
    "church_of_the_east",
    "oriental_orthodoxy",
    "eastern_orthodoxy",
    "roman_catholicism",
    "protestantism",
    "islam",
    "buddhism",
  ];
  static const List<String> _countryCodes = [
    "+251",
    "+971",
    "+1",
    "+44",
    "+61"
  ];

  // Get translated labels for display
  String _getTranslatedLabel(String value, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    // Sex translations
    if (value == "male") {
      if (lang == 'ar') return "ذكر";
      if (lang == 'am') return "ወንድ";
      return "Male";
    }
    if (value == "female") {
      if (lang == 'ar') return "أنثى";
      if (lang == 'am') return "ሴት";
      return "Female";
    }

    // Marital status translations
    if (value == "single") {
      if (lang == 'ar') return "أعزب";
      if (lang == 'am') return "ያላገባ";
      return "Single";
    }
    if (value == "married") {
      if (lang == 'ar') return "متزوج";
      if (lang == 'am') return "ያገባ";
      return "Married";
    }
    if (value == "divorced") {
      if (lang == 'ar') return "مطلق";
      if (lang == 'am') return "የተፋታ";
      return "Divorced";
    }
    if (value == "widowed") {
      if (lang == 'ar') return "أرمل";
      if (lang == 'am') return "የተሰወረ";
      return "Widowed";
    }
    if (value == "separated") {
      if (lang == 'ar') return "منفصل";
      if (lang == 'am') return "የተለያየ";
      return "Separated";
    }

    // Skin tone translations
    if (value == "very_light") {
      if (lang == 'ar') return "فاتح جداً";
      if (lang == 'am') return "በጣም ቀላል";
      return "Very Light";
    }
    if (value == "light") {
      if (lang == 'ar') return "فاتح";
      if (lang == 'am') return "ቀላል";
      return "Light";
    }
    if (value == "medium") {
      if (lang == 'ar') return "متوسط";
      if (lang == 'am') return "መካከለኛ";
      return "Medium";
    }
    if (value == "dark") {
      if (lang == 'ar') return "غامق";
      if (lang == 'am') return "ጥቁር";
      return "Dark";
    }
    if (value == "very_dark") {
      if (lang == 'ar') return "غامق جداً";
      if (lang == 'am') return "በጣም ጥቁር";
      return "Very Dark";
    }

    // Religion translations
    if (value == "none") {
      if (lang == 'ar') return "لا دين";
      if (lang == 'am') return "ሃይማኖት የለም";
      return "None";
    }
    if (value == "church_of_the_east") {
      if (lang == 'ar') return "كنيسة المشرق";
      if (lang == 'am') return "የምስራቅ ቤተክርስቲያን";
      return "Church of the East";
    }
    if (value == "oriental_orthodoxy") {
      if (lang == 'ar') return "الأرثوذكسية المشرقية";
      if (lang == 'am') return "ኦርቶዶክስ ተዋሕዶ";
      return "Oriental Orthodoxy";
    }
    if (value == "eastern_orthodoxy") {
      if (lang == 'ar') return "الأرثوذكسية الشرقية";
      if (lang == 'am') return "ምስራቃዊ ኦርቶዶክስ";
      return "Eastern Orthodoxy";
    }
    if (value == "roman_catholicism") {
      if (lang == 'ar') return "الكاثوليكية الرومانية";
      if (lang == 'am') return "ሮማን ካቶሊክ";
      return "Roman Catholicism";
    }
    if (value == "protestantism") {
      if (lang == 'ar') return "البروتستانتية";
      if (lang == 'am') return "ፕሮቴስታንት";
      return "Protestantism";
    }
    if (value == "islam") {
      if (lang == 'ar') return "الإسلام";
      if (lang == 'am') return "እስልምና";
      return "Islam";
    }
    if (value == "buddhism") {
      if (lang == 'ar') return "البوذية";
      if (lang == 'am') return "ቡዲስት";
      return "Buddhism";
    }

    // For country codes and birth places, return as-is
    return value;
  }

  String _getTranslatedHint(String label, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر $label";
    if (lang == 'am') return "$label ይምረጡ";
    return "Select $label";
  }

  // Ensure value passed to DropdownButtonFormField is present in items or null
  Object? _safeValue<T>(T? value, List<T> items) {
    if (value == null) return null;
    return items.contains(value) ? value : null;
  }

  // Normalize skin tone values
  String? _normalizeSkinTone(String? v) {
    if (v == null) return null;
    final s = v.trim().toLowerCase().replaceAll(' ', '_');
    const allowed = {
      'very_light',
      'light',
      'medium',
      'dark',
      'very_dark',
    };
    final mapped = <String, String>{
          'tan': 'medium',
          'very light': 'very_light',
          'very dark': 'very_dark',
          'medium_': 'medium',
          'Medium': 'medium',
          'Light': 'light',
          'Dark': 'dark',
        }[s] ??
        s;
    return allowed.contains(mapped) ? mapped : null;
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

  Future<void> _pickDate(LanguageProvider languageProvider) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _buttonTeal,
              onPrimary: Colors.white,
              onSurface: _titleColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobCtrl.text =
          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
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

      // Map dropdown values to backend enum
      final sexValue = (_sex ?? "male").toLowerCase();
      final maritalValue = (_maritalStatus ?? "single").toLowerCase();
      final skinToneValue = (_skinTone ?? "medium").toLowerCase();

      String religionValue = (_religion ?? "none").toLowerCase();
      if (religionValue == "muslim") religionValue = "islam";
      if (religionValue == "christian") religionValue = "protestantism";

      // Fix phone
      final phoneRaw = _phoneCtrl.text.trim();
      final phoneValue =
          phoneRaw.startsWith('+') ? phoneRaw : '$_countryCode$phoneRaw';

      final childrenValue = int.tryParse(_childrenCtrl.text) ?? 0;

      final res = await CVService.submitPersonalInfo(
        userId: userId,
        token: token,
        amharicFullName: _amhNameCtrl.text.trim(),
        englishFullName: _engNameCtrl.text.trim(),
        arabicFullName: _arbNameCtrl.text.trim(),
        sex: sexValue,
        email: _emailCtrl.text.trim(),
        phone: phoneValue,
        height: _heightCtrl.text.isEmpty ? "0" : _heightCtrl.text.trim(),
        weight: _weightCtrl.text.isEmpty ? "0" : _weightCtrl.text.trim(),
        maritalStatus: maritalValue,
        children: childrenValue.toString(),
        skinTone: skinToneValue,
        placeOfBirth: _placeOfBirth ?? "Ethiopia (ETH)",
        dateOfBirth: _dobCtrl.text,
        religion: religionValue,
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

    // If any of these values were prefilled elsewhere and don't match items, _safeValue will null them to avoid the crash.
    final sexValue = _safeValue(_sex, _sexItems);
    final maritalValue = _safeValue(_maritalStatus, _maritalItems);
    final skinToneValue =
        _safeValue(_normalizeSkinTone(_skinTone), _skinToneItems);
    final birthPlaceValue = _safeValue(_placeOfBirth, _birthPlaceItems);
    final religionValue = _safeValue(_religion, _religionItems);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 8),
            _fieldLabel(_getTranslatedAmharicNameLabel(languageProvider)),
            TextFormField(
              controller: _amhNameCtrl,
              decoration: _decoration(
                hint: _getTranslatedAmharicNameHint(languageProvider),
                languageProvider: languageProvider,
              ),
            ),
            const SizedBox(height: 12),
            _fieldLabel(_getTranslatedEnglishNameLabel(languageProvider)),
            TextFormField(
              controller: _engNameCtrl,
              decoration: _decoration(
                hint: _getTranslatedEnglishNameHint(languageProvider),
                languageProvider: languageProvider,
              ),
            ),
            const SizedBox(height: 12),
            _fieldLabel(_getTranslatedArabicNameLabel(languageProvider)),
            TextFormField(
              controller: _arbNameCtrl,
              decoration: _decoration(
                hint: _getTranslatedArabicNameHint(languageProvider),
                languageProvider: languageProvider,
              ),
            ),
            const SizedBox(height: 12),
            _dropdown<String>(
              label: _getTranslatedSexLabel(languageProvider),
              value: sexValue as String?,
              items: _sexItems,
              labelOf: (value) => _getTranslatedLabel(value, languageProvider),
              onChanged: (v) => setState(() => _sex = v),
              languageProvider: languageProvider,
            ),
            const SizedBox(height: 12),
            _fieldLabel(_getTranslatedEmailLabel(languageProvider)),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _decoration(
                hint: _getTranslatedEmailHint(languageProvider),
                languageProvider: languageProvider,
              ),
            ),
            const SizedBox(height: 12),
            _fieldLabel(_getTranslatedPhoneLabel(languageProvider)),
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: DropdownButtonFormField<String>(
                    value: _safeValue(_countryCode, _countryCodes) as String?,
                    items: _countryCodes
                        .map(
                          (code) => DropdownMenuItem(
                            value: code,
                            child: Text(
                              code,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _labelColor,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      if (v != null) _countryCode = v;
                    }),
                    decoration: _decoration(
                      hint: _getTranslatedCodeHint(languageProvider),
                      languageProvider: languageProvider,
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _iconMuted,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: _decoration(
                      hint: _getTranslatedPhoneHint(languageProvider),
                      languageProvider: languageProvider,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel(_getTranslatedHeightLabel(languageProvider)),
                      TextFormField(
                        controller: _heightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _decoration(
                          hint: _getTranslatedHeightHint(languageProvider),
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
                      _fieldLabel(_getTranslatedWeightLabel(languageProvider)),
                      TextFormField(
                        controller: _weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _decoration(
                          hint: _getTranslatedWeightHint(languageProvider),
                          languageProvider: languageProvider,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _dropdown<String>(
              label: _getTranslatedMaritalStatusLabel(languageProvider),
              value: maritalValue as String?,
              items: _maritalItems,
              labelOf: (value) => _getTranslatedLabel(value, languageProvider),
              onChanged: (v) => setState(() => _maritalStatus = v),
              languageProvider: languageProvider,
            ),
            const SizedBox(height: 12),
            _fieldLabel(_getTranslatedChildrenLabel(languageProvider)),
            TextFormField(
              controller: _childrenCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(signed: false),
              decoration: _decoration(
                hint: _getTranslatedChildrenHint(languageProvider),
                languageProvider: languageProvider,
              ),
            ),
            const SizedBox(height: 12),
            _dropdown<String>(
              label: _getTranslatedSkinToneLabel(languageProvider),
              value: skinToneValue as String?,
              items: _skinToneItems,
              labelOf: (value) => _getTranslatedLabel(value, languageProvider),
              onChanged: (v) => setState(() => _skinTone = v),
              languageProvider: languageProvider,
            ),
            const SizedBox(height: 12),
            _dropdown<String>(
              label: _getTranslatedBirthPlaceLabel(languageProvider),
              value: birthPlaceValue as String?,
              items: _birthPlaceItems,
              labelOf: (value) => _getTranslatedLabel(value, languageProvider),
              onChanged: (v) => setState(() => _placeOfBirth = v),
              languageProvider: languageProvider,
            ),
            const SizedBox(height: 12),
            _fieldLabel(_getTranslatedDobLabel(languageProvider)),
            TextFormField(
              controller: _dobCtrl,
              readOnly: true,
              decoration: _decoration(
                hint: _getTranslatedDobHint(languageProvider),
                suffixIcon: IconButton(
                  onPressed: () => _pickDate(languageProvider),
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: _iconMuted,
                  ),
                ),
                languageProvider: languageProvider,
              ),
              onTap: () => _pickDate(languageProvider),
            ),
            const SizedBox(height: 12),
            _dropdown<String>(
              label: _getTranslatedReligionLabel(languageProvider),
              value: religionValue as String?,
              items: _religionItems,
              labelOf: (value) => _getTranslatedLabel(value, languageProvider),
              onChanged: (v) => setState(() => _religion = v),
              languageProvider: languageProvider,
            ),
            const SizedBox(height: 20),
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
    if (lang == 'ar') return "الخطوة 3: المعلومات الشخصية";
    if (lang == 'am') return "ደረጃ 3: የግል መረጃ";
    return "Step 3: Personal Information";
  }

  String _getTranslatedSectionTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المعلومات الشخصية";
    if (lang == 'am') return "የግል መረጃ";
    return "Personal Information";
  }

  String _getTranslatedAmharicNameLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الاسم الكامل بالأمهرية";
    if (lang == 'am') return "ሙሉ ስም በአማርኛ";
    return "Amharic Full Name";
  }

  String _getTranslatedAmharicNameHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل الاسم الكامل بالأمهرية";
    if (lang == 'am') return "ሙሉ ስም በአማርኛ ያስገቡ";
    return "Enter Amharic Full Name";
  }

  String _getTranslatedEnglishNameLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الاسم الكامل بالإنجليزية";
    if (lang == 'am') return "ሙሉ ስም በእንግሊዝኛ";
    return "English Full Name";
  }

  String _getTranslatedEnglishNameHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل الاسم الكامل بالإنجليزية";
    if (lang == 'am') return "ሙሉ ስም በእንግሊዝኛ ያስገቡ";
    return "Enter English Full Name";
  }

  String _getTranslatedArabicNameLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الاسم الكامل بالعربية";
    if (lang == 'am') return "ሙሉ ስም በዓረብኛ";
    return "Arabic Full Name";
  }

  String _getTranslatedArabicNameHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل الاسم الكامل بالعربية";
    if (lang == 'am') return "ሙሉ ስም በዓረብኛ ያስገቡ";
    return "Enter Arabic Full Name";
  }

  String _getTranslatedSexLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الجنس";
    if (lang == 'am') return "ጾታ";
    return "Sex";
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

  String _getTranslatedCodeHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الكود";
    if (lang == 'am') return "ኮድ";
    return "Code";
  }

  String _getTranslatedPhoneHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل رقم الهاتف";
    if (lang == 'am') return "ስልክ ቁጥር ያስገቡ";
    return "Enter Phone Number";
  }

  String _getTranslatedHeightLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الطول (سم)";
    if (lang == 'am') return "ቁመት (ሴ.ሜ)";
    return "Height (cm)";
  }

  String _getTranslatedHeightHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل الطول";
    if (lang == 'am') return "ቁመት ያስገቡ";
    return "Enter Height";
  }

  String _getTranslatedWeightLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الوزن (كجم)";
    if (lang == 'am') return "ክብደት (ኪ.ግ)";
    return "Weight (kg)";
  }

  String _getTranslatedWeightHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل الوزن";
    if (lang == 'am') return "ክብደት ያስገቡ";
    return "Enter Weight";
  }

  String _getTranslatedMaritalStatusLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الحالة الاجتماعية";
    if (lang == 'am') return "የጋብቻ ሁኔታ";
    return "Marital Status";
  }

  String _getTranslatedChildrenLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "عدد الأطفال";
    if (lang == 'am') return "የልጆች ብዛት";
    return "Number of Children";
  }

  String _getTranslatedChildrenHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل عدد الأطفال";
    if (lang == 'am') return "የልጆች ብዛት ያስገቡ";
    return "Enter Number of Children";
  }

  String _getTranslatedSkinToneLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "لون البشرة";
    if (lang == 'am') return "የቆዳ ቀለም";
    return "Skin Tone";
  }

  String _getTranslatedBirthPlaceLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "مكان الميلاد";
    if (lang == 'am') return "የትውልድ ቦታ";
    return "Place of Birth";
  }

  String _getTranslatedDobLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تاريخ الميلاد";
    if (lang == 'am') return "የትውልድ ቀን";
    return "Date of Birth";
  }

  String _getTranslatedDobHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "yyyy-mm-dd";
    if (lang == 'am') return "ዓ-ሳ-ዓዓዓዓ";
    return "yyyy-mm-dd";
  }

  String _getTranslatedReligionLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الدين";
    if (lang == 'am') return "ሃይማኖት";
    return "Religion";
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
    if (lang == 'ar') return "تم إرسال المعلومات الشخصية بنجاح";
    if (lang == 'am') return "የግል መረጃ በተሳካ ሁኔታ ቀርቧል";
    return "Personal info submitted successfully";
  }

  String _getTranslatedErrorMessage(
      String error, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "خطأ: $error";
    if (lang == 'am') return "ስህተት: $error";
    return "Error: $error";
  }
}
