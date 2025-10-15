import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/Employee/dashboard_service.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  // Store ratings for each question
  final Map<int, int> _ratings = {};
  bool _isSubmitting = false;
  bool _isSubmitted = false; // Add this flag to track submission state

  // Questions list
  final List<String> _questions = [
    "Rate your ability to work under pressure",
    "Rate your time management skills",
    "Rate your communication skills",
    "Rate your teamwork and collaboration ability",
    "Rate your flexibility and adaptability to change",
    "Rate your problem-solving skills",
    "Rate your willingness to learn new skills and technologies",
    "Rate your attention to detail",
    "Rate your ability to follow instructions",
  ];

  Future<void> _submitRatings() async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    // Check if all questions are answered
    if (_ratings.length != _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_getTranslatedAnswerAllQuestions(languageProvider))),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Calculate average rating from all questions
      final totalRating = _ratings.values.reduce((a, b) => a + b);
      final averageRating = totalRating / _ratings.length;

      // Prepare rating data with SHORTENED description
      final ratingData = {
        "value": averageRating,
        "description":
            "Self-rating: ${averageRating.toStringAsFixed(1)}/5 average", // Short description
      };

      final response = await EmployeeDashboardService.submitRatings(ratingData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message'] ??
                _getTranslatedRatingsSubmitted(languageProvider))),
      );

      // REMOVED Navigator.pop(context) - Stay on this screen
      setState(() {
        _isSubmitted = true; // Mark as submitted
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("${_getTranslatedFailedToSubmit(languageProvider)}: $e")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _resetRatings() {
    setState(() {
      _ratings.clear();
      _isSubmitted = false;
    });
  }

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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show success message if submitted
                  if (_isSubmitted)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            _getTranslatedSuccessMessage(languageProvider),
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),

                  Text(
                    _getTranslatedDescription(languageProvider),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),

                  // Render each question with stars
                  ...List.generate(
                    _questions.length,
                    (index) => _buildRatingQuestion(
                        index, _questions[index], languageProvider),
                  ),
                ],
              ),
            ),
          ),

          // Submit Button or Reset Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: _isSubmitted
                ? ElevatedButton(
                    onPressed: _resetRatings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _getTranslatedSubmitNewRating(languageProvider),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRatings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _getTranslatedSubmit(languageProvider),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  // Widget for a single rating question
  Widget _buildRatingQuestion(
      int index, String question, LanguageProvider languageProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getTranslatedQuestion(question, languageProvider),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (starIndex) {
              final rating = _ratings[index] ?? 0;
              return IconButton(
                onPressed: _isSubmitted
                    ? null // Disable stars after submission
                    : () {
                        setState(() {
                          _ratings[index] = starIndex + 1;
                        });
                      },
                icon: Icon(
                  Icons.star,
                  color: starIndex < rating ? Colors.red : Colors.grey,
                  size: 28,
                ),
              );
            }),
          ),
          if (_ratings[index] != null)
            Text(
              "${_getTranslatedSelected(languageProvider)}: ${_ratings[index]} ${_getTranslatedStars(languageProvider)}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "التقييم";
    if (lang == 'am') return "ደረጃ";
    return "Rating";
  }

  String _getTranslatedDescription(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "يرجى الإجابة على الأسئلة أدناه للحصول على تقييمك";
    if (lang == 'am') return "ደረጃዎን ለማግኘት ከዚህ በታች ያሉትን ጥያቄዎች ይመልሱ";
    return "Please answer the questions asked below to get your rating";
  }

  String _getTranslatedSuccessMessage(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم تقديم التقييم بنجاح!";
    if (lang == 'am') return "ደረጃ በተሳካ ሁኔታ ቀርቧል!";
    return "Rating submitted successfully!";
  }

  String _getTranslatedSubmitNewRating(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تقديم تقييم جديد";
    if (lang == 'am') return "አዲስ ደረጃ አስገባ";
    return "Submit New Rating";
  }

  String _getTranslatedSubmit(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تقديم";
    if (lang == 'am') return "አስገባ";
    return "Submit";
  }

  String _getTranslatedSelected(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المحدد";
    if (lang == 'am') return "የተመረጠ";
    return "Selected";
  }

  String _getTranslatedStars(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "نجوم";
    if (lang == 'am') return "ኮከቦች";
    return "stars";
  }

  String _getTranslatedAnswerAllQuestions(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "يرجى الإجابة على جميع الأسئلة";
    if (lang == 'am') return "እባክዎ ሁሉንም ጥያቄዎች ይመልሱ";
    return "Please answer all questions";
  }

  String _getTranslatedRatingsSubmitted(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم تقديم التقييمات بنجاح!";
    if (lang == 'am') return "ደረጃዎች በተሳካ ሁኔታ ቀርበዋል!";
    return "Ratings submitted successfully!";
  }

  String _getTranslatedFailedToSubmit(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "فشل في تقديم التقييمات";
    if (lang == 'am') return "ደረጃዎች ማስገባት አልተሳካም";
    return "Failed to submit ratings";
  }

  String _getTranslatedTokenNotFound(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الرمز غير موجود، يرجى تسجيل الدخول مرة أخرى";
    if (lang == 'am') return "ቶከን አልተገኘም፣ እባክዎ እንደገና ይግቡ";
    return "Token not found, please login again";
  }

  String _getTranslatedQuestion(
      String question, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    switch (question) {
      case "Rate your ability to work under pressure":
        if (lang == 'ar') return "قيم قدرتك على العمل تحت الضغط";
        if (lang == 'am') return "በግፊት ስር የማሰር ችሎታዎን ይገምግሙ";
        return question;

      case "Rate your time management skills":
        if (lang == 'ar') return "قيم مهاراتك في إدارة الوقت";
        if (lang == 'am') return "የጊዜ አስተዳደር ክህሎቶችዎን ይገምግሙ";
        return question;

      case "Rate your communication skills":
        if (lang == 'ar') return "قيم مهاراتك في التواصل";
        if (lang == 'am') return "የመገናኛ ክህሎቶችዎን ይገምግሙ";
        return question;

      case "Rate your teamwork and collaboration ability":
        if (lang == 'ar') return "قيم قدرتك على العمل الجماعي والتعاون";
        if (lang == 'am') return "የቡድን ሥራ እና የትብብር ችሎታዎን ይገምግሙ";
        return question;

      case "Rate your flexibility and adaptability to change":
        if (lang == 'ar') return "قيم مرونتك وقدرتك على التكيف مع التغيير";
        if (lang == 'am') return "ለውጥ ተስማሚነትዎን እና ተለዋዋጭነትዎን ይገምግሙ";
        return question;

      case "Rate your problem-solving skills":
        if (lang == 'ar') return "قيم مهاراتك في حل المشكلات";
        if (lang == 'am') return "የችግር መፍትሄ ክህሎቶችዎን ይገምግሙ";
        return question;

      case "Rate your willingness to learn new skills and technologies":
        if (lang == 'ar') return "قيم استعدادك لتعلم مهارات وتقنيات جديدة";
        if (lang == 'am') return "አዳዲስ ክህሎቶች እና ቴክኖሎጂዎች ለመማር ፈቃደኝነትዎን ይገምግሙ";
        return question;

      case "Rate your attention to detail":
        if (lang == 'ar') return "قيم اهتمامك بالتفاصيل";
        if (lang == 'am') return "ለዝርዝሮች ያለዎትን ትኩረት ይገምግሙ";
        return question;

      case "Rate your ability to follow instructions":
        if (lang == 'ar') return "قيم قدرتك على اتباع التعليمات";
        if (lang == 'am') return "መመሪያዎችን የመከተል ችሎታዎን ይገምግሙ";
        return question;

      default:
        return question;
    }
  }
}
