import 'package:flutter/material.dart';
import 'package:marrir/Page/Agent/agent_page.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:marrir/Page/Employer/employer_page.dart';
import 'package:marrir/Page/Recruitment/recruitment_page.dart';
import 'register_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/api_service.dart';

// import '../../services/user.dart'; // make sure this file exists

import 'package:shared_preferences/shared_preferences.dart';
// Social login packages
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:marrir/Component/auth/ForgotPassword/forgot_password_screen.dart';
import 'package:marrir/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart'; // Import your LanguageProvider

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? _selectedAccountType;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final Map<String, String> _accountTypes = {
      "agent": lang.t('agency'), // e.g., 'Foreign Employment Agency'
      "recruitment": lang.t('rec_firm'), // e.g., 'Recruitment Firm'
      "sponsor": lang.t('employer'), // e.g., 'Employer'
      "employee": lang.t('employee'), // e.g., 'Employee'
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===== HEADER WITH CURVES =====
              Stack(
                children: [
                  ClipPath(
                    clipper: HeaderClipper(),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF7B4BBA), Color(0xFF48C2E9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 1,
                    child: Image.asset(
                      "assets/images/splash_image/logo3.png",
                      height: 100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  lang.t('login_title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ===== FORM =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('select_role'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: _selectedAccountType,
                      items: _accountTypes.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAccountType = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      lang.t('email'),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    _buildTextField(
                      lang.t('email_adress'),
                      prefixIcon: Icons.email,
                      controller: emailController,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      lang.t('password'),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    _buildTextField(
                      lang.t('password'),
                      obscure: true,
                      controller: passwordController,
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          lang.t('forgot_password'),
                          style: TextStyle(color: Color(0xFF65b2c9)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF65b2c9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          lang.t('sign_in'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (_selectedAccountType == 'employee') ...[
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _handleGoogleLogin,
                          icon: const FaIcon(
                            FontAwesomeIcons.google,
                            color: Color(0xFF4285F4),
                          ),
                          label: Text(
                            lang.t('login_with_google'),
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _handleFacebookLogin,
                          icon: const FaIcon(
                            FontAwesomeIcons.facebook,
                            color: Color(0xFF1877F2),
                          ),
                          label: Text(
                            lang.t('login_with_fb'),
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lang.t(
                              'dont_have_account'), // e.g., "Don't have an account?"
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            lang.t('register'), // e.g., "Register"
                            style: const TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0, bottom: 20.0),
                        child: Image.asset(
                          'assets/images/onboarding_images/logo2.png',
                          width: 70,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint,
      {IconData? prefixIcon,
      bool obscure = false,
      TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ===== LOGIN with role & email check =====
  Future<void> _loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (_selectedAccountType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your account type")),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    try {
      final userData = await ApiService.loginUser(
        email: email,
        password: password,
      );

      final apiRole = (userData['role'] ?? '').toString().toLowerCase();
      final apiEmail = (userData['email'] ?? '').toString().toLowerCase();
      final selectedRole = _selectedAccountType!.toLowerCase();

      if (apiRole.isEmpty || apiEmail.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Invalid user data returned from server")),
        );
        return;

        // Navigate to dashboard based on role, passing token
        Widget page;
        switch (userData["role"].toLowerCase()) {
          case "employee":
            page =
                EmployeePage(token: userData["access_token"]); // ✅ pass token
            break;
          case "agent":
            page = const AgentPage(); // If needed
            break;
          case "employer":
            page = const EmployerPage(); // If needed
            break;
          case "recruitment":
            page = const RecruitmentPage(); // If needed
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Unknown role: ${userData["role"]}")),
            );
            return;
        }

        if (apiRole != selectedRole || apiEmail != email.toLowerCase()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Invalid login. Make sure you're using the correct email and role you registered with.",
              ),
            ),
          );
          return;
        }
      }

      await _saveAndRedirect(userData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      // Initialize GoogleSignIn with serverClientId (Web Client ID from Google Cloud)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            "1007744408168-lqifcb5ffoc8bfauogjuse1meu78elk7.apps.googleusercontent.com",
      );

      // Start the Google sign-in flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User cancelled login

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get the authorization code (backend expects this)
      final String? authCode = googleAuth.serverAuthCode;
      if (authCode == null) {
        throw Exception("No authorization code returned by Google");
      }

      // Call your backend API with the authCode
      final userData = await ApiService.loginWithGoogle(authCode);

      // Save token and redirect to proper page
      await _saveAndRedirect(userData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google login failed: $e")),
      );
    }
  }

  Future<void> _handleFacebookLogin() async {
    try {
      // Trigger the Facebook sign-in
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final String accessToken = result.accessToken!.token;

        // Send accessToken to backend (like Google login uses authCode)
        final Map<String, dynamic> userData =
            await ApiService.loginWithFacebook(accessToken);

        // Save token and redirect user based on role
        await _saveAndRedirect(userData);
      } else if (result.status == LoginStatus.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Facebook login cancelled by user")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Facebook login failed: ${result.message}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Facebook login error: $e")),
      );
    }
  }

  Future<void> _saveAndRedirect(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", userData["access_token"]);
    await prefs.setString("user_role", userData["role"]);
    await prefs.setString("user_email", userData["email"]);
    await prefs.setString("user_id", userData["user_id"]);

    // ✅ Update the provider so app knows user is logged in
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.login(userData['role']);

    Widget page;
    switch (userData["role"].toLowerCase()) {
      case "employee":
        page = EmployeePage(token: userData["access_token"]);

        break;
      case "agent":
        page = const AgentPage();
        break;
      case "sponsor":
        page = const EmployerPage();
        break;
      case "recruitment":
        page = const RecruitmentPage();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unknown role: ${userData["role"]}")),
        );
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 50,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 100,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
