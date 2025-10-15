import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSecurity/security.dart';
import 'package:marrir/Component/Employee/wave_background.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class TermConditionPage extends StatefulWidget {
  final Function(Widget)? onChildSelected;

  const TermConditionPage({super.key, this.onChildSelected});

  @override
  State<TermConditionPage> createState() => _TermConditionPageState();
}

class _TermConditionPageState extends State<TermConditionPage> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header now scrolls with the content
            WaveBackground(
              title: _getTranslatedTitle(languageProvider),
              onBack: () {
                if (widget.onChildSelected != null) {
                  widget.onChildSelected!(
                    SecurityPage(onChildSelected: widget.onChildSelected!),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              onNotification: () {},
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    _getTranslatedTitle(languageProvider),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Last Updated Date
                  Text(
                    _getTranslatedLastUpdated(languageProvider),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Terms and Conditions Content
                  ..._buildTermsContent(languageProvider),

                  const SizedBox(height: 20),

                  // Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                        },
                        activeColor: const Color.fromRGBO(142, 198, 214, 1),
                      ),
                      Expanded(
                        child: Text(
                          _getTranslatedAcceptTerms(languageProvider),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Accept button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isChecked
                          ? () {
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(
                          142,
                          198,
                          214,
                          1,
                        ),
                        disabledBackgroundColor: const Color.fromRGBO(
                          142,
                          198,
                          214,
                          0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _getTranslatedAcceptButton(languageProvider),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTermsContent(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    if (lang == 'ar') {
      return _buildArabicContent();
    } else if (lang == 'am') {
      return _buildAmharicContent();
    } else {
      return _buildEnglishContent();
    }
  }

  List<Widget> _buildArabicContent() {
    return [
      const Text(
        "آخر تحديث: 2025/05/07",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      const Text(
        "سياسة الخصوصية:",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const Text(
        "من خلال استخدامك لموقعنا أو تطبيقاتنا أو منصاتنا وخدماتنا فإنك توافق كلياً على الشروط والأحكام التي تتلاءم مع سياسة الخصوصية التي تحكم العلاقة بين (MARRIR.COM) وبك فيما يخص هذا الموقع وخدماته التابعة.",
      ),
      const SizedBox(height: 12),
      const Text(
        "يحتوي موقع (MARRIR.COM) (موقعنا) على معلومات يكون المستخدم على علم بها بخصوص سرية المعلومات وخصوصية بيانات المستخدم الهامة، حيث أن هدفنا هو تقديم خدمة عالية الجودة لجميع المستخدمين مع الحفاظ على أعلى مستويات الخصوصية.",
      ),
      const SizedBox(height: 8),
      const Text(
        "1. ملفات تعريف الارتباط\n"
        "2. إعدادات المتصفح\n"
        "3. عنوان IP وبيانات الخادم\n"
        "4. الموقع الجغرافي",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    ];
  }

  List<Widget> _buildAmharicContent() {
    return [
      const Text(
        "የመጨረሻ ዝመና: 2025/05/07",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      const Text(
        "የግላዊነት ፖሊሲ:",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const Text(
        "የእኛን ድር ጣቢያ፣ መተግበሪያዎቻችንን፣ መድረናችንን ወይም አገልግሎቶቻችንን በመጠቀም ከዚህ ድር ጣቢያ እና አገልግሎቶቹ ጋር በተገናኙ ከ (MARRIR.COM) ጋር ባለዎት ግንኙነት ላይ የሚቆጣጠሩትን የግላዊነት ፖሊሲ የሚስማማውን ሁሉንም ውሎች እና ሁኔታዎች ሙሉ በሙሉ ተስማምተዋል።",
      ),
      const SizedBox(height: 12),
      const Text(
        "ይህ ድር ጣቢያ (MARRIR.COM) (የእኛ ድር ጣቢያ) ተጠቃሚዎች ስለ መረጃ ሚስጥርነት እና የተጠቃሚ ጠቃሚ ውሂብ ግላዊነት ማወቅ ያለባቸውን መረጃዎች ይዟል። ዓላማችን ለሁሉም ተጠቃሚዎች ከፍተኛ ደረጃ ያለው ግላዊነት በማስጠበቅ ከፍተኛ ጥራት ያለው አገልግሎት ማቅረብ ነው።",
      ),
      const SizedBox(height: 8),
      const Text(
        "1. ኩኪዎች\n"
        "2. የአሳሽ ቅንብሮች\n"
        "3. የ IP አድራሻ እና የሰርቨር ውሂብ\n"
        "4. የጂኦግራፊያዊ አቀማመጥ",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    ];
  }

  List<Widget> _buildEnglishContent() {
    return [
      const Text(
        "Last Updated: 07/05/2025",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      const Text(
        "Privacy Policy:",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const Text(
        "By using our website, applications, platform, or services, you shall fully agree to the terms and conditions, which align with this Privacy Policy governing the relationship between (MARRIR.COM) and you concerning this website and its services.",
      ),
      const SizedBox(height: 12),
      const Text(
        "This website, (MARRIR.COM) (Our Website), contains information that users shall be aware of the confidentiality and privacy of their important data. Our mission is to provide high-quality service to all users while maintaining the highest levels of privacy.",
      ),
      const SizedBox(height: 8),
      const Text(
        "1. Cookies\n"
        "2. Browser Settings\n"
        "3. IP Address and Server Data\n"
        "4. Geographic Location",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    ];
  }

  // Translation helper methods
  String _getTranslatedTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الشروط والأحكام";
    if (lang == 'am') return "ውሎች እና ሁኔታዎች";
    return "Terms and Conditions";
  }

  String _getTranslatedLastUpdated(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "آخر تحديث: 2025/05/07";
    if (lang == 'am') return "የመጨረሻ ዝመና: 2025/05/07";
    return "Last Updated: 07/05/2025";
  }

  String _getTranslatedAcceptTerms(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أوافق على جميع الشروط والأحكام";
    if (lang == 'am') return "ሁሉንም ውሎች እና ሁኔታዎች ተቀበዋለሁ";
    return "I accept all the terms and conditions";
  }

  String _getTranslatedAcceptButton(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "قبول";
    if (lang == 'am') return "ተቀበል";
    return "Accept";
  }
}
