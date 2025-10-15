import 'package:flutter/material.dart';
import 'package:marrir/services/Employee/cv_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

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

  bool _isLoading = false;

  // ---------------------- Colors & UI Helpers ----------------------
  static const _titleColor = Color(0xFF1D2433);
  static const _labelColor = Color(0xFF3C4555);
  static const _hintColor = Color(0xFF9AA3B2);
  static const _borderColor = Color(0xFFE6E9EF);
  static const _fillColor = Colors.white;
  static const _iconMuted = Color(0xFF667085);
  static const _buttonTeal = Color(0xFF8EC6D6);

  // Currency options
  static const List<String> _currencyItems = ["USD", "ETB", "EUR"];

  // Get translated labels for display
  String _getTranslatedLabel(String value, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    // Currency translations
    if (value == "USD") {
      if (lang == 'ar') return "دولار";
      if (lang == 'am') return "ዶላር";
      return "USD";
    }
    if (value == "ETB") {
      if (lang == 'ar') return "بير إثيوبي";
      if (lang == 'am') return "ብር";
      return "ETB";
    }
    if (value == "EUR") {
      if (lang == 'ar') return "يورو";
      if (lang == 'am') return "ዩሮ";
      return "EUR";
    }

    return value;
  }

  String _getTranslatedHint(String label, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر $label";
    if (lang == 'am') return "$label ይምረጡ";
    return "Select $label";
  }

  InputDecoration _decoration({
    String? hint,
    Widget? suffixIcon,
    Widget? prefixIcon,
    LanguageProvider? languageProvider,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _hintColor,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: _fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: _labelColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) labelOf,
    required void Function(T?) onChanged,
    required LanguageProvider languageProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        DropdownButtonFormField<T>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(
                    labelOf(e),
                    style: const TextStyle(fontSize: 13, color: _labelColor),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: _decoration(
            hint: _getTranslatedHint(label, languageProvider),
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _iconMuted,
                size: 22,
              ),
            ),
            languageProvider: languageProvider,
          ),
          icon: const SizedBox.shrink(),
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(fontSize: 13, color: _labelColor),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString("user_id");
      final String? token = prefs.getString("access_token");

      if (userId == null || token == null) {
        throw Exception(_getTranslatedNotLoggedIn(languageProvider));
      }

      final skills = [
        _skill1Ctrl.text,
        _skill2Ctrl.text,
        _skill3Ctrl.text,
        _skill4Ctrl.text,
        _skill5Ctrl.text,
        _skill6Ctrl.text
      ].where((s) => s.isNotEmpty).toList();

      final res = await CVService.submitSummaryInfo(
        userId: userId,
        token: token,
        summary: _summaryCtrl.text.trim(),
        salaryExpectation:
            _salaryCtrl.text.trim().isNotEmpty ? _salaryCtrl.text.trim() : null,
        currency: _currency,
        skills: skills,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTranslatedSuccessMessage(languageProvider))),
      );

      widget.onSuccess();
      widget.onNextStep();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                _getTranslatedErrorMessage(e.toString(), languageProvider))),
      );
    } finally {
      setState(() => _isLoading = false);
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
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              _getTranslatedStepTitle(languageProvider),
              style: const TextStyle(
                  fontSize: 16,
                  color: _titleColor,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            _fieldLabel(_getTranslatedSummaryLabel(languageProvider)),
            TextFormField(
              controller: _summaryCtrl,
              maxLines: 4,
              decoration: _decoration(
                hint: _getTranslatedSummaryHint(languageProvider),
                languageProvider: languageProvider,
              ),
              validator: (value) => value!.isEmpty
                  ? _getTranslatedSummaryRequired(languageProvider)
                  : null,
            ),
            const SizedBox(height: 12),
            _fieldLabel(_getTranslatedSalaryLabel(languageProvider)),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _salaryCtrl,
                    decoration: _decoration(
                      hint: _getTranslatedSalaryHint(languageProvider),
                      languageProvider: languageProvider,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dropdown<String>(
                    label: _getTranslatedCurrencyLabel(languageProvider),
                    value: _currency,
                    items: _currencyItems,
                    labelOf: (value) =>
                        _getTranslatedLabel(value, languageProvider),
                    onChanged: (v) => setState(() => _currency = v),
                    languageProvider: languageProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _fieldLabel(_getTranslatedSkillsLabel(languageProvider)),
            _buildSkillPair(_skill1Ctrl, _skill2Ctrl, languageProvider),
            const SizedBox(height: 8),
            _buildSkillPair(_skill3Ctrl, _skill4Ctrl, languageProvider),
            const SizedBox(height: 8),
            _buildSkillPair(_skill5Ctrl, _skill6Ctrl, languageProvider),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : Text(_getTranslatedSubmitButton(languageProvider)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillPair(TextEditingController c1, TextEditingController c2,
      LanguageProvider languageProvider) {
    return Row(
      children: [
        Expanded(
            child: TextFormField(
                controller: c1,
                decoration: _decoration(
                  hint: _getTranslatedSkillHint(languageProvider),
                  languageProvider: languageProvider,
                ))),
        const SizedBox(width: 10),
        Expanded(
            child: TextFormField(
                controller: c2,
                decoration: _decoration(
                  hint: _getTranslatedSkillHint(languageProvider),
                  languageProvider: languageProvider,
                ))),
      ],
    );
  }

  // Translation helper methods
  String _getTranslatedStepTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الخطوة 5: الملخص";
    if (lang == 'am') return "ደረጃ 5: ማጠቃለያ";
    return "Step 5: Summary";
  }

  String _getTranslatedSummaryLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الملخص";
    if (lang == 'am') return "ማጠቃለያ";
    return "Summary";
  }

  String _getTranslatedSummaryHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "ملخص مهني موجز";
    if (lang == 'am') return "አጭር ሙያዊ ማጠቃለያ";
    return "Brief professional summary";
  }

  String _getTranslatedSummaryRequired(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الملخص مطلوب";
    if (lang == 'am') return "ማጠቃለያ ያስፈልጋል";
    return "Summary is required";
  }

  String _getTranslatedSalaryLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الراتب المتوقع";
    if (lang == 'am') return "የሚጠበቅ ደሞዝ";
    return "Salary Expectation";
  }

  String _getTranslatedSalaryHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الراتب المتوقع";
    if (lang == 'am') return "የሚጠበቅ ደሞዝ";
    return "Salary Expectation";
  }

  String _getTranslatedCurrencyLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "العملة";
    if (lang == 'am') return "ምንዛሪ";
    return "Currency";
  }

  String _getTranslatedSkillsLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المهارات";
    if (lang == 'am') return "ክህሎቶች";
    return "Skills";
  }

  String _getTranslatedSkillHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "مهارة";
    if (lang == 'am') return "ክህሎት";
    return "Skill";
  }

  String _getTranslatedSubmitButton(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إرسال";
    if (lang == 'am') return "አስገባ";
    return "Submit";
  }

  // Error and success message translations
  String _getTranslatedNotLoggedIn(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المستخدم غير مسجل الدخول";
    if (lang == 'am') return "ተጠቃሚው አልገባም";
    return "User not logged in";
  }

  String _getTranslatedSuccessMessage(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم إرسال الملخص بنجاح";
    if (lang == 'am') return "ማጠቃለያ በተሳካ ሁኔታ ቀርቧል";
    return "Summary submitted successfully";
  }

  String _getTranslatedErrorMessage(
      String error, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "خطأ: $error";
    if (lang == 'am') return "ስህተት: $error";
    return "Error: $error";
  }
}
