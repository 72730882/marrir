import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/Employee/cv_service.dart'; // your CVService

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

  // Dropdown values (store canonical tokens used in items)
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

  // Pretty label for display while keeping canonical value in state
  String _prettyLabel(String s) {
    // Preserve country and birthplace labels as-is
    if (s.contains('(') && s.contains(')')) return s;
    return s
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  // Ensure value passed to DropdownButtonFormField is present in items or null
  Object? _safeValue<T>(T? value, List<T> items) {
    if (value == null) return null;
    return items.contains(value) ? value : null;
  }

  // If you ever prefill values (e.g., from API), normalize them here
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
            hint: "Select $label",
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _iconMuted,
                size: 22,
              ),
            ),
          ),
          icon: const SizedBox.shrink(),
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(fontSize: 13, color: _labelColor),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token") ?? "";
      final userId = prefs.getString("user_id") ?? "";

      if (token.isEmpty || userId.isEmpty) {
        throw Exception("User not logged in");
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
        const SnackBar(content: Text("Personal info submitted successfully")),
      );
      // ignore: avoid_print
      print("Submitted data: $res");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const Text(
              "Step 3: Personal Information",
              style: TextStyle(
                fontSize: 16,
                color: _titleColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Personal Information",
              style: TextStyle(
                fontSize: 13,
                color: _labelColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _fieldLabel("Amharic Full Name"),
            TextFormField(
              controller: _amhNameCtrl,
              decoration: _decoration(hint: "Enter Amharic Full Name"),
            ),
            const SizedBox(height: 12),
            _fieldLabel("English Full Name"),
            TextFormField(
              controller: _engNameCtrl,
              decoration: _decoration(hint: "Enter English Full Name"),
            ),
            const SizedBox(height: 12),
            _fieldLabel("Arabic Full Name"),
            TextFormField(
              controller: _arbNameCtrl,
              decoration: _decoration(hint: "Enter Arabic Full Name"),
            ),
            const SizedBox(height: 12),
            _dropdown<String>(
              label: "Sex",
              value: sexValue as String?,
              items: _sexItems,
              labelOf: _prettyLabel,
              onChanged: (v) => setState(() => _sex = v),
            ),
            const SizedBox(height: 12),
            _fieldLabel("Email"),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _decoration(hint: "Enter Email"),
            ),
            const SizedBox(height: 12),
            _fieldLabel("Phone Number"),
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
                    decoration: _decoration(hint: "Code"),
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
                    decoration: _decoration(hint: "Enter Phone Number"),
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
                      _fieldLabel("Height (cm)"),
                      TextFormField(
                        controller: _heightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _decoration(hint: "Enter Height"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel("Weight (kg)"),
                      TextFormField(
                        controller: _weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _decoration(hint: "Enter Weight"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _dropdown<String>(
              label: "Marital Status",
              value: maritalValue as String?,
              items: _maritalItems,
              labelOf: _prettyLabel,
              onChanged: (v) => setState(() => _maritalStatus = v),
            ),
            const SizedBox(height: 12),
            _fieldLabel("Number of Children"),
            TextFormField(
              controller: _childrenCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(signed: false),
              decoration: _decoration(hint: "Enter Number of Children"),
            ),
            const SizedBox(height: 12),
            _dropdown<String>(
              label: "Skin Tone",
              value: skinToneValue as String?,
              items: _skinToneItems,
              labelOf: _prettyLabel,
              onChanged: (v) => setState(() => _skinTone = v),
            ),
            const SizedBox(height: 12),
            _dropdown<String>(
              label: "Place of Birth",
              value: birthPlaceValue as String?,
              items: _birthPlaceItems,
              labelOf: (s) => s, // already pretty
              onChanged: (v) => setState(() => _placeOfBirth = v),
            ),
            const SizedBox(height: 12),
            _fieldLabel("Date of Birth"),
            TextFormField(
              controller: _dobCtrl,
              readOnly: true,
              decoration: _decoration(
                hint: "yyyy-mm-dd",
                suffixIcon: IconButton(
                  onPressed: _pickDate,
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: _iconMuted,
                  ),
                ),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            _dropdown<String>(
              label: "Religion",
              value: religionValue as String?,
              items: _religionItems,
              labelOf: _prettyLabel,
              onChanged: (v) => setState(() => _religion = v),
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
                    : const Text("Submit"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
