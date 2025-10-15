import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/employee_profile.dart';
import 'package:marrir/services/user.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class EditProfilePage extends StatefulWidget {
  final Function(Widget) onChildSelected;
  final String userName;
  final String userId;
  final String userImage;
  final String token;

  const EditProfilePage({
    super.key,
    required this.onChildSelected,
    required this.userName,
    required this.userId,
    required this.userImage,
    required this.token,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.userName);
    phoneController = TextEditingController();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // Phone number validation function
  String? _validatePhoneNumber(
      String? value, LanguageProvider languageProvider) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional
    }

    if (!value.startsWith('+')) {
      return _getTranslatedPhoneCountryCodeError(languageProvider);
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^0-9+]'), '');

    if (digitsOnly.length < 8) {
      return _getTranslatedPhoneTooShort(languageProvider);
    }

    if (digitsOnly.length > 16) {
      return _getTranslatedPhoneTooLong(languageProvider);
    }

    return null;
  }

  Future<void> _updateProfile(LanguageProvider languageProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final fullName = fullNameController.text.trim();
      final firstName =
          fullName.contains(" ") ? fullName.split(" ").first : fullName;
      final lastName = fullName.contains(" ") ? fullName.split(" ").last : "";

      final response = await ApiService.updateUserProfile(
        userId: widget.userId,
        token: widget.token,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ??
              _getTranslatedProfileUpdated(languageProvider)),
          backgroundColor: Colors.green,
        ),
      );

      widget.onChildSelected(
        ProfilePage(onChildSelected: widget.onChildSelected),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = _getTranslatedUpdateFailed(languageProvider);

      if (e.toString().contains("phone_number")) {
        if (e.toString().contains("format") ||
            e.toString().contains("invalid")) {
          errorMessage = _getTranslatedInvalidPhoneFormat(languageProvider);
        } else if (e.toString().contains("already exists")) {
          errorMessage = _getTranslatedPhoneAlreadyExists(languageProvider);
        }
      } else if (e.toString().contains("email")) {
        if (e.toString().contains("invalid") ||
            e.toString().contains("format")) {
          errorMessage = _getTranslatedInvalidEmailFormat(languageProvider);
        } else if (e.toString().contains("already exists")) {
          errorMessage = _getTranslatedEmailAlreadyExists(languageProvider);
        }
      } else {
        errorMessage =
            "${_getTranslatedUpdateFailed(languageProvider)}: ${e.toString()}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Stack(
              children: [
                ClipPath(clipper: WaveClipper1(), child: _buildWaveBox1()),
                ClipPath(clipper: WaveClipper2(), child: _buildWaveBox2()),
                ClipPath(clipper: WaveClipper3(), child: _buildWaveBox3()),
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          widget.onChildSelected(
                            ProfilePage(
                                onChildSelected: widget.onChildSelected),
                          );
                        },
                      ),
                      Text(
                        _getTranslatedEditProfileTitle(languageProvider),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 26),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: (widget.userImage.isNotEmpty)
                            ? NetworkImage(widget.userImage)
                            : null,
                        child: (widget.userImage.isEmpty)
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.blue)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "${_getTranslatedId(languageProvider)}: ${widget.userId}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildLabeledTextField(
                    _getTranslatedFullNameLabel(languageProvider),
                    fullNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _getTranslatedFullNameRequired(languageProvider);
                      }
                      return null;
                    },
                    languageProvider: languageProvider,
                  ),
                  _buildLabeledTextField(
                    _getTranslatedPhoneNumberLabel(languageProvider),
                    phoneController,
                    validator: (value) =>
                        _validatePhoneNumber(value, languageProvider),
                    hintText: _getTranslatedPhoneHint(languageProvider),
                    keyboardType: TextInputType.phone,
                    languageProvider: languageProvider,
                  ),
                  _buildLabeledTextField(
                    _getTranslatedEmailLabel(languageProvider),
                    emailController,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if (!emailRegex.hasMatch(value)) {
                          return _getTranslatedValidEmailRequired(
                              languageProvider);
                        }
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    languageProvider: languageProvider,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTranslatedPhoneFormatTitle(languageProvider),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTranslatedPhoneFormatDescription(
                              languageProvider),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _updateProfile(languageProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF65B2C9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      _getTranslatedUpdateProfileButton(languageProvider),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBox1() => Container(
        height: 260,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 125, 180, 197),
              Color.fromARGB(255, 171, 120, 180)
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      );

  Widget _buildWaveBox2() => Container(
        height: 260,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 156, 102, 166), Color(0xFF65B2C9)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      );

  Widget _buildWaveBox3() =>
      Container(height: 260, color: Colors.white.withOpacity(0.2));

  Widget _buildLabeledTextField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    String? hintText,
    TextInputType? keyboardType,
    required LanguageProvider languageProvider,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFEAF6FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintText: hintText,
              errorMaxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedEditProfileTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تعديل الملف الشخصي";
    if (lang == 'am') return "መገለጫ አስተካክል";
    return "Edit Profile";
  }

  String _getTranslatedId(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الرقم";
    if (lang == 'am') return "መለያ";
    return "ID";
  }

  String _getTranslatedFullNameLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الاسم الكامل";
    if (lang == 'am') return "ሙሉ ስም";
    return "Full Name";
  }

  String _getTranslatedFullNameRequired(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "يرجى إدخال الاسم الكامل";
    if (lang == 'am') return "እባክዎ ሙሉ ስምዎን ያስገቡ";
    return "Please enter your full name";
  }

  String _getTranslatedPhoneNumberLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "رقم الهاتف";
    if (lang == 'am') return "ስልክ ቁጥር";
    return "Phone Number";
  }

  String _getTranslatedPhoneHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "+251911223344";
    if (lang == 'am') return "+251911223344";
    return "+251911223344";
  }

  String _getTranslatedEmailLabel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "البريد الإلكتروني";
    if (lang == 'am') return "ኢሜል";
    return "Email Address";
  }

  String _getTranslatedValidEmailRequired(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "يرجى إدخال بريد إلكتروني صحيح";
    if (lang == 'am') return "እባክዎ ትክክለኛ ኢሜል ያስገቡ";
    return "Please enter a valid email address";
  }

  String _getTranslatedPhoneFormatTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "صيغة رقم الهاتف:";
    if (lang == 'am') return "የስልክ ቁጥር ቅርጸት:";
    return "Phone Number Format:";
  }

  String _getTranslatedPhoneFormatDescription(
      LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "• يجب أن يبدأ برمز الدولة (مثال: +251 لإثيوبيا)";
    if (lang == 'am') return "• ከአገር ኮድ መጀመር አለበት (ለምሳሌ: +251 ለኢትዮጵያ)";
    return "• Must start with country code (e.g., +251 for Ethiopia)";
  }

  String _getTranslatedUpdateProfileButton(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تحديث الملف الشخصي";
    if (lang == 'am') return "መገለጫ አዘምን";
    return "Update Profile";
  }

  // Validation error messages
  String _getTranslatedPhoneCountryCodeError(
      LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar')
      return "رقم الهاتف يجب أن يبدأ برمز الدولة (مثال: +251...)";
    if (lang == 'am') return "ስልክ ቁጥሩ ከአገር ኮድ መጀመር አለበት (ለምሳሌ: +251...)";
    return "Phone number must start with country code (e.g., +251...)";
  }

  String _getTranslatedPhoneTooShort(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "رقم الهاتف قصير جداً";
    if (lang == 'am') return "ስልክ ቁጥሩ በጣም አጭር ነው";
    return "Phone number is too short";
  }

  String _getTranslatedPhoneTooLong(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "رقم الهاتف طويل جداً";
    if (lang == 'am') return "ስልክ ቁጥሩ በጣም ረጅም ነው";
    return "Phone number is too long";
  }

  // Success and error messages
  String _getTranslatedProfileUpdated(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم تحديث الملف الشخصي";
    if (lang == 'am') return "መገለጫ ተዘምኗል";
    return "Profile updated";
  }

  String _getTranslatedUpdateFailed(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "فشل التحديث";
    if (lang == 'am') return "ማዘመን አልተሳካም";
    return "Update failed";
  }

  String _getTranslatedInvalidPhoneFormat(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar')
      return "صيغة رقم الهاتف غير صحيحة. يرجى استخدام صيغة رمز الدولة (مثال: +251911223344)";
    if (lang == 'am')
      return "የስልክ ቁጥር ቅርጸት ትክክል አይደለም። እባክዎ የአገር ኮድ ቅርጸት ይጠቀሙ (ለምሳሌ: +251911223344)";
    return "Invalid phone number format. Please use country code format (e.g., +251911223344)";
  }

  String _getTranslatedPhoneAlreadyExists(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "رقم الهاتف مسجل مسبقاً مع حساب آخر";
    if (lang == 'am') return "ስልክ ቁጥሩ በሌላ መለያ ተመዝግቧል";
    return "Phone number already registered with another account";
  }

  String _getTranslatedInvalidEmailFormat(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "صيغة البريد الإلكتروني غير صحيحة";
    if (lang == 'am') return "የኢሜል ቅርጸት ትክክል አይደለም";
    return "Invalid email format";
  }

  String _getTranslatedEmailAlreadyExists(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "البريد الإلكتروني مسجل مسبقاً مع حساب آخر";
    if (lang == 'am') return "ኢሜሉ በሌላ መለያ ተመዝግቧል";
    return "Email already registered with another account";
  }
}

// Wave Clippers (keep your existing WaveClipper classes)
class WaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.7);
    var firstControl = Offset(size.width * 0.25, size.height * 0.85);
    var firstEnd = Offset(size.width * 0.5, size.height * 0.7);
    path.quadraticBezierTo(
      firstControl.dx,
      firstControl.dy,
      firstEnd.dx,
      firstEnd.dy,
    );
    var secondControl = Offset(size.width * 0.75, size.height * 0.55);
    var secondEnd = Offset(size.width, size.height * 0.7);
    path.quadraticBezierTo(
      secondControl.dx,
      secondControl.dy,
      secondEnd.dx,
      secondEnd.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.6);
    var firstControl = Offset(size.width * 0.25, size.height * 0.75);
    var firstEnd = Offset(size.width * 0.5, size.height * 0.6);
    path.quadraticBezierTo(
      firstControl.dx,
      firstControl.dy,
      firstEnd.dx,
      firstEnd.dy,
    );
    var secondControl = Offset(size.width * 0.75, size.height * 0.45);
    var secondEnd = Offset(size.width, size.height * 0.6);
    path.quadraticBezierTo(
      secondControl.dx,
      secondControl.dy,
      secondEnd.dx,
      secondEnd.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WaveClipper3 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.5);
    var firstControl = Offset(size.width * 0.25, size.height * 0.65);
    var firstEnd = Offset(size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(
      firstControl.dx,
      firstControl.dy,
      firstEnd.dx,
      firstEnd.dy,
    );
    var secondControl = Offset(size.width * 0.75, size.height * 0.35);
    var secondEnd = Offset(size.width, size.height * 0.5);
    path.quadraticBezierTo(
      secondControl.dx,
      secondControl.dy,
      secondEnd.dx,
      secondEnd.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
