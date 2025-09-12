import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:country_picker/country_picker.dart';
import '../../services/api_service.dart'; // <-- make sure you created this file

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isCompany = true;
  bool agreeTerms = false;
  String? selectedCountry;
  String? selectedAccountType;

  // ===== Controllers =====
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final Map<String, String> accountTypeLabels = {
  "agent": "Foreign Employment Agent",
  "recruitment": "Recruitment Firm",
  "sponsor": "Employer",
  "employee": "Employee",
  "selfsponsor": "Self Sponsor",
};

List<String> get accountTypeOptions {
  return isCompany
      ? ["agent", "recruitment", "sponsor"]
      : ["employee", "selfsponsor"];
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===== HEADER =====
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
              const Text(
                "Create Account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // ===== Toggle Company / Individual =====
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => isCompany = true),
                      child: Text(
                        "Company",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isCompany ? FontWeight.bold : FontWeight.normal,
                          color: isCompany ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => isCompany = false),
                      child: Text(
                        "Individual",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              !isCompany ? FontWeight.bold : FontWeight.normal,
                          color: !isCompany ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== FORM =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First + Last Name
                    Row(
                      children: [
                        Expanded(
                          child: _buildLabeledField(
                            "First Name",
                            controller: firstNameController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildLabeledField(
                            "Last Name",
                            controller: lastNameController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    _buildLabeledField("Email Address",
                        controller: emailController),
                    const SizedBox(height: 15),

                    _buildLabeledField("Phone Number",
                        controller: phoneController, prefixIcon: Icons.flag),
                    const SizedBox(height: 15),

                    // Country picker
                    const Text("Country",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: false,
                          onSelect: (Country country) {
                            setState(() {
                              selectedCountry = country.name;
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF48C2E9)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedCountry ?? "Select country",
                                style: const TextStyle(fontSize: 16)),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Account type checkboxes
                    const Text("Account Type",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Column(
                      children: accountTypeOptions.map((type) {
                        bool isSelected = selectedAccountType == type;
                        return Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  selectedAccountType = type;
                                });
                              },
                              activeColor: const Color(0xFF7B4BBA),
                            ),
                            Text(accountTypeLabels[type] ?? type, style: const TextStyle(fontSize: 16))
,
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),

                    _buildLabeledField("Password",
                        controller: passwordController, obscure: true),
                    const SizedBox(height: 15),

                    _buildLabeledField("Confirm Password",
                        controller: confirmPasswordController, obscure: true),
                    const SizedBox(height: 15),

                    // Terms
                    Row(
                      children: [
                        Checkbox(
                          value: agreeTerms,
                          onChanged: (val) =>
                              setState(() => agreeTerms = val ?? false),
                        ),
                        const Expanded(
                          child: Text("I agree to the terms and conditions"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Sign Up button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF65b2c9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
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

  // ===== Helper widget with label =====
  Widget _buildLabeledField(String label,
      {TextEditingController? controller,
      IconData? prefixIcon,
      bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: label,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  // ===== API Call =====
  Future<void> _registerUser() async {
    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must agree to terms")),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    final data = {
      "first_name": firstNameController.text,
      "last_name": lastNameController.text,
      "email": emailController.text,
      "phone_number": phoneController.text,
      "country": selectedCountry,
      "role": selectedAccountType,
      "password": passwordController.text,
    };

    try {
      final response = await ApiService.registerUser(data);
      print("✅ Registered: $response");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }
  }
}

// ===== Custom header clipper =====
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height - 50);
    path.quadraticBezierTo(
        size.width * 0.75, size.height - 100, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
