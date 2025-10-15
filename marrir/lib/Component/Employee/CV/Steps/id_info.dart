import 'package:flutter/material.dart';
import 'package:marrir/services/Employee/cv_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class StepID extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onNextStep;
  const StepID({
    super.key,
    required this.onSuccess,
    required this.onNextStep,
  });

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

  // ---------------------- Colors & UI Helpers ----------------------
  static const _titleColor = Color(0xFF1D2433);
  static const _sectionLabel = Color(0xFF3C4555);
  static const _hintColor = Color(0xFF9AA3B2);
  static const _borderColor = Color(0xFFE6E9EF);
  static const _fieldFill = Colors.white;
  static const _submitTeal = Color(0xFF8EC6D6);
  static const _iconMuted = Color(0xFF667085);

  InputDecoration _decor(
      {String? hint, Widget? suffixIcon, LanguageProvider? languageProvider}) {
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

  Future<void> _pickDate(TextEditingController controller,
      LanguageProvider languageProvider) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      controller.text = _formatDateForDisplay(pickedDate, languageProvider);
    }
  }

  String _formatDateForDisplay(
      DateTime date, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar' || lang == 'am') {
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } else {
      return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
    }
  }

  // --------------------- Submit Form ---------------------
  Future<void> _submitForm() async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    if (!_formKey.currentState!.validate()) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _getTranslatedSubmitting(languageProvider),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      // Retrieve logged-in user ID and token
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString("user_id");
      final String? token = prefs.getString("access_token");

      if (userId == null || token == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getTranslatedNotLoggedIn(languageProvider))),
        );
        return;
      }

      // Prepare CV data
      final res = await CVService.submitCVForm(
        nationalId: nationalIDController.text.trim(),
        passportNumber: passportController.text.trim(),
        dateIssued: dateIssuedController.text.trim(),
        placeIssued: placeIssuedController.text.trim(),
        dateExpiry: dateExpiryController.text.trim(),
        nationality: nationality!,
        token: token,
        userId: userId,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(res['message'] ??
                _getTranslatedSubmissionSuccess(languageProvider))),
      );

      widget.onSuccess();
      widget.onNextStep();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_getTranslatedSubmissionFailed(
                e.toString(), languageProvider))),
      );
    }
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
            Text(
              _getTranslatedStepTitle(languageProvider),
              style: const TextStyle(
                fontSize: 16,
                color: _titleColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _getTranslatedSectionTitle(languageProvider),
              style: const TextStyle(
                fontSize: 13,
                color: _sectionLabel,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // National ID
            _fieldLabel(_getTranslatedNationalIDLabel(languageProvider)),
            TextFormField(
              controller: nationalIDController,
              decoration: _decor(
                hint: _getTranslatedNationalIDHint(languageProvider),
                languageProvider: languageProvider,
              ),
              validator: (value) => value!.isEmpty
                  ? _getTranslatedNationalIDError(languageProvider)
                  : null,
            ),
            const SizedBox(height: 12),

            // Passport Number
            _fieldLabel(_getTranslatedPassportLabel(languageProvider)),
            TextFormField(
              controller: passportController,
              decoration: _decor(
                hint: _getTranslatedPassportHint(languageProvider),
                languageProvider: languageProvider,
              ),
              validator: (value) => value!.isEmpty
                  ? _getTranslatedPassportError(languageProvider)
                  : null,
            ),
            const SizedBox(height: 12),

            // Date Issued
            _fieldLabel(_getTranslatedDateIssuedLabel(languageProvider)),
            TextFormField(
              controller: dateIssuedController,
              readOnly: true,
              decoration: _decor(
                hint: _getTranslatedDateIssuedHint(languageProvider),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today,
                      color: _iconMuted, size: 20),
                  onPressed: () =>
                      _pickDate(dateIssuedController, languageProvider),
                ),
                languageProvider: languageProvider,
              ),
              validator: (value) => value!.isEmpty
                  ? _getTranslatedDateIssuedError(languageProvider)
                  : null,
            ),
            const SizedBox(height: 12),

            // Place Issued
            _fieldLabel(_getTranslatedPlaceIssuedLabel(languageProvider)),
            TextFormField(
              controller: placeIssuedController,
              decoration: _decor(
                hint: _getTranslatedPlaceIssuedHint(languageProvider),
                languageProvider: languageProvider,
              ),
              validator: (value) => value!.isEmpty
                  ? _getTranslatedPlaceIssuedError(languageProvider)
                  : null,
            ),
            const SizedBox(height: 12),

            // Date of Expiry
            _fieldLabel(_getTranslatedDateExpiryLabel(languageProvider)),
            TextFormField(
              controller: dateExpiryController,
              readOnly: true,
              decoration: _decor(
                hint: _getTranslatedDateExpiryHint(languageProvider),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today,
                      color: _iconMuted, size: 20),
                  onPressed: () =>
                      _pickDate(dateExpiryController, languageProvider),
                ),
                languageProvider: languageProvider,
              ),
              validator: (value) => value!.isEmpty
                  ? _getTranslatedDateExpiryError(languageProvider)
                  : null,
            ),
            const SizedBox(height: 12),

            // Nationality
            _fieldLabel(_getTranslatedNationalityLabel(languageProvider)),
            DropdownButtonFormField<String>(
              value: nationality,
              items: _getNationalityOptions(languageProvider)
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c,
                            style: const TextStyle(
                                fontSize: 13, color: _sectionLabel)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => nationality = v),
              decoration: _decor(
                hint: _getTranslatedNationalityHint(languageProvider),
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: _iconMuted, size: 22),
                ),
                languageProvider: languageProvider,
              ),
              icon: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(10),
              validator: (value) => (value == null ||
                      value ==
                          _getTranslatedSelectNationality(languageProvider))
                  ? _getTranslatedNationalityError(languageProvider)
                  : null,
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
                onPressed: _submitForm,
                child: Text(
                  _getTranslatedSubmitButton(languageProvider),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedStepTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الخطوة 2: معلومات الهوية";
    if (lang == 'am') return "ደረጃ 2: የመለያ መረጃ";
    return "Step 2: ID Information";
  }

  String _getTranslatedSectionTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "معلومات الهوية";
    if (lang == 'am') return "የመለያ መረጃ";
    return "ID Information";
  }

  String _getTranslatedNationalIDLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الرقم القومي";
    if (lang == 'am') return "ብሔራዊ መለያ";
    return "National ID";
  }

  String _getTranslatedNationalIDHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل الرقم القومي";
    if (lang == 'am') return "ብሔራዊ መለያ ያስገቡ";
    return "Enter National ID";
  }

  String _getTranslatedNationalIDError(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الرقم القومي مطلوب";
    if (lang == 'am') return "ብሔራዊ መለያ ያስፈልጋል";
    return "National ID is required";
  }

  String _getTranslatedPassportLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "رقم جواز السفر";
    if (lang == 'am') return "የፓስፖርት ቁጥር";
    return "Passport Number";
  }

  String _getTranslatedPassportHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل رقم جواز السفر";
    if (lang == 'am') return "የፓስፖርት ቁጥር ያስገቡ";
    return "Enter Passport Number";
  }

  String _getTranslatedPassportError(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "رقم جواز السفر مطلوب";
    if (lang == 'am') return "የፓስፖርት ቁጥር ያስፈልጋል";
    return "Passport Number is required";
  }

  String _getTranslatedDateIssuedLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تاريخ الإصدار";
    if (lang == 'am') return "የተሰጠበት ቀን";
    return "Date Issued";
  }

  String _getTranslatedDateIssuedHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر تاريخ الإصدار";
    if (lang == 'am') return "የተሰጠበት ቀን ይምረጡ";
    return "Select Date Issued";
  }

  String _getTranslatedDateIssuedError(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تاريخ الإصدار مطلوب";
    if (lang == 'am') return "የተሰጠበት ቀን ያስፈልጋል";
    return "Date Issued is required";
  }

  String _getTranslatedPlaceIssuedLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "مكان الإصدار";
    if (lang == 'am') return "የተሰጠበት ቦታ";
    return "Place Issued";
  }

  String _getTranslatedPlaceIssuedHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل مكان الإصدار";
    if (lang == 'am') return "የተሰጠበት ቦታ ያስገቡ";
    return "Enter Place Issued";
  }

  String _getTranslatedPlaceIssuedError(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "مكان الإصدار مطلوب";
    if (lang == 'am') return "የተሰጠበት ቦታ ያስፈልጋል";
    return "Place Issued is required";
  }

  String _getTranslatedDateExpiryLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تاريخ الانتهاء";
    if (lang == 'am') return "የሚያልቅበት ቀን";
    return "Date of Expiry";
  }

  String _getTranslatedDateExpiryHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر تاريخ الانتهاء";
    if (lang == 'am') return "የሚያልቅበት ቀን ይምረጡ";
    return "Select Expiry Date";
  }

  String _getTranslatedDateExpiryError(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تاريخ الانتهاء مطلوب";
    if (lang == 'am') return "የሚያልቅበት ቀን ያስፈልጋል";
    return "Expiry Date is required";
  }

  String _getTranslatedNationalityLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الجنسية";
    if (lang == 'am') return "ዜግነት";
    return "Nationality";
  }

  String _getTranslatedNationalityHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر الجنسية";
    if (lang == 'am') return "ዜግነት ይምረጡ";
    return "Select Nationality";
  }

  String _getTranslatedSelectNationality(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر الجنسية";
    if (lang == 'am') return "ዜግነት ይምረጡ";
    return "Select Nationality";
  }

  String _getTranslatedNationalityError(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "يرجى اختيار الجنسية";
    if (lang == 'am') return "እባክዎ ዜግነት ይምረጡ";
    return "Please select nationality";
  }

  String _getTranslatedSubmitButton(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إرسال";
    if (lang == 'am') return "አስገባ";
    return "Submit";
  }

  List<String> _getNationalityOptions(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    if (lang == 'ar') {
      return ["اختر الجنسية", "إثيوبي", "أمريكي", "بريطاني", "أخرى"];
    } else if (lang == 'am') {
      return ["ዜግነት ይምረጡ", "ኢትዮጵያዊ", "አሜሪካዊ", "ብሪታንያዊ", "ሌላ"];
    } else {
      return [
        "Select Nationality",
        "Ethiopian",
        "American",
        "British",
        "Other"
      ];
    }
  }

  // Error and status message translations
  String _getTranslatedSubmitting(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "جاري الإرسال...";
    if (lang == 'am') return "እየቀረበ ነው...";
    return "Submitting...";
  }

  String _getTranslatedNotLoggedIn(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المستخدم غير مسجل الدخول!";
    if (lang == 'am') return "ተጠቃሚው አልገባም!";
    return "User not logged in!";
  }

  String _getTranslatedSubmissionSuccess(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم إرسال السيرة الذاتية بنجاح!";
    if (lang == 'am') return "የህይወት ታሪክ በተሳካ ሁኔታ ቀርቧል!";
    return "CV submitted successfully!";
  }

  String _getTranslatedSubmissionFailed(
      String error, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "فشل الإرسال: $error";
    if (lang == 'am') return "ማስገባት አልተሳካም: $error";
    return "Submission failed: $error";
  }
}
