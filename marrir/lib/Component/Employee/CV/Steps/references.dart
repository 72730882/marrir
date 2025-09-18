// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:marrir/services/Employee/cv_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // 🔹 Submit Reference Data via Service
  Future<void> _submitReference() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("token");
      final String? userId = prefs.getString("userId");

      if (token == null || userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in!")),
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
        summary: summaryController.text, // ✅ Added summary field
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reference submitted successfully!")),
      );

      // ✅ Move to next step if provided
      widget.onSuccess?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submission failed: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF111111);
    const Color buttonColor = Color.fromRGBO(142, 198, 214, 1);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Step 9: References',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 30),
          _buildLabel('Name'),
          _buildTextField(
              controller: nameController, placeholder: 'Enter Name'),
          const SizedBox(height: 16),
          _buildLabel('Email'),
          _buildTextField(
              controller: emailController, placeholder: 'Enter Email'),
          const SizedBox(height: 16),
          _buildLabel('Phone Number'),
          _buildPhoneField(),
          const SizedBox(height: 16),
          _buildLabel('Date of Birth'),
          _buildDatePicker(),
          const SizedBox(height: 16),
          _buildLabel('Select Gender'),
          _buildDropdownField(
              options: ['Male', 'Female', 'Other'],
              hint: 'Select Gender',
              onChanged: (val) => setState(() => selectedGender = val)),
          const SizedBox(height: 16),
          _buildLabel('Country'),
          _buildDropdownField(
              options: ['Ethiopia', 'USA', 'Other'],
              hint: 'Select Country',
              onChanged: (val) => setState(() => selectedCountry = val)),
          const SizedBox(height: 16),
          _buildLabel('City'),
          _buildTextField(
              controller: cityController, placeholder: 'Enter City'),
          const SizedBox(height: 16),
          _buildLabel('Sub City'),
          _buildTextField(
              controller: subCityController, placeholder: 'Enter Sub City'),
          const SizedBox(height: 16),
          _buildLabel('Zone'),
          _buildTextField(
              controller: zoneController, placeholder: 'Enter Zone'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('P.O. Box'),
                    _buildTextField(
                        controller: poBoxController,
                        placeholder: 'Enter P.O.Box'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('House Number'),
                    _buildTextField(
                        controller: houseNumberController,
                        placeholder: 'Enter House Number'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabel('Reference Summary'),
          _buildTextField(
              controller: summaryController,
              placeholder: 'Enter summary',
              maxLines: 4),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitReference,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Submit',
                      style: TextStyle(
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

  // 🔹 Reusable Widgets
  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: placeholder,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D1D6)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('+251'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Enter Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            selectedDate = picked;
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            hintText: selectedDate == null
                ? "mm/dd/yyyy"
                : "${selectedDate!.month.toString().padLeft(2, '0')}/"
                    "${selectedDate!.day.toString().padLeft(2, '0')}/"
                    "${selectedDate!.year}",
            suffixIcon: const Icon(Icons.calendar_today_outlined,
                color: Color(0xFF8E8E93)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required List<String> options,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: null,
      hint: Text(hint, style: const TextStyle(color: Color(0xFF8E8E93))),
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
