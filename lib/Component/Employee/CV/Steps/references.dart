import 'package:flutter/material.dart';

class ReferencesForm extends StatefulWidget {
  const ReferencesForm({super.key});

  @override
  State<ReferencesForm> createState() => _ReferencesFormState();
}

class _ReferencesFormState extends State<ReferencesForm> {
  DateTime? selectedDate;

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
          const SizedBox(height: 8),
          _buildTextField('Enter Name'),
          const SizedBox(height: 16),

          _buildLabel('Email'),
          const SizedBox(height: 8),
          _buildTextField('Enter Email'),
          const SizedBox(height: 16),

          _buildLabel('Phone Number'),
          const SizedBox(height: 8),
          _buildPhoneField(),
          const SizedBox(height: 16),

          // 🔹 Date of Birth with Date Picker
          _buildLabel('Date of Birth'),
          const SizedBox(height: 8),
          GestureDetector(
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
                      color: Color(0xFF8E8E93)), // ✅ calendar icon
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
                    borderSide:
                        const BorderSide(color: Color(0xFFD1D1D6), width: 2),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          _buildLabel('Select Gender'),
          const SizedBox(height: 8),
          _buildDropdownField(['Male', 'Female', 'Other'], 'Select Gender'),
          const SizedBox(height: 16),

          _buildLabel('Country'),
          const SizedBox(height: 8),
          _buildDropdownField(['Ethiopia', 'USA', 'Other'], 'Select Country'),
          const SizedBox(height: 16),

          _buildLabel('City'),
          const SizedBox(height: 8),
          _buildTextField('Enter City'),
          const SizedBox(height: 16),

          _buildLabel('Sub City'),
          const SizedBox(height: 8),
          _buildTextField('Enter Sub City'),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('P.O. Box'),
                    const SizedBox(height: 8),
                    _buildTextField('Enter P.O.Box'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('House Number'),
                    const SizedBox(height: 8),
                    _buildTextField('Enter House Number'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildLabel('Reference'),
          const SizedBox(height: 8),
          _buildTextField('Brief summary of the above input', maxLines: 4),

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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      maxLines: maxLines,
      keyboardType: keyboardType,
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

  Widget _buildPhoneField() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D1D6)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Text('+251', style: TextStyle(fontSize: 14)),
              SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Enter Phone Number',
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
                borderSide: const BorderSide(
                  color: Color(0xFFD1D1D6),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(List<String> options, String hint) {
    String? selectedValue;
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D1D6)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text(hint, style: const TextStyle(color: Color(0xFF8E8E93))),
            isExpanded: true,
            underline: const SizedBox(),
            items: options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedValue = value;
              });
            },
          ),
        );
      },
    );
  }
}
