import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/setting.dart';
import 'package:marrir/Component/Employee/wave_background.dart';
import 'package:marrir/services/user.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class DeleteAccountPage extends StatefulWidget {
  final Function(Widget)? onChildSelected;
  final String accessToken;
  final String userId;

  const DeleteAccountPage({
    super.key,
    this.onChildSelected,
    required this.accessToken,
    required this.userId,
  });

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  final Color _primaryBlueDark = const Color(0xFF65B2C9);
  final Color _cardBlue = const Color(0xFFE6F2F9);
  final Color _textPrimary = const Color(0xFF2C2C2C);
  final Color _textSecondary = const Color(0xFF6F7A86);
  final Color _chipGrey = const Color(0xFFE7EEF2);
  final Color _pillGrey = const Color(0xFFF1F5F7);
  final Color _errorRed = const Color(0xFFE53935);

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount(LanguageProvider languageProvider) async {
    if (_passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTranslatedEnterPassword(languageProvider))),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.deleteAccount(
      accessToken: widget.accessToken,
      password: _passwordCtrl.text,
      userId: widget.userId,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Account deleted successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ??
                _getTranslatedAccountDeleted(languageProvider))),
      );

      // Navigate to login or home screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ??
              _getTranslatedSomethingWentWrong(languageProvider)),
          backgroundColor: _errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              WaveBackground(
                title: _getTranslatedTitle(languageProvider),
                onBack: () {
                  if (widget.onChildSelected != null) {
                    widget.onChildSelected!(
                      SettingPage(onChildSelected: widget.onChildSelected!),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                onNotification: () {},
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Text(
                      _getTranslatedConfirmationQuestion(languageProvider),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Info card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _cardBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTranslatedWarningMessage(languageProvider),
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: _textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _bullet(_getTranslatedBullet1(languageProvider),
                              languageProvider),
                          const SizedBox(height: 10),
                          _bullet(_getTranslatedBullet2(languageProvider),
                              languageProvider),
                          const SizedBox(height: 10),
                          _bullet(_getTranslatedBullet3(languageProvider),
                              languageProvider),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _getTranslatedPasswordConfirmation(languageProvider),
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _PasswordPillField(
                      controller: _passwordCtrl,
                      obscure: _obscure,
                      onToggleObscure: () =>
                          setState(() => _obscure = !_obscure),
                      chipColor: _chipGrey,
                      pillColor: const Color(0xFFE0EAEE),
                      textColor: _textPrimary,
                      hintText: _getTranslatedPasswordHint(languageProvider),
                    ),

                    const SizedBox(height: 22),

                    // Primary button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _deleteAccount(languageProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlueDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                _getTranslatedDeleteButton(languageProvider),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Secondary button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (widget.onChildSelected != null) {
                                  widget.onChildSelected!(
                                    SettingPage(
                                        onChildSelected:
                                            widget.onChildSelected!),
                                  );
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _pillGrey,
                          foregroundColor: _textPrimary,
                          side: BorderSide(color: _pillGrey),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          _getTranslatedCancelButton(languageProvider),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bullet(String text, LanguageProvider languageProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF8CA4B5),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Translation helper methods
  String _getTranslatedTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "حذف الحساب";
    if (lang == 'am') return "መለያ ሰርዝ";
    return "Delete Account";
  }

  String _getTranslatedConfirmationQuestion(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "هل أنت متأكد أنك تريد\nحذف حسابك؟";
    if (lang == 'am') return "መለያህን መሰረዝ እንደምትፈልግ እርግጠኛ ነህ?\n";
    return "Are You Sure You Want To\nDelete Your Account?";
  }

  String _getTranslatedWarningMessage(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') {
      return "هذا الإجراء سيقوم بحذف جميع بياناتك بشكل دائم، ولن تتمكن من استعادتها. يرجى مراعاة ما يلي قبل المتابعة:";
    }
    if (lang == 'am') {
      return "ይህ እርምጃ ሁሉንም የእርስዎ ውሂብ ለዘላለም ያጥፋል፣ እና መመለስ አይችሉም። ከመቀጠልዎ በፊት የሚከተሉትን ያስታውሱ፡";
    }
    return "This action will permanently delete all of your data, and you will not be able to recover it. Please keep the following in mind before proceeding:";
  }

  String _getTranslatedBullet1(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') {
      return "سيتم حذف جميع نفقاتك ودخلك والمعاملات المرتبطة بها.";
    }
    if (lang == 'am') return "ሁሉም ወጪዎችዎ፣ ገቢዎችዎ እና ተዛማጅ ግብይቶች ይጠፋሉ።";
    return "All your expenses, income and associated transactions will be eliminated.";
  }

  String _getTranslatedBullet2(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') {
      return "لن تتمكن من الوصول إلى حسابك أو أي معلومات مرتبطة به.";
    }
    if (lang == 'am') return "ወደ መለያዎ ወይም ማንኛውም ተዛማጅ መረጃ መድረስ አይችሉም።";
    return "You will not be able to access your account or any related information.";
  }

  String _getTranslatedBullet3(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "لا يمكن التراجع عن هذا الإجراء.";
    if (lang == 'am') return "ይህ እርምጃ ሊመለስ አይችልም።";
    return "This action cannot be undone.";
  }

  String _getTranslatedPasswordConfirmation(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') {
      return "يرجى إدخال كلمة المرور الخاصة بك لتأكيد\nحذف حسابك.";
    }
    if (lang == 'am') return "መለያዎን ለማጥፋት ማረጋገጫ ለማድረግ የይለፍ ቃልዎን ያስገቡ\n.";
    return "Please Enter Your Password To Confirm\nDeletion Of Your Account.";
  }

  String _getTranslatedPasswordHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "••••••••";
    if (lang == 'am') return "••••••••";
    return "••••••••";
  }

  String _getTranslatedDeleteButton(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "نعم، احذف الحساب";
    if (lang == 'am') return "አዎ፣ መለያውን ሰርዝ";
    return "Yes, Delete Account";
  }

  String _getTranslatedCancelButton(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إلغاء";
    if (lang == 'am') return "ሰርዝ";
    return "Cancel";
  }

  String _getTranslatedEnterPassword(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "يرجى إدخال كلمة المرور";
    if (lang == 'am') return "እባክዎ የይለፍ ቃልዎን ያስገቡ";
    return "Please enter your password";
  }

  String _getTranslatedAccountDeleted(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم حذف الحساب";
    if (lang == 'am') return "መለያው ተሰርዟል";
    return "Account deleted";
  }

  String _getTranslatedSomethingWentWrong(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "حدث خطأ ما";
    if (lang == 'am') return "ስህተት ተከስቷል";
    return "Something went wrong";
  }
}

class _PasswordPillField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final Color chipColor;
  final Color pillColor;
  final Color textColor;
  final String hintText;

  const _PasswordPillField({
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    required this.chipColor,
    required this.pillColor,
    required this.textColor,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            height: 48,
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: textColor.withOpacity(0.6),
                  letterSpacing: 3,
                  fontSize: 18,
                ),
              ),
              style: const TextStyle(fontSize: 18, letterSpacing: 3),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            onPressed: onToggleObscure,
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF536571),
              size: 20,
            ),
            splashRadius: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }
}
