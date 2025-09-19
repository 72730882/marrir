import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSecurity/security.dart';
import 'package:marrir/Component/Employee/wave_background.dart';
import 'package:marrir/services/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

// StatefulWidget wrapper
class ChangePinPage extends StatefulWidget {
  final Function(Widget)? onChildSelected;

  const ChangePinPage({super.key, this.onChildSelected});

  @override
  State<ChangePinPage> createState() => ChangePinPageState();
}

class ChangePinPageState extends State<ChangePinPage> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final TextEditingController _currentPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  // Show success dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'Pin Has Been Changed Successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (widget.onChildSelected != null) {
                        widget.onChildSelected!(
                          SecurityPage(
                              onChildSelected: widget.onChildSelected!),
                        );
                      } else {
                        Navigator.of(context).pop();
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
        );
      },
    );
  }

  // Handle Change Pin button pressed
  Future<void> _handleChangePin() async {
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (newPin.isEmpty || confirmPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (newPin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New Pin and Confirm Pin do not match')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("user_id");
      final token = prefs.getString("token");

      if (userId == null || token == null) {
        throw Exception("User not logged in or token missing.");
      }

      await ApiService.updateUserProfile(
        userId: userId,
        token: token,
        firstName: "", // no change
        lastName: "", // no change
        password: newPin, // send new pin as password
      );

      _showSuccessDialog(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  InputDecoration _pinInputDecoration(bool obscure, VoidCallback toggle) {
    return InputDecoration(
      filled: true,
      fillColor: const Color.fromRGBO(142, 198, 214, 0.3),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
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
      body: Column(
        children: [
          WaveBackground(
            title: "Change Pin",
            onBack: () {
              if (widget.onChildSelected != null) {
                widget.onChildSelected!(
                    SecurityPage(onChildSelected: widget.onChildSelected!));
              } else {
                Navigator.pop(context);
              }
            },
            onNotification: () {},
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Pin',
                      style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _currentPinController,
                    obscureText: _obscureCurrent,
                    keyboardType: TextInputType.number,
                    decoration: _pinInputDecoration(_obscureCurrent, () {
                      setState(() => _obscureCurrent = !_obscureCurrent);
                    }),
                  ),
                  const SizedBox(height: 20),
                  const Text('New Pin',
                      style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _newPinController,
                    obscureText: _obscureNew,
                    keyboardType: TextInputType.number,
                    decoration: _pinInputDecoration(_obscureNew, () {
                      setState(() => _obscureNew = !_obscureNew);
                    }),
                  ),
                  const SizedBox(height: 20),
                  const Text('Confirm Pin',
                      style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPinController,
                    obscureText: _obscureConfirm,
                    keyboardType: TextInputType.number,
                    decoration: _pinInputDecoration(_obscureConfirm, () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    }),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleChangePin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Change Pin',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
