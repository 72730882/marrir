import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSecurity/term_condition.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/employee_profile.dart';
import 'package:marrir/Component/Employee/wave_background.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class SecurityPage extends StatelessWidget {
  final Function(Widget) onChildSelected;

  const SecurityPage({super.key, required this.onChildSelected});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Column(
      children: [
        // ✅ Reuse the shared wave background
        WaveBackground(
          title: _getTranslatedSecurityTitle(languageProvider),
          onBack: () {
            onChildSelected(ProfilePage(onChildSelected: onChildSelected));
          },
          onNotification: () {},
        ),

        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _getTranslatedSecurityTitle(languageProvider),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),

        Expanded(
          child: ListView(
            children: [
              // _buildSecurityOption(
              //   _getTranslatedChangePin(languageProvider),
              //   onTap: () {
              //     onChildSelected(
              //       ChangePinPage(
              //         onChildSelected: onChildSelected,
              //       ),
              //     );
              //   },
              //   languageProvider: languageProvider,
              // ),
              _buildSecurityOption(
                _getTranslatedTermsAndConditions(languageProvider),
                onTap: () {
                  onChildSelected(
                    TermConditionPage(onChildSelected: onChildSelected),
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
    String title, {
    required VoidCallback onTap,
    required LanguageProvider languageProvider,
  }) {
    return ListTile(
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
  String _getTranslatedSecurityTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الأمان";
    if (lang == 'am') return "ደህንነት";
    return "Security";
  }

  String _getTranslatedChangePin(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تغيير الرقم السري";
    if (lang == 'am') return "ፒን ቀይር";
    return "Change Pin";
  }

  String _getTranslatedTermsAndConditions(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الشروط والأحكام";
    if (lang == 'am') return "ውሎች እና ሁኔታዎች";
    return "Terms And Conditions";
  }
}
