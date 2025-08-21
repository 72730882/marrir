import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/setting.dart';
import 'package:marrir/Component/Employee/wave_background.dart';

class NotificationSettingsPage extends StatelessWidget {
  final Function(Widget) onChildSelected;

  const NotificationSettingsPage({super.key, required this.onChildSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with waves (same as ProfilePage)
        WaveBackground(
          title: "Terms And Conditions",
          onBack: () {
            onChildSelected(SettingPage(onChildSelected: onChildSelected));
          },
          onNotification: () {},
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildNotificationOption("General Notification"),
              _buildNotificationOption("Sound"),
              _buildNotificationOption("Sound Call"),
              _buildNotificationOption("Vibrate"),
              _buildNotificationOption("Transaction Update"),
              _buildNotificationOption("Expense Reminder"),
              _buildNotificationOption("Budget Notifications"),
              _buildNotificationOption("Low Balance Alerts"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationOption(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Switch(
            value: true, // Set your actual value here
            onChanged: (bool value) {
              // Handle switch change
            },
            activeColor: const Color(0xFF65B2C9),
          ),
        ],
      ),
    );
  }
}

// Wave Clippers (same as ProfilePage)
