import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marrir/services/Employee/cv_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class StepPassport extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onNextStep;

  const StepPassport({
    super.key,
    required this.onSuccess,
    required this.onNextStep,
  });

  @override
  State<StepPassport> createState() => _StepPassportState();
}

class _StepPassportState extends State<StepPassport> {
  File? _passportFile;
  bool _isLoading = false;
  String _fileName = "";
  String? _errorMessage;
  String? _userId;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeFileName();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString("user_id");
    });
  }

  void _initializeFileName() {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    setState(() {
      _fileName = _getTranslatedNoFileChosen(languageProvider);
    });
  }

  Future<void> _pickPassportImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1200,
        maxHeight: 1600,
      );

      if (image != null) {
        setState(() {
          _passportFile = File(image.path);
          _fileName = image.name;
          _errorMessage = null;
        });
      }
    } catch (e) {
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      setState(() {
        _errorMessage =
            _getTranslatedImagePickError(e.toString(), languageProvider);
      });
    }
  }

  Future<void> _uploadPassport() async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    if (_passportFile == null) {
      setState(() {
        _errorMessage = _getTranslatedNoFileSelected(languageProvider);
      });
      return;
    }

    if (_userId == null) {
      setState(() {
        _errorMessage = _getTranslatedUserNotIdentified(languageProvider);
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("access_token");

      if (token == null) {
        throw Exception(_getTranslatedNotAuthenticated(languageProvider));
      }

      final result = await CVService.uploadPassport(
        passportFile: _passportFile!,
        userId: _userId!,
        token: token,
      );

      if ((result["id"] != null || result["user_id"] != null)) {
        widget.onSuccess();
        widget.onNextStep();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getTranslatedUploadSuccess(languageProvider)),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(_getTranslatedUploadFailed(languageProvider));
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            _getTranslatedUploadError(e.toString(), languageProvider);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_getTranslatedUploadError(e.toString(), languageProvider)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    const Color primaryColor = Color(0xFF8EC6D6);
    const Color borderColor = Color(0xFFD1D1D6);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Title
          Text(
            _getTranslatedStepTitle(languageProvider),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          // User info (for debugging/confirmation)
          if (_userId != null)
            Text(
              _getTranslatedUserInfo(_userId!, languageProvider),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            _getTranslatedSubtitle(languageProvider),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          // Warning Text
          Text(
            _getTranslatedWarningText(languageProvider),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // Upload Box
          GestureDetector(
            onTap: _pickPassportImage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              decoration: BoxDecoration(
                border:
                    Border.all(color: borderColor, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
                color: _passportFile != null ? Colors.green[50] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _passportFile != null
                        ? Icons.check_circle
                        : Icons.cloud_upload_outlined,
                    size: 40,
                    color: _passportFile != null ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _passportFile != null
                        ? _getTranslatedPassportSelected(languageProvider)
                        : _getTranslatedTapToUpload(languageProvider),
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          _passportFile != null ? Colors.green : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _pickPassportImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        _getTranslatedChooseFile(languageProvider),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _fileName,
                    style: TextStyle(
                      fontSize: 12,
                      color: _passportFile != null ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Preview image (if selected)
          if (_passportFile != null) ...[
            Text(
              _getTranslatedPreview(languageProvider),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.file(
                _passportFile!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _uploadPassport,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _getTranslatedSubmitPassport(languageProvider),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          // Loading indicator
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 8),
            Text(
              _getTranslatedUploading(languageProvider),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedStepTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الخطوة 1: مسح جواز السفر";
    if (lang == 'am') return "ደረጃ 1: ፓስፖርት ማስቀመጫ";
    return "Step 1: Passport Scan";
  }

  String _getTranslatedUserInfo(
      String userId, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    final shortId = userId.substring(0, 8);
    if (lang == 'ar') return "التحميل للمستخدم: $shortId...";
    if (lang == 'am') return "ለተጠቃሚ መጫን: $shortId...";
    return "Uploading for user: $shortId...";
  }

  String _getTranslatedSubtitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "امسح جواز سفرك";
    if (lang == 'am') return "ፓስፖርትዎን ይቅረጹ";
    return "Scan Your Passport";
  }

  String _getTranslatedWarningText(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تأكد من أن منطقة MRZ في الأسفل واضحة للعيان!";
    if (lang == 'am') return "ከታች ያለው የMRZ ቦታ በግልጽ እንደሚታይ ያረጋግጡ!";
    return "Make sure the MRZ zone at the bottom is clearly visible!";
  }

  String _getTranslatedPassportSelected(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم اختيار جواز السفر";
    if (lang == 'am') return "ፓስፖርት ተመርጧል";
    return "Passport selected";
  }

  String _getTranslatedTapToUpload(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "انقر لتحميل مسح جواز السفر";
    if (lang == 'am') return "ፓስፖርት ለማስቀመጥ ይንኩ";
    return "Tap to upload passport scan";
  }

  String _getTranslatedChooseFile(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر الملف";
    if (lang == 'am') return "ፋይል ይምረጡ";
    return "Choose File";
  }

  String _getTranslatedNoFileChosen(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "لم يتم اختيار ملف";
    if (lang == 'am') return "ምንም ፋይል አልተመረጠም";
    return "No file chosen";
  }

  String _getTranslatedPreview(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "معاينة:";
    if (lang == 'am') return "ቅድመ እይታ:";
    return "Preview:";
  }

  String _getTranslatedSubmitPassport(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إرسال جواز السفر";
    if (lang == 'am') return "ፓስፖርት አስገባ";
    return "Submit Passport";
  }

  String _getTranslatedUploading(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "جاري تحميل جواز السفر...";
    if (lang == 'am') return "ፓስፖርት እየተጫነ ነው...";
    return "Uploading passport...";
  }

  // Error message translations
  String _getTranslatedNoFileSelected(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "يرجى اختيار صورة جواز السفر أولاً";
    if (lang == 'am') return "እባክዎ የፓስፖርት ምስል ይምረጡ";
    return "Please select a passport image first";
  }

  String _getTranslatedUserNotIdentified(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar')
      return "لم يتم التعرف على المستخدم. يرجى تسجيل الدخول مرة أخرى.";
    if (lang == 'am') return "ተጠቃሚ አልታወቀም። እባክዎ እንደገና ይግቡ።";
    return "User not identified. Please login again.";
  }

  String _getTranslatedNotAuthenticated(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المستخدم غير مصرح به";
    if (lang == 'am') return "ተጠቃሚው አልተፈቀደም";
    return "User not authenticated";
  }

  String _getTranslatedUploadSuccess(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم تحميل جواز السفر بنجاح!";
    if (lang == 'am') return "ፓስፖርት በተሳካ ሁኔታ ተጫኗል!";
    return "Passport uploaded successfully!";
  }

  String _getTranslatedUploadFailed(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "فشل تحميل جواز السفر - تنسيق استجابة غير صالح";
    if (lang == 'am') return "ፓስፖርት መጫን አልተሳካም - የማይሰራ የምላሽ ቅርጸት";
    return "Failed to upload passport - invalid response format";
  }

  String _getTranslatedUploadError(
      String error, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "فشل التحميل: $error";
    if (lang == 'am') return "መጫን አልተሳካም: $error";
    return "Upload failed: $error";
  }

  String _getTranslatedImagePickError(
      String error, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "فشل اختيار الصورة: $error";
    if (lang == 'am') return "ምስል መምረጥ አልተሳካም: $error";
    return "Failed to pick image: $error";
  }
}
