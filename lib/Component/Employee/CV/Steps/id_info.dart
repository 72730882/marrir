import 'package:flutter/material.dart';

class StepID extends StatefulWidget {
  const StepID({super.key});

  @override
  State<StepID> createState() => _StepIDState();
}

class _StepIDState extends State<StepID> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nationalIDController = TextEditingController();
  final TextEditingController passportController = TextEditingController();
  final TextEditingController dateIssuedController = TextEditingController();
  final TextEditingController placeIssuedController = TextEditingController();
  final TextEditingController dateExpiryController = TextEditingController();

  String? nationality;

  @override
  void dispose() {
    nationalIDController.dispose();
    passportController.dispose();
    dateIssuedController.dispose();
    placeIssuedController.dispose();
    dateExpiryController.dispose();
    super.dispose();
  }

  static const _titleColor = Color(0xFF1D2433);
  static const _sectionLabel = Color(0xFF3C4555);
  static const _hintColor = Color(0xFF9AA3B2);
  static const _borderColor = Color(0xFFE6E9EF);
  static const _fieldFill = Colors.white;
  static const _submitTeal = Color(0xFF8EC6D6);
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

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      controller.text =
          "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 2: ID Information",
            style: TextStyle(
              fontSize: 16,
              color: _titleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "ID Information",
            style: TextStyle(
              fontSize: 13,
              color: _sectionLabel,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // National ID
          _fieldLabel("National ID"),
          TextFormField(
            controller: nationalIDController,
            decoration: _decor(hint: "Enter National ID"),
          ),
          const SizedBox(height: 12),

          // Passport Number
          _fieldLabel("Passport Number"),
          TextFormField(
            controller: passportController,
            decoration: _decor(hint: "Enter Passport Number"),
          ),
          const SizedBox(height: 12),

          // Date Issued
          _fieldLabel("Date Issued"),
          TextFormField(
            controller: dateIssuedController,
            readOnly: true,
            decoration: _decor(
              hint: "Select Date Issued",
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: _iconMuted,
                  size: 20,
                ),
                onPressed: () => _pickDate(dateIssuedController),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Place Issued
          _fieldLabel("Place Issued"),
          TextFormField(
            controller: placeIssuedController,
            decoration: _decor(hint: "Enter Place Issued"),
          ),
          const SizedBox(height: 12),

          // Date of Expiry
          _fieldLabel("Date of Expiry"),
          TextFormField(
            controller: dateExpiryController,
            readOnly: true,
            decoration: _decor(
              hint: "Select Expiry Date",
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: _iconMuted,
                  size: 20,
                ),
                onPressed: () => _pickDate(dateExpiryController),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nationality
          _fieldLabel("Nationality"),
          DropdownButtonFormField<String>(
            value: nationality,
            items:
                const [
                      "Select Nationality",
                      "Ethiopian",
                      "American",
                      "British",
                      "Other",
                    ]
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
            onChanged: (v) => setState(() => nationality = v),
            decoration: _decor(
              hint: "Select Nationality",
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
          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _submitTeal,
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
