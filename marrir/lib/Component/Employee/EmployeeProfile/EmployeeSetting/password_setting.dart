import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/setting.dart';
import 'package:marrir/Component/Employee/wave_background.dart';
import 'package:marrir/services/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  void _showDialog(String message, {bool success = false}) {
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
                  child: const Text(
                    'OK',
                    style: TextStyle(
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
  Future<void> _handleChangePassword() async {
    final current = _currentController.text.trim();
    final newPass = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showDialog("Please fill all fields.");
      return;
    }

    if (newPass != confirm) {
      _showDialog("New password and confirmation do not match.");
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final String? userId =
          prefs.getString('user_id'); // same as work experience
      final String? token = prefs.getString('access_token');
      if (userId == null || token == null) {
        throw Exception("User not logged in or token missing.");
      }

      // Call API
      await ApiService.updateUserProfile(
        userId: userId,
        token: token,
        firstName: "", // no change
        lastName: "", // no change
        password: newPass,
      );

      _showDialog("Password changed successfully!", success: true);
    } catch (e) {
      _showDialog("Error: $e");
    }
  }

  InputDecoration _pinInputDecoration(bool obscure, VoidCallback toggle) {
    return InputDecoration(
      filled: true,
      fillColor: const Color.fromRGBO(142, 198, 214, 0.3),
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
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset:
          true, // ✅ allows body to resize when keyboard appears
      body: SafeArea(
        child: Column(
          children: [
            WaveBackground(
              title: "Password Settings",
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
                    const Text('Current Password',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _currentController,
                      obscureText: _obscureCurrent,
                      decoration: _pinInputDecoration(_obscureCurrent, () {
                        setState(() => _obscureCurrent = !_obscureCurrent);
                      }),
                    ),
                    const SizedBox(height: 20),
                    const Text('New Password',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newController,
                      obscureText: _obscureNew,
                      decoration: _pinInputDecoration(_obscureNew, () {
                        setState(() => _obscureNew = !_obscureNew);
                      }),
                    ),
                    const SizedBox(height: 20),
                    const Text('Confirm Password',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      decoration: _pinInputDecoration(_obscureConfirm, () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      }),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleChangePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(142, 198, 214, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), // 👌 extra space for keyboard
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
