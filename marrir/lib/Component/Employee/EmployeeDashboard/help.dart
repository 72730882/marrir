import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<Map<String, String>> _faqs = [
    {
      "q": "How do I add a new employee?",
      "a": "Go to Dashboard > Add Employee."
    },
    {
      "q": "How can I promote an employee profile?",
      "a": "Navigate to Employee Profile > Promotion."
    },
    {
      "q": "What is the difference between reserve and transfer?",
      "a": "Reserve keeps the slot, transfer reassigns it."
    },
    {
      "q": "How do I track payments?",
      "a": "Go to Payment section for full history."
    },
    {
      "q": "Can I export employee data?",
      "a": "Yes, from Settings > Export Data."
    },
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? token = prefs.getString("access_token");

            if (token != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeePage(token: token),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text(_getTranslatedTokenNotFound(languageProvider))),
              );
            }
          },
        ),
        centerTitle: true,
        title: Text(
          _getTranslatedTitle(languageProvider),
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            Text(
              _getTranslatedTitle(languageProvider),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              _getTranslatedSubtitle(languageProvider),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Top Support Options (equal height)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _supportOption(
                        Icons.help_outline,
                        _getTranslatedFAQ(languageProvider),
                        _getTranslatedFAQSubtitle(languageProvider),
                        Colors.purple,
                        languageProvider),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _supportOption(
                        Icons.email_outlined,
                        _getTranslatedEmail(languageProvider),
                        _getTranslatedEmailSubtitle(languageProvider),
                        Colors.pink,
                        languageProvider),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _supportOption(
                        Icons.phone_outlined,
                        _getTranslatedPhone(languageProvider),
                        _getTranslatedPhoneSubtitle(languageProvider),
                        Colors.deepPurple,
                        languageProvider),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Search box
            Text(
              _getTranslatedHelpQuestions(languageProvider),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: _getTranslatedSearchHint(languageProvider),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
              ),
            ),
            const SizedBox(height: 20),

            // FAQ section
            Text(
              _getTranslatedFAQs(languageProvider),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ...List.generate(_faqs.length, (index) {
              return _buildFAQItem(index, _faqs[index]["q"]!,
                  _faqs[index]["a"]!, languageProvider);
            }),
            const SizedBox(height: 20),

            // Contact Support
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getTranslatedStillNeedHelp(languageProvider),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(
                    _getTranslatedSupportDescription(languageProvider),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(_getTranslatedContactSupport(languageProvider)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Info Cards (equal height)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _infoCard(
                        Icons.menu_book_outlined,
                        _getTranslatedDocumentation(languageProvider),
                        _getTranslatedDocumentationSubtitle(languageProvider),
                        Colors.purple,
                        languageProvider),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                        Icons.play_circle_outline,
                        _getTranslatedTutorials(languageProvider),
                        _getTranslatedTutorialsSubtitle(languageProvider),
                        Colors.pink,
                        languageProvider),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                        Icons.people_outlined,
                        _getTranslatedCommunity(languageProvider),
                        _getTranslatedCommunitySubtitle(languageProvider),
                        Colors.deepPurple,
                        languageProvider),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Support Option Card ---
  Widget _supportOption(IconData icon, String title, String subtitle,
      Color color, LanguageProvider languageProvider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // --- FAQ Item ---
  Widget _buildFAQItem(int index, String question, String answer,
      LanguageProvider languageProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300)),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(_getTranslatedFAQQuestion(question, languageProvider),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        iconColor: Colors.black,
        collapsedIconColor: Colors.black,
        onExpansionChanged: (expanded) => setState(() {}),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(_getTranslatedFAQAnswer(answer, languageProvider),
                style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  // --- Info Card ---
  Widget _infoCard(IconData icon, String title, String subtitle, Color color,
      LanguageProvider languageProvider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "مركز المساعدة";
    if (lang == 'am') return "የእገዛ ማዕከል";
    return "Help Center";
  }

  String _getTranslatedSubtitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "ابحث عن إجابات لأسئلتك واحصل على الدعم";
    if (lang == 'am') return "ለጥያቄዎችዎ መልስ ያግኙ እና ድጋፍ ያግኙ";
    return "Find answers to your questions and get support";
  }

  String _getTranslatedFAQ(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الأسئلة الشائعة";
    if (lang == 'am') return "ተደጋግሞ የሚጠየቁ ጥያቄዎች";
    return "FAQ";
  }

  String _getTranslatedFAQSubtitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "ابحث عن إجابات للأسئلة الشائعة";
    if (lang == 'am') return "ለተለመዱ ጥያቄዎች መልስ ያግኙ";
    return "Find answers to common questions";
  }

  String _getTranslatedEmail(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "البريد الإلكتروني";
    if (lang == 'am') return "ኢሜይል";
    return "Email";
  }

  String _getTranslatedEmailSubtitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الدعم عبر البريد الإلكتروني";
    if (lang == 'am') return "የኢሜይል ድጋፍ";
    return "Email Support";
  }

  String _getTranslatedPhone(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الهاتف";
    if (lang == 'am') return "ስልክ";
    return "Phone";
  }

  String _getTranslatedPhoneSubtitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الدعم الهاتفي";
    if (lang == 'am') return "የስልክ ድጋፍ";
    return "Phone Support";
  }

  String _getTranslatedHelpQuestions(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أسئلة المساعدة";
    if (lang == 'am') return "የእገዛ ጥያቄዎች";
    return "Help Questions";
  }

  String _getTranslatedSearchHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "ابحث في مقالات المساعدة...";
    if (lang == 'am') return "የእገዛ መጣጥፎችን ይፈልጉ...";
    return "Search help articles...";
  }

  String _getTranslatedFAQs(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الأسئلة الشائعة";
    if (lang == 'am') return "ተደጋግሞ የሚጠየቁ ጥያቄዎች";
    return "Frequently Asked Questions";
  }

  String _getTranslatedStillNeedHelp(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "لا تزال بحاجة للمساعدة؟";
    if (lang == 'am') return "አሁንም እገዛ ይፈልጋሉ?";
    return "Still Need Help?";
  }

  String _getTranslatedSupportDescription(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar')
      return "لا يمكنك العثور على ما تبحث عنه؟ فريق الدعم لدينا هنا لمساعدتك.";
    if (lang == 'am') return "የሚፈልጉትን ማግኘት አልቻሉም? የእገዛ ቡድናችን እዚህ ያግኙዎታል።";
    return "Can't find what you're looking for? Our support team is here to help.";
  }

  String _getTranslatedContactSupport(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اتصل بالدعم";
    if (lang == 'am') return "ድጋፍ ያግኙ";
    return "Contact Support";
  }

  String _getTranslatedDocumentation(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الوثائق";
    if (lang == 'am') return "ሰነዶች";
    return "Documentation";
  }

  String _getTranslatedDocumentationSubtitle(
      LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "أدلة تفصيلية ووثائق API";
    if (lang == 'am') return "ዝርዝር መመሪያዎች እና API ሰነዶች";
    return "Detailed guides and API documentation";
  }

  String _getTranslatedTutorials(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الدروس";
    if (lang == 'am') return "መማሪያዎች";
    return "Tutorials";
  }

  String _getTranslatedTutorialsSubtitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "دروس فيديو خطوة بخطوة وأدلة";
    if (lang == 'am') return "ደረጃ በደረጃ የቪዲዮ መማሪያዎች እና መመሪያዎች";
    return "Step-by-step video tutorials and guides";
  }

  String _getTranslatedCommunity(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المجتمع";
    if (lang == 'am') return "ማህበረሰብ";
    return "Community";
  }

  String _getTranslatedCommunitySubtitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "انضم إلى منتديات مجتمعنا للمناقشات والدعم";
    if (lang == 'am') return "ለውይይት እና ድጋፍ ወደ ማህበረሰባችን መድረኮች ይቀላቀሉ";
    return "Join our community forums for discussions and support";
  }

  String _getTranslatedTokenNotFound(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الرمز غير موجود، يرجى تسجيل الدخول مرة أخرى";
    if (lang == 'am') return "ቶከን አልተገኘም፣ እባክዎ እንደገና ይግቡ";
    return "Token not found, please login again";
  }

  String _getTranslatedFAQQuestion(
      String question, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    switch (question) {
      case "How do I add a new employee?":
        if (lang == 'ar') return "كيف يمكنني إضافة موظف جديد؟";
        if (lang == 'am') return "አዲስ ሰራተኛ እንዴት ማከል እችላለሁ?";
        return question;

      case "How can I promote an employee profile?":
        if (lang == 'ar') return "كيف يمكنني ترقية ملف موظف؟";
        if (lang == 'am') return "የሰራተኛ መገለጫ እንዴት ማሳደግ እችላለሁ?";
        return question;

      case "What is the difference between reserve and transfer?":
        if (lang == 'ar') return "ما الفرق بين الحجز والنقل؟";
        if (lang == 'am') return "በቦታ ማስያዝ እና ማስተላለፍ መካከል ያለው ልዩነት ምንድነው?";
        return question;

      case "How do I track payments?":
        if (lang == 'ar') return "كيف يمكنني تتبع المدفوعات؟";
        if (lang == 'am') return "ክፍያዎችን እንዴት እከታተላለሁ?";
        return question;

      case "Can I export employee data?":
        if (lang == 'ar') return "هل يمكنني تصدير بيانات الموظفين؟";
        if (lang == 'am') return "የሰራተኞችን ውሂብ ልላክ ይቻለኛል?";
        return question;

      default:
        return question;
    }
  }

  String _getTranslatedFAQAnswer(
      String answer, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    switch (answer) {
      case "Go to Dashboard > Add Employee.":
        if (lang == 'ar') return "اذهب إلى لوحة التحكم > إضافة موظف.";
        if (lang == 'am') return "ወደ ዳሽቦርድ > ሰራተኛ ጨምር ይሂዱ.";
        return answer;

      case "Navigate to Employee Profile > Promotion.":
        if (lang == 'ar') return "انتقل إلى ملف الموظف > الترقية.";
        if (lang == 'am') return "ወደ ሰራተኛ መገለጫ > ማስተዋወቅ ይሂዱ.";
        return answer;

      case "Reserve keeps the slot, transfer reassigns it.":
        if (lang == 'ar') return "الحجز يحتفظ بالفتحة، النقل يعيد تعيينها.";
        if (lang == 'am') return "ቦታ ማስያዝ ቦታውን ይጠብቃል፣ ማስተላለፍ ደግሞ ዳግም ያመድጣል።";
        return answer;

      case "Go to Payment section for full history.":
        if (lang == 'ar')
          return "اذهب إلى قسم المدفوعات للحصول على السجل الكامل.";
        if (lang == 'am') return "ሙሉ ታሪክ ለማግኘት ወደ ክፍያ ክፍል ይሂዱ.";
        return answer;

      case "Yes, from Settings > Export Data.":
        if (lang == 'ar') return "نعم، من الإعدادات > تصدير البيانات.";
        if (lang == 'am') return "አዎ፣ ከቅንብሮች > ውሂብ ላክ ይችላሉ።";
        return answer;

      default:
        return answer;
    }
  }
}
