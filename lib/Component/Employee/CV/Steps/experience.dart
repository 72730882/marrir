import 'package:flutter/material.dart';

class PreviousExperienceForm extends StatefulWidget {
  const PreviousExperienceForm({super.key});

  @override
  State<PreviousExperienceForm> createState() => _PreviousExperienceFormState();
}

class _PreviousExperienceFormState extends State<PreviousExperienceForm> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
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
          "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";
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
          _buildTextField('Select Country'),
          const SizedBox(height: 16),

          _buildLabel('City'),
          const SizedBox(height: 8),
          _buildTextField('Enter City'),
          const SizedBox(height: 16),

          _buildLabel('Company'),
          const SizedBox(height: 8),
          _buildTextField('Enter Company Home'),
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
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: buttonColor,
                side: BorderSide(color: buttonColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
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
          _buildTextField('Enter summary of the above input', maxLines: 4),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
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

  Widget _buildTextField(String placeholder, {int maxLines = 1}) {
    return TextField(
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
}
