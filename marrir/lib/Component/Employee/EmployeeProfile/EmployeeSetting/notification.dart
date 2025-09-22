import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/setting.dart';
import 'package:marrir/Component/Employee/wave_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsPage extends StatefulWidget {
  final Function(Widget) onChildSelected;

  const NotificationSettingsPage({super.key, required this.onChildSelected});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final Map<String, bool> _defaultSettings = {
    "general_notification": true,
    "sound": true,
    "sound_call": true,
    "vibrate": true,
    "transaction_update": true,
    "expense_reminder": true,
    "budget_notifications": true,
    "low_balance_alerts": true,
  };

  late Map<String, bool> _notificationStates;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notificationStates = Map.from(_defaultSettings);
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        for (var key in _defaultSettings.keys) {
          _notificationStates[key] =
              prefs.getBool(key) ?? _defaultSettings[key]!;
        }
        _isLoading = false;
      });
    } catch (e) {
      // If loading fails, use default settings
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateNotificationSetting(String key, bool value) async {
    // Optimistic update for instant UI response
    setState(() => _notificationStates[key] = value);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      // Revert on error with a snackbar notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save setting: $e')),
      );
      setState(() => _notificationStates[key] = !value);
    }
  }

  Widget _buildNotificationOption(String title, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: _notificationStates[key] ?? true,
            onChanged: (bool value) => _updateNotificationSetting(key, value),
            activeColor: const Color(0xFF65B2C9),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(0),
              children: [
                WaveBackground(
                  title: "Notification Settings",
                  onBack: () {
                    widget.onChildSelected(
                      SettingPage(onChildSelected: widget.onChildSelected),
                    );
                  },
                  onNotification: () {},
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNotificationOption(
                          "General Notification", "general_notification"),
                      _buildNotificationOption("Sound", "sound"),
                      _buildNotificationOption("Sound Call", "sound_call"),
                      _buildNotificationOption("Vibrate", "vibrate"),
                      _buildNotificationOption(
                          "Transaction Updates", "transaction_update"),
                      _buildNotificationOption(
                          "Expense Reminders", "expense_reminder"),
                      _buildNotificationOption(
                          "Budget Notifications", "budget_notifications"),
                      _buildNotificationOption(
                          "Low Balance Alerts", "low_balance_alerts"),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
