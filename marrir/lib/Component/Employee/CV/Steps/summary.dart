import 'package:flutter/material.dart';
import 'package:marrir/services/Employee/cv_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SummaryStep extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onNextStep;
  const SummaryStep(
      {super.key, required this.onSuccess, required this.onNextStep});

  @override
  State<SummaryStep> createState() => _SummaryStepState();
}

class _SummaryStepState extends State<SummaryStep> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _summaryCtrl = TextEditingController();
  final TextEditingController _salaryCtrl = TextEditingController();
  final TextEditingController _skill1Ctrl = TextEditingController();
  final TextEditingController _skill2Ctrl = TextEditingController();
  final TextEditingController _skill3Ctrl = TextEditingController();
  final TextEditingController _skill4Ctrl = TextEditingController();
  final TextEditingController _skill5Ctrl = TextEditingController();
  final TextEditingController _skill6Ctrl = TextEditingController();

  String? _currency;

  // ---------------------- Colors & UI Helpers ----------------------
  static const _titleColor = Color(0xFF1D2433);
  static const _sectionLabel = Color(0xFF3C4555);
  static const _hintColor = Color(0xFF9AA3B2);
  static const _borderColor = Color(0xFFE6E9EF);
  static const _fieldFill = Colors.white;
  static const _submitTeal = Color(0xFF8EC6D6);

  InputDecoration _decor({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          color: _hintColor, fontSize: 13, fontWeight: FontWeight.w400),
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
      child: Text(text,
          style: const TextStyle(
              fontSize: 13, color: _sectionLabel, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString("user_id");
      final String? token = prefs.getString("access_token");

      if (userId == null || token == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("User not logged in!")));
        return;
      }

      final skills = [
        _skill1Ctrl.text,
        _skill2Ctrl.text,
        _skill3Ctrl.text,
        _skill4Ctrl.text,
        _skill5Ctrl.text,
        _skill6Ctrl.text
      ].where((s) => s.isNotEmpty).toList();

      final cvData = {
        "user_id": userId,
        "summary": _summaryCtrl.text.trim(),
        "expected_salary":
            _salaryCtrl.text.trim().isNotEmpty ? _salaryCtrl.text.trim() : null,
        "currency": _currency,
        "skills_one": skills.isNotEmpty ? skills[0] : null,
        "skills_two": skills.length > 1 ? skills[1] : null,
        "skills_three": skills.length > 2 ? skills[2] : null,
        "skills_four": skills.length > 3 ? skills[3] : null,
        "skills_five": skills.length > 4 ? skills[4] : null,
        "skills_six": skills.length > 5 ? skills[5] : null,
      };

      final res = await CVService.submitSummaryInfo(
        userId: userId,
        token: token,
        summary: cvData["summary"] ?? "",
        salaryExpectation: cvData["expected_salary"],
        currency: cvData["currency"],
        skills: [
          cvData["skills_one"],
          cvData["skills_two"],
          cvData["skills_three"],
          cvData["skills_four"],
          cvData["skills_five"],
          cvData["skills_six"],
        ].where((s) => s != null && s.isNotEmpty).map((s) => s!).toList(),
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(res['message'] ?? "Summary submitted successfully!")),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submission failed: ${e.toString()}")));
    }
  }

  @override
  void dispose() {
    _summaryCtrl.dispose();
    _salaryCtrl.dispose();
    _skill1Ctrl.dispose();
    _skill2Ctrl.dispose();
    _skill3Ctrl.dispose();
    _skill4Ctrl.dispose();
    _skill5Ctrl.dispose();
    _skill6Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Step 5: Summary",
              style: TextStyle(
                  fontSize: 16,
                  color: _titleColor,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            _fieldLabel("Summary"),
            TextFormField(
              controller: _summaryCtrl,
              maxLines: 4,
              decoration: _decor(hint: "Brief professional summary"),
              validator: (value) =>
                  value!.isEmpty ? "Summary is required" : null,
            ),
            const SizedBox(height: 12),
            _fieldLabel("Salary Expectation"),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _salaryCtrl,
                    decoration: _decor(hint: "Salary Expectation"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    items: const ["USD", "ETB", "EUR"]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => _currency = val),
                    decoration: _decor(hint: "Currency"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _fieldLabel("Skills"),
            _buildSkillPair(_skill1Ctrl, _skill2Ctrl),
            const SizedBox(height: 8),
            _buildSkillPair(_skill3Ctrl, _skill4Ctrl),
            const SizedBox(height: 8),
            _buildSkillPair(_skill5Ctrl, _skill6Ctrl),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _submitTeal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submitForm,
                child: const Text(
                  "Submit",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillPair(TextEditingController c1, TextEditingController c2) {
    return Row(
      children: [
        Expanded(
            child: TextFormField(
                controller: c1, decoration: _decor(hint: "Skill"))),
        const SizedBox(width: 10),
        Expanded(
            child: TextFormField(
                controller: c2, decoration: _decor(hint: "Skill"))),
      ],
    );
  }
}
