import 'package:flutter/material.dart';

class PersonalInformationStep extends StatefulWidget {
  const PersonalInformationStep({super.key});

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
  String? _skinTone = "Medium";
  String? _placeOfBirth = "Ethiopia (ETH)";
  String? _religion;

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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
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
            value: _sex,
            items: const ["Male", "Female", "Prefer not to say"],
            labelOf: (s) => s,
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
                  value: _countryCode,
                  items: const ["+251", "+971", "+1", "+44", "+61"]
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
            value: _maritalStatus,
            items: const ["Single", "Married", "Divorced", "Widowed"],
            labelOf: (s) => s,
            onChanged: (v) => setState(() => _maritalStatus = v),
          ),
          const SizedBox(height: 12),

          _fieldLabel("Number of Children"),
          TextFormField(
            controller: _childrenCtrl,
            keyboardType: const TextInputType.numberWithOptions(signed: false),
            decoration: _decoration(hint: "Enter Number of Children"),
          ),
          const SizedBox(height: 12),

          _dropdown<String>(
            label: "Skin Tone",
            value: _skinTone,
            items: const ["Light", "Medium", "Tan", "Dark"],
            labelOf: (s) => s,
            onChanged: (v) => setState(() => _skinTone = v),
          ),
          const SizedBox(height: 12),

          _dropdown<String>(
            label: "Place of Birth",
            value: _placeOfBirth,
            items: const [
              "Ethiopia (ETH)",
              "Kenya (KEN)",
              "Eritrea (ERI)",
              "Somalia (SOM)",
            ],
            labelOf: (s) => s,
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
            value: _religion,
            items: const ["Christian", "Muslim", "Traditional", "Other"],
            labelOf: (s) => s,
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
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  // Submit
                }
              },
              child: const Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }
}
