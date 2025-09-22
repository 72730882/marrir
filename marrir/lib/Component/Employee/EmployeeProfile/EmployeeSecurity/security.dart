import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSecurity/term_condition.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/employee_profile.dart';
import 'package:marrir/Component/Employee/wave_background.dart';

class SecurityPage extends StatelessWidget {
  final Function(Widget) onChildSelected;

  const SecurityPage({super.key, required this.onChildSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ Reuse the shared wave background
        WaveBackground(
          title: "Security",
          onBack: () {
            onChildSelected(ProfilePage(onChildSelected: onChildSelected));
          },
          onNotification: () {},
        ),

        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Security",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),

        Expanded(
          child: ListView(
            children: [
              // _buildSecurityOption(
              //   "Change Pin",
              //   onTap: () {
              //     onChildSelected(
              //       ChangePinPage(
              //         onChildSelected: onChildSelected,
              //       ),
              //     );
              //   },
              // ),
              _buildSecurityOption(
                "Terms And Conditions",
                onTap: () {
                  onChildSelected(
                    TermConditionPage(onChildSelected: onChildSelected),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityOption(String title, {required VoidCallback onTap}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color.fromARGB(221, 20, 20, 20),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: onTap,
    );
  }
}
