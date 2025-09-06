import 'package:flutter/material.dart';

class SummaryStep extends StatelessWidget {
  const SummaryStep({super.key});

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
            'Step 5: Summary',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 30),

          _buildLabel('Summary'),
          const SizedBox(height: 8),
          _buildTextField('Brief professional summary', maxLines: 4),

          const SizedBox(height: 20),

          _buildLabel('Salary Expectation'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField('Salary Expectation')),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDropdownField(['USD', 'ETB', 'EUR'], 'Currency'),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _buildLabel('Skills'),
          const SizedBox(height: 8),

          _buildSkillPair('Skill One', 'Skill Two'),
          const SizedBox(height: 8),
          _buildSkillPair('Skill Three', 'Skill Four'),
          const SizedBox(height: 8),
          _buildSkillPair('Skill Five', 'Skill Six'),

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
          borderSide: const BorderSide(
            color: Color.fromRGBO(142, 198, 214, 1),
            width: 2,
          ),
        ),
      ),
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

  Widget _buildSkillPair(String skill1, String skill2) {
    return Row(
      children: [
        Expanded(child: _buildTextField(skill1)),
        const SizedBox(width: 10),
        Expanded(child: _buildTextField(skill2)),
      ],
    );
  }
}
