import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/delete.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/notification.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/password_setting.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/employee_profile.dart';
import 'package:marrir/Component/Employee/wave_background.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class SettingPage extends StatelessWidget {
  final Function(Widget) onChildSelected;

  const SettingPage({super.key, required this.onChildSelected});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Column(
      children: [
        // Header with waves
        WaveBackground(
          title: _getTranslatedSettingTitle(languageProvider),
          onBack: () {
            onChildSelected(ProfilePage(onChildSelected: onChildSelected));
          },
          onNotification: () {},
        ),

        const SizedBox(height: 20),

        Expanded(
          child: ListView(
            children: [
              _buildSecurityOption(
                _getTranslatedNotificationSettings(languageProvider),
                Icons.notifications,
                onTap: () {
                  onChildSelected(
                    NotificationSettingsPage(onChildSelected: onChildSelected),
                  );
                },
                languageProvider: languageProvider,
              ),
              _buildSecurityOption(
                _getTranslatedPasswordSettings(languageProvider),
                Icons.lock,
                onTap: () {
                  onChildSelected(
                    PassWordPinPage(onChildSelected: onChildSelected),
                  );
                },
                languageProvider: languageProvider,
              ),
              _buildSecurityOption(
                _getTranslatedDeleteAccount(languageProvider),
                Icons.delete,
                onTap: () {
                  onChildSelected(
                    DeleteAccountPage(
                      onChildSelected: onChildSelected,
                      userId: '',
                      accessToken: '',
                    ),
                  );
                },
                languageProvider: languageProvider,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityOption(
    String title,
    IconData icon, {
    required VoidCallback onTap,
    required LanguageProvider languageProvider,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF65B2C9),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color.fromARGB(221, 20, 20, 20),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: onTap,
    );
  }

  // Translation helper methods
  String _getTranslatedSettingTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الإعدادات";
    if (lang == 'am') return "ቅንብሮች";
    return "Setting";
  }

  String _getTranslatedNotificationSettings(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إعدادات الإشعارات";
    if (lang == 'am') return "የማሳወቂያ ቅንብሮች";
    return "Notification Settings";
  }

  String _getTranslatedPasswordSettings(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إعدادات كلمة المرور";
    if (lang == 'am') return "የይለፍ ቃል ቅንብሮች";
    return "Password Settings";
  }

  String _getTranslatedDeleteAccount(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "حذف الحساب";
    if (lang == 'am') return "መለያ ሰርዝ";
    return "Delete Account";
  }
}
