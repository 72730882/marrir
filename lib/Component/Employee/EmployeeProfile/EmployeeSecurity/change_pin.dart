import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSecurity/security.dart';
import 'package:marrir/Component/Employee/wave_background.dart';

class ChangePinPage extends StatefulWidget {
  final Function(Widget)? onChildSelected;

  const ChangePinPage({super.key, this.onChildSelected});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

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
                  'Pin Has Been\nChanged Successfully',
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
                            onChildSelected: widget.onChildSelected!,
                          ),
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
                        color: Colors.white,
                      ),
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

  InputDecoration _pinInputDecoration(bool obscure, VoidCallback toggle) {
    return InputDecoration(
      filled: true,
      fillColor: const Color.fromRGBO(142, 198, 214, 0.3),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: Colors.black54,
        ),
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
          // Wave Header
          WaveBackground(
            title: "Change Pin",
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

          // Body Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Pin',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    obscureText: _obscureCurrent,
                    keyboardType: TextInputType.number,
                    decoration: _pinInputDecoration(_obscureCurrent, () {
                      setState(() => _obscureCurrent = !_obscureCurrent);
                    }),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'New Pin',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    obscureText: _obscureNew,
                    keyboardType: TextInputType.number,
                    decoration: _pinInputDecoration(_obscureNew, () {
                      setState(() => _obscureNew = !_obscureNew);
                    }),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Confirm Pin',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    obscureText: _obscureConfirm,
                    keyboardType: TextInputType.number,
                    decoration: _pinInputDecoration(_obscureConfirm, () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    }),
                  ),
                  const SizedBox(height: 25),

                  // Change Pin Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showSuccessDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Change Pin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

// Wave clippers (reuse same as SecurityPage)
