import 'package:flutter/material.dart';

class EducationalDataForm extends StatefulWidget {
  const EducationalDataForm({super.key});

  @override
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

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF111111);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Step 6: Educational Data',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
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
            (value) => setState(() => selectedEducation = value),
          ),

          _buildSectionLabel('Institution Name'),
          const SizedBox(height: 8),
          _buildDropdownField(
            'Select Institution Name',
            institutionOptions,
            selectedInstitution,
            (value) => setState(() => selectedInstitution = value),
          ),

          _buildSectionLabel('Country'),
          const SizedBox(height: 8),
          _buildDropdownField(
            'Select Country',
            countryOptions,
            selectedCountry,
            (value) => setState(() => selectedCountry = value),
          ),

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
            (value) => setState(() => selectedOccupationField = value),
          ),

          _buildSectionLabel('Occupation'),
          const SizedBox(height: 8),
          _buildDropdownField(
            'Select Occupation',
            occupationOptions,
            selectedOccupation,
            (value) => setState(() => selectedOccupation = value),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle submit
                print('City: ${cityController.text}');
                print('Grade: ${gradeController.text}');
                print('Education: $selectedEducation');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
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
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField(String placeholder, TextEditingController controller) {
    const Color borderColor = Color(0xFFD1D1D6);
    const Color mutedText = Color(0xFF8E8E93);

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(color: mutedText),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: borderColor,
          ), // Keep border same on focus
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String hint,
    List<String> options,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    const Color borderColor = Color(0xFFD1D1D6);
    const Color mutedText = Color(0xFF8E8E93);

    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: mutedText),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
      ),
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
