import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/Employee/cv_service.dart'; // import your service

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

  String? selectedCountry; // ✅ store selected country
  bool isSubmitting = false;

  final List<String> countries = [
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

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      controller.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _submitExperience() async {
    if (selectedCountry == null ||
        _cityController.text.isEmpty ||
        _companyController.text.isEmpty ||
        _fromDateController.text.isEmpty ||
        _toDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final userId = prefs.getString("userId");

      if (token == null || userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authentication required")),
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
        SnackBar(content: Text("Experience submitted: ${res['id'] ?? 'OK'}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
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
            'Step 8: Previous Experience and Documents',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 30),
          _buildLabel('Country'),
          const SizedBox(height: 8),
          _buildCountryDropdown(),
          const SizedBox(height: 16),
          _buildLabel('City'),
          const SizedBox(height: 8),
          _buildTextField('Enter City', controller: _cityController),
          const SizedBox(height: 16),
          _buildLabel('Company'),
          const SizedBox(height: 8),
          _buildTextField('Enter Company Name', controller: _companyController),
          const SizedBox(height: 16),
          _buildLabel('From'),
          const SizedBox(height: 8),
          _buildDateField(context, _fromDateController),
          const SizedBox(height: 16),
          _buildLabel('To'),
          const SizedBox(height: 8),
          _buildDateField(context, _toDateController),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isSubmitting ? null : _submitExperience,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: buttonColor,
                side: const BorderSide(color: buttonColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Add Experience',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLabel('Previous Work'),
          const SizedBox(height: 8),
          _buildTextField(
            'Enter summary of the above input',
            maxLines: 4,
            controller: _summaryController,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _submitExperience,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
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

  // 🔹 Reusable Widgets
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111111),
      ),
    );
  }

  Widget _buildTextField(
    String placeholder, {
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: placeholder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D1D6), width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _pickDate(context, controller),
      decoration: InputDecoration(
        hintText: 'Select Date',
        suffixIcon: const Icon(
          Icons.calendar_today,
          color: Colors.grey,
          size: 18,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D1D6), width: 2),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D1D6)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedCountry,
        hint: const Text(
          "Select Country",
          style: TextStyle(color: Color(0xFF8E8E93)),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        items: countries
            .map((country) => DropdownMenuItem(
                  value: country,
                  child: Text(country),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedCountry = value;
          });
        },
      ),
    );
  }
}
