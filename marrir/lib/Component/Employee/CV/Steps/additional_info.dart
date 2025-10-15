import 'package:flutter/material.dart';
import 'package:marrir/services/Employee/cv_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class AdditionalContactForm extends StatefulWidget {
  const AdditionalContactForm({super.key});

  @override
  State<AdditionalContactForm> createState() => _AdditionalContactFormState();
}

class _AdditionalContactFormState extends State<AdditionalContactForm> {
  final _formKey = GlobalKey<FormState>();

  final facebookController = TextEditingController();
  final xController = TextEditingController();
  final telegramController = TextEditingController();
  final tiktokController = TextEditingController();
  final instagramController = TextEditingController();

  bool isLoading = false;

  // Design tokens
  static const _titleColor = Color(0xFF111111);
  static const _labelColor = Color(0xFF111111);
  static const _hintColor = Color(0xFF8E8E93);
  static const _borderColor = Color(0xFFD1D1D6);
  static const _fillColor = Colors.white;
  static const _buttonColor = Color.fromRGBO(142, 198, 214, 1);

  @override
  void initState() {
    super.initState();
    _loadSavedContacts();
  }

  @override
  void dispose() {
    facebookController.dispose();
    xController.dispose();
    telegramController.dispose();
    tiktokController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      facebookController.text = prefs.getString('facebook') ?? '';
      xController.text = prefs.getString('x') ?? '';
      telegramController.text = prefs.getString('telegram') ?? '';
      tiktokController.text = prefs.getString('tiktok') ?? '';
      instagramController.text = prefs.getString('instagram') ?? '';
    });
  }

  Future<void> _saveContactsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('facebook', facebookController.text);
    await prefs.setString('x', xController.text);
    await prefs.setString('telegram', telegramController.text);
    await prefs.setString('tiktok', tiktokController.text);
    await prefs.setString('instagram', instagramController.text);
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
            fontSize: 16,
            color: _labelColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Future<void> _submitContacts(LanguageProvider languageProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');
      final String? token = prefs.getString('access_token');

      if (userId == null || token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getTranslatedNotLoggedIn(languageProvider))),
        );
        setState(() => isLoading = false);
        return;
      }

      final result = await CVService.submitAdditionalContacts(
        userId: userId,
        token: token,
        facebook: facebookController.text,
        x: xController.text,
        telegram: telegramController.text,
        tiktok: tiktokController.text,
        instagram: instagramController.text,
      );

      await _saveContactsLocally();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTranslatedSuccessMessage(languageProvider))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                _getTranslatedErrorMessage(e.toString(), languageProvider))),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildSocialInput(
    String label,
    IconData icon,
    TextEditingController controller,
    LanguageProvider languageProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: _decoration(
            hint: _getTranslatedSocialHint(label, languageProvider),
            prefixIcon: Icon(icon, color: _titleColor),
            languageProvider: languageProvider,
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              _getTranslatedStepTitle(languageProvider),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _titleColor,
              ),
            ),
            const SizedBox(height: 30),
            _buildSocialInput(
              _getTranslatedFacebookLabel(languageProvider),
              Icons.facebook,
              facebookController,
              languageProvider,
            ),
            _buildSocialInput(
              _getTranslatedTwitterLabel(languageProvider),
              Icons.alternate_email,
              xController,
              languageProvider,
            ),
            _buildSocialInput(
              _getTranslatedTelegramLabel(languageProvider),
              Icons.send,
              telegramController,
              languageProvider,
            ),
            _buildSocialInput(
              _getTranslatedTikTokLabel(languageProvider),
              Icons.music_note,
              tiktokController,
              languageProvider,
            ),
            _buildSocialInput(
              _getTranslatedInstagramLabel(languageProvider),
              Icons.camera_alt,
              instagramController,
              languageProvider,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isLoading ? null : () => _submitContacts(languageProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _getTranslatedSubmitButton(languageProvider),
                        style: const TextStyle(
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
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedStepTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الخطوة 10: معلومات الاتصال الإضافية";
    if (lang == 'am') return "ደረጃ 10: ተጨማሪ የመገኛ መረጃ";
    return "Step 10: Additional Contact Information";
  }

  String _getTranslatedFacebookLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "فيسبوك";
    if (lang == 'am') return "ፌስቡክ";
    return "Facebook";
  }

  String _getTranslatedTwitterLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "X / تويتر";
    if (lang == 'am') return "X / ትዊተር";
    return "X / Twitter";
  }

  String _getTranslatedTelegramLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تيليجرام";
    if (lang == 'am') return "ቴሌግራም";
    return "Telegram";
  }

  String _getTranslatedTikTokLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تيك توك";
    if (lang == 'am') return "ቲክቶክ";
    return "TikTok";
  }

  String _getTranslatedInstagramLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إنستجرام";
    if (lang == 'am') return "ኢንስታግራም";
    return "Instagram";
  }

  String _getTranslatedSocialHint(
      String platform, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل رابط $platform";
    if (lang == 'am') return "$platform አድራሻ ያስገቡ";
    return "Enter $platform URL";
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
    if (lang == 'ar') return "المستخدم غير مسجل الدخول!";
    if (lang == 'am') return "ተጠቃሚው አልገባም!";
    return "User not logged in!";
  }

  String _getTranslatedSuccessMessage(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم إرسال معلومات الاتصال بنجاح!";
    if (lang == 'am') return "የመገኛ መረጃ በተሳካ ሁኔታ ቀርቧል!";
    return "Contacts submitted successfully!";
  }

  String _getTranslatedErrorMessage(
      String error, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "فشل الإرسال: $error";
    if (lang == 'am') return "ማስገባት አልተሳካም: $error";
    return "Submission failed: $error";
  }
}
