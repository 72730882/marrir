import 'package:flutter/material.dart';

class AddressInformationStep extends StatefulWidget {
  const AddressInformationStep({super.key});

  @override
  State<AddressInformationStep> createState() => _AddressInformationStepState();
}

class _AddressInformationStepState extends State<AddressInformationStep> {
  final _formKey = GlobalKey<FormState>();

  // Controllers...
  final _regionCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _street2Ctrl = TextEditingController();
  final _street3Ctrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _houseNumberCtrl = TextEditingController();
  final _poBoxCtrl = TextEditingController();

  String? _country;

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
  static const _sectionLabel = Color(0xFF3C4555);
  static const _hintColor = Color(0xFF9AA3B2);
  static const _borderColor = Color(0xFFE6E9EF);
  static const _fieldFill = Colors.white;
  static const _iconMuted = Color(0xFF667085);

  InputDecoration _decor({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _hintColor,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: _sectionLabel,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 4: Address Information",
            style: TextStyle(
              fontSize: 16,
              color: _titleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Address Information",
            style: TextStyle(
              fontSize: 13,
              color: _sectionLabel,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Country
          _fieldLabel("Country"),
          DropdownButtonFormField<String>(
            value: _country,
            items: const ["Ethiopia", "Kenya", "Eritrea", "Somalia", "Sudan"]
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                      c,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _sectionLabel,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _country = v),
            decoration: _decor(
              hint: "Enter Country",
              suffixIcon: const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _iconMuted,
                  size: 22,
                ),
              ),
            ),
            icon: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(10),
            style: const TextStyle(fontSize: 13, color: _sectionLabel),
          ),
          const SizedBox(height: 12),

          // Region
          _fieldLabel("Region"),
          TextFormField(
            controller: _regionCtrl,
            decoration: _decor(hint: "Enter Region"),
          ),
          const SizedBox(height: 12),

          // City
          _fieldLabel("City"),
          TextFormField(
            controller: _cityCtrl,
            decoration: _decor(hint: "Enter City"),
          ),
          const SizedBox(height: 12),

          // Street fields...
          _fieldLabel("Street"),
          TextFormField(
            controller: _streetCtrl,
            decoration: _decor(hint: "Enter Street"),
          ),
          const SizedBox(height: 12),

          _fieldLabel("Street 2"),
          TextFormField(
            controller: _street2Ctrl,
            decoration: _decor(hint: "Enter Street 2"),
          ),
          const SizedBox(height: 12),

          _fieldLabel("Street 3"),
          TextFormField(
            controller: _street3Ctrl,
            decoration: _decor(hint: "Enter Street 3"),
          ),
          const SizedBox(height: 12),

          // Zip + House Number
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel("Zip Code"),
                    TextFormField(
                      controller: _zipCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _decor(hint: "Enter Zip Code"),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel("House Number"),
                    TextFormField(
                      controller: _houseNumberCtrl,
                      decoration: _decor(hint: "Enter House Number"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // P.O.Box
          _fieldLabel("P.O.Box"),
          TextFormField(
            controller: _poBoxCtrl,
            keyboardType: TextInputType.number,
            decoration: _decor(hint: "Enter P.O.Box"),
          ),
          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Form submitted!")),
                  );
                }
              },
              child: const Text(
                "Submit",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
