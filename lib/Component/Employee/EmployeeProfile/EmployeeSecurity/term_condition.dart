import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSecurity/security.dart';
import 'package:marrir/Component/Employee/wave_background.dart';

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
    return Scaffold(
      body: Column(
        children: [
          // Header with waves
          WaveBackground(
            title: "Terms And Conditions",
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Terms and conditions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Lorem ipsum dolor Lorem ipsum dolor Lorem ipsum dolor "
                      "Lorem ipsum dolor Lorem ipsum dolor Lorem ipsum dolor "
                      "Lorem ipsum dolor Lorem ipsum dolor Lorem ipsum dolor.",
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "1. Lorem ipsum dolor.\n"
                      "2. Lorem ipsum dolor.\n"
                      "3. Lorem ipsum dolor.\n"
                      "4. Lorem ipsum dolor.\n",
                    ),
                    const Text(
                      "Lorem ipsum dolor Lorem ipsum dolor Lorem ipsum dolor "
                      "Lorem ipsum dolor Lorem ipsum dolor.",
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "• Lorem ipsum dolor.\n"
                      "• Lorem ipsum dolor Lorem ipsum dolor.\n",
                    ),
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
                        const Expanded(
                          child: Text(
                            "I accept all the terms and conditions",
                            style: TextStyle(fontSize: 14),
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
                          disabledBackgroundColor: Color.fromRGBO(
                            142,
                            198,
                            214,
                            1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Accept",
                          style: TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }
}
