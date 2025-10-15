import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/setting.dart';
import 'package:marrir/Component/Employee/wave_background.dart';
import 'package:marrir/services/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class PassWordPinPage extends StatefulWidget {
  final Function(Widget)? onChildSelected;

  const PassWordPinPage({super.key, this.onChildSelected});

  @override
  State<PassWordPinPage> createState() => _PassWordPinPageState();
}

class _PassWordPinPageState extends State<PassWordPinPage> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // Show dialog
  void _showDialog(String message,
      {bool success = false, required LanguageProvider languageProvider}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red, size: 60),
              const SizedBox(height: 20),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (success && widget.onChildSelected != null) {
                      widget.onChildSelected!(SettingPage(
                          onChildSelected: widget.onChildSelected!));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _getTranslatedOk(languageProvider),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle password change
  Future<void> _handleChangePassword(LanguageProvider languageProvider) async {
    final current = _currentController.text.trim();
    final newPass = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showDialog(_getTranslatedFillAllFields(languageProvider),
          languageProvider: languageProvider);
      return;
    }

    if (newPass != confirm) {
      _showDialog(_getTranslatedPasswordMismatch(languageProvider),
          languageProvider: languageProvider);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final String? userId = prefs.getString('user_id');
      final String? token = prefs.getString('access_token');
      if (userId == null || token == null) {
        throw Exception(_getTranslatedNotLoggedIn(languageProvider));
      }

      // Call API
      await ApiService.updateUserProfile(
        userId: userId,
        token: token,
        firstName: "", // no change
        lastName: "", // no change
        password: newPass,
      );

      _showDialog(_getTranslatedPasswordChanged(languageProvider),
          success: true, languageProvider: languageProvider);
    } catch (e) {
      _showDialog("${_getTranslatedError(languageProvider)}: $e",
          languageProvider: languageProvider);
    }
  }

  InputDecoration _pinInputDecoration(
      bool obscure, VoidCallback toggle, String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: const Color.fromRGBO(142, 198, 214, 0.3),
      hintText: hintText,
      suffixIcon: IconButton(
        icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.black54),
        onPressed: toggle,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
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
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getTranslatedCurrentPassword(languageProvider),
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _currentController,
                      obscureText: _obscureCurrent,
                      decoration: _pinInputDecoration(_obscureCurrent, () {
                        setState(() => _obscureCurrent = !_obscureCurrent);
                      }, _getTranslatedCurrentPasswordHint(languageProvider)),
                    ),
                    const SizedBox(height: 20),
                    Text(_getTranslatedNewPassword(languageProvider),
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newController,
                      obscureText: _obscureNew,
                      decoration: _pinInputDecoration(_obscureNew, () {
                        setState(() => _obscureNew = !_obscureNew);
                      }, _getTranslatedNewPasswordHint(languageProvider)),
                    ),
                    const SizedBox(height: 20),
                    Text(_getTranslatedConfirmPassword(languageProvider),
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      decoration: _pinInputDecoration(_obscureConfirm, () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      }, _getTranslatedConfirmPasswordHint(languageProvider)),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            _handleChangePassword(languageProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(142, 198, 214, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _getTranslatedChangePasswordButton(languageProvider),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إعدادات كلمة المرور";
    if (lang == 'am') return "የይለፍ ቃል ቅንብሮች";
    return "Password Settings";
  }

  String _getTranslatedCurrentPassword(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "كلمة المرور الحالية";
    if (lang == 'am') return "አሁን ያለው የይለፍ ቃል";
    return "Current Password";
  }

  String _getTranslatedCurrentPasswordHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل كلمة المرور الحالية";
    if (lang == 'am') return "አሁን ያለው የይለፍ ቃል ያስገቡ";
    return "Enter current password";
  }

  String _getTranslatedNewPassword(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "كلمة المرور الجديدة";
    if (lang == 'am') return "አዲስ የይለፍ ቃል";
    return "New Password";
  }

  String _getTranslatedNewPasswordHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدخل كلمة المرور الجديدة";
    if (lang == 'am') return "አዲስ የይለፍ ቃል ያስገቡ";
    return "Enter new password";
  }

  String _getTranslatedConfirmPassword(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تأكيد كلمة المرور";
    if (lang == 'am') return "የይለፍ ቃል አረጋግጥ";
    return "Confirm Password";
  }

  String _getTranslatedConfirmPasswordHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أعد إدخال كلمة المرور الجديدة";
    if (lang == 'am') return "አዲሱን የይለፍ ቃል እንደገና ያስገቡ";
    return "Re-enter new password";
  }

  String _getTranslatedChangePasswordButton(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تغيير كلمة المرور";
    if (lang == 'am') return "የይለፍ ቃል ቀይር";
    return "Change Password";
  }

  String _getTranslatedOk(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "موافق";
    if (lang == 'am') return "እሺ";
    return "OK";
  }

  String _getTranslatedFillAllFields(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "يرجى ملء جميع الحقول";
    if (lang == 'am') return "እባክዎ ሁሉንም ሕዋሶች ይሙሉ";
    return "Please fill all fields";
  }

  String _getTranslatedPasswordMismatch(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "كلمة المرور الجديدة وتأكيدها غير متطابقين";
    if (lang == 'am') return "አዲሱ የይለፍ ቃል እና ማረጋገጫው አይሚሳሰሉም";
    return "New password and confirmation do not match";
  }

  String _getTranslatedNotLoggedIn(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المستخدم غير مسجل الدخول أو الرمز مفقود";
    if (lang == 'am') return "ተጠቃሚው አልገባም ወይም ቶከኑ ጠፍቷል";
    return "User not logged in or token missing";
  }

  String _getTranslatedPasswordChanged(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم تغيير كلمة المرور بنجاح!";
    if (lang == 'am') return "የይለፍ ቃሉ በተሳካ ሁኔታ ተቀይሯል!";
    return "Password changed successfully!";
  }

  String _getTranslatedError(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "خطأ";
    if (lang == 'am') return "ስህተት";
    return "Error";
  }
}
