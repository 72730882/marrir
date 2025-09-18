import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/Employee/cv_service.dart';

class EducationalDataForm extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onNextStep;
  const EducationalDataForm(
      {super.key, required this.onSuccess, required this.onNextStep});

  @override
  // ignore: library_private_types_in_public_api
  _EducationalDataFormState createState() => _EducationalDataFormState();
}

class _EducationalDataFormState extends State<EducationalDataForm> {
  bool isGraduate = true;
  String formTitle = 'Graduate Form';

  // Controllers for editable fields
  final TextEditingController cityController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();

  // Dropdown selections
  String? selectedEducation;
  String? selectedInstitution;
  String? selectedCountry;
  String? selectedOccupationField;
  String? selectedOccupation;

  final List<String> educationOptions = ['Bachelor', 'Master', 'PhD'];
  final List<String> institutionOptions = ['University A', 'University B'];
  final List<String> countryOptions = ['USA', 'UK', 'Canada'];
  final List<String> occupationFieldOptions = ['IT', 'Finance', 'Engineering'];
  final List<String> occupationOptions = ['Developer', 'Analyst', 'Manager'];

  void _toggleForm() {
    setState(() {
      isGraduate = !isGraduate;
      formTitle = isGraduate ? 'Graduate Form' : 'Non-Graduate Form';
    });
  }

  Future<void> _submitForm() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('user_id');
    final String? token = prefs.getString('access_token');

    if (userId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await CVService.submitEducationInfo(
        userId: userId,
        token: token,
        highestLevel: selectedEducation,
        institutionName: selectedInstitution,
        country: selectedCountry,
        city: cityController.text.trim(),
        grade: gradeController.text.trim(),
        occupationCategory: selectedOccupationField,
        occupation: selectedOccupation,
      );

      Navigator.pop(context); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(res['message'] ?? "Education info submitted successfully!"),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submission failed: ${e.toString()}")),
      );
    }
  }

  @override
  void dispose() {
    cityController.dispose();
    gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF111111);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Step 6: Educational Data',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 30),

          // Graduate / Non-Graduate Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToggleButton('Graduate', isGraduate),
              const SizedBox(width: 30),
              _buildToggleButton('Non-Graduate', !isGraduate),
            ],
          ),
          const SizedBox(height: 30),

          _buildSectionLabel(formTitle),
          const SizedBox(height: 20),

          _buildSectionLabel('Highest Level of Education Received'),
          const SizedBox(height: 8),
          _buildDropdownField(
              'Select Education',
              educationOptions,
              selectedEducation,
              (val) => setState(() => selectedEducation = val)),

          _buildSectionLabel('Institution Name'),
          const SizedBox(height: 8),
          _buildDropdownField(
              'Select Institution',
              institutionOptions,
              selectedInstitution,
              (val) => setState(() => selectedInstitution = val)),

          _buildSectionLabel('Country'),
          const SizedBox(height: 8),
          _buildDropdownField('Select Country', countryOptions, selectedCountry,
              (val) => setState(() => selectedCountry = val)),

          _buildSectionLabel('City'),
          const SizedBox(height: 8),
          _buildTextField('City', cityController),

          _buildSectionLabel('Grade'),
          const SizedBox(height: 8),
          _buildTextField('Grade', gradeController),

          _buildSectionLabel('Occupation Field'),
          const SizedBox(height: 8),
          _buildDropdownField(
              'Select Occupation Field',
              occupationFieldOptions,
              selectedOccupationField,
              (val) => setState(() => selectedOccupationField = val)),

          _buildSectionLabel('Occupation'),
          const SizedBox(height: 8),
          _buildDropdownField(
              'Select Occupation',
              occupationOptions,
              selectedOccupation,
              (val) => setState(() => selectedOccupation = val)),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    const Color selectedColor = Color(0xFF65B2C9);
    const Color textColor = Color(0xFF111111);

    return GestureDetector(
      onTap: _toggleForm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : textColor,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black));
  }

  Widget _buildTextField(String placeholder, TextEditingController controller) {
    const Color borderColor = Color(0xFFD1D1D6);
    const Color mutedText = Color(0xFF8E8E93);

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(color: mutedText),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor)),
      ),
    );
  }

  Widget _buildDropdownField(String hint, List<String> options,
      String? selectedValue, ValueChanged<String?> onChanged) {
    const Color borderColor = Color(0xFFD1D1D6);
    const Color mutedText = Color(0xFF8E8E93);

    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: mutedText),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor)),
      ),
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
