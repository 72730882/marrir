import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/setting.dart';
import 'package:marrir/Component/Employee/wave_background.dart';

class NotificationSettingsPage extends StatelessWidget {
  final Function(Widget) onChildSelected;

  const NotificationSettingsPage({super.key, required this.onChildSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          // Wave header scrolls with content
          WaveBackground(
            title: "Notification Settings",
            onBack: () {
              onChildSelected(SettingPage(onChildSelected: onChildSelected));
            },
            onNotification: () {},
          ),

          // List of notification options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
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
      ),
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
            value: true, // Replace with actual state
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
