import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/delete.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/notification.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/password_setting.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/employee_profile.dart';
import 'package:marrir/Component/Employee/wave_background.dart';

class SettingPage extends StatelessWidget {
  final Function(Widget) onChildSelected;

  const SettingPage({super.key, required this.onChildSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with waves
        WaveBackground(
          title: "Setting",
          onBack: () {
            onChildSelected(ProfilePage(onChildSelected: onChildSelected));
          },
          onNotification: () {},
        ),

        const SizedBox(height: 20),

        Expanded(
          child: ListView(
            children: [
              _buildSecurityOption(
                "Notification Settings",
                Icons.notifications,
                onTap: () {
                  onChildSelected(
                    NotificationSettingsPage(onChildSelected: onChildSelected),
                  );
                },
              ),
              _buildSecurityOption(
                "Password Settings",
                Icons.lock,
                onTap: () {
                  // Replace with your TermsAndConditionsPage widget
                  onChildSelected(
                    PassWordPinPage(onChildSelected: onChildSelected),
                  );
                },
              ),
              _buildSecurityOption(
                "Delete Account",
                Icons.delete,
                onTap: () {
                  // Replace with your TermsAndConditionsPage widget
                  onChildSelected(
                    DeleteAccountPage(
                      onChildSelected: onChildSelected,
                      userId: '',
                      accessToken: '',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityOption(
    String title,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF65B2C9),
      ), // Add this line to use the icon parameter
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

// Add these at the bottom of your file or in separate files:
