import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/setting.dart';
import 'package:marrir/Component/Employee/wave_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateNotificationSetting(
      String key, bool value, LanguageProvider languageProvider) async {
    setState(() => _notificationStates[key] = value);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTranslatedSaveFailed(languageProvider))),
      );
      setState(() => _notificationStates[key] = !value);
    }
  }

  Widget _buildNotificationOption(
      String title, String key, LanguageProvider languageProvider) {
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
            onChanged: (bool value) =>
                _updateNotificationSetting(key, value, languageProvider),
            activeColor: const Color(0xFF65B2C9),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(0),
              children: [
                WaveBackground(
                  title: _getTranslatedTitle(languageProvider),
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
                          _getTranslatedGeneralNotification(languageProvider),
                          "general_notification",
                          languageProvider),
                      _buildNotificationOption(
                          _getTranslatedSound(languageProvider),
                          "sound",
                          languageProvider),
                      _buildNotificationOption(
                          _getTranslatedSoundCall(languageProvider),
                          "sound_call",
                          languageProvider),
                      _buildNotificationOption(
                          _getTranslatedVibrate(languageProvider),
                          "vibrate",
                          languageProvider),
                      _buildNotificationOption(
                          _getTranslatedTransactionUpdates(languageProvider),
                          "transaction_update",
                          languageProvider),
                      _buildNotificationOption(
                          _getTranslatedExpenseReminders(languageProvider),
                          "expense_reminder",
                          languageProvider),
                      _buildNotificationOption(
                          _getTranslatedBudgetNotifications(languageProvider),
                          "budget_notifications",
                          languageProvider),
                      _buildNotificationOption(
                          _getTranslatedLowBalanceAlerts(languageProvider),
                          "low_balance_alerts",
                          languageProvider),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Translation helper methods
  String _getTranslatedTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إعدادات الإشعارات";
    if (lang == 'am') return "የማሳወቂያ ቅንብሮች";
    return "Notification Settings";
  }

  String _getTranslatedGeneralNotification(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الإشعارات العامة";
    if (lang == 'am') return "አጠቃላይ ማሳወቂያ";
    return "General Notification";
  }

  String _getTranslatedSound(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الصوت";
    if (lang == 'am') return "ድምፅ";
    return "Sound";
  }

  String _getTranslatedSoundCall(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "صوت المكالمة";
    if (lang == 'am') return "የደወል ድምፅ";
    return "Sound Call";
  }

  String _getTranslatedVibrate(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الاهتزاز";
    if (lang == 'am') return "እንቅጥቅጥ";
    return "Vibrate";
  }

  String _getTranslatedTransactionUpdates(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تحديثات المعاملات";
    if (lang == 'am') return "የግብይት ዝመናዎች";
    return "Transaction Updates";
  }

  String _getTranslatedExpenseReminders(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تذكير بالمصروفات";
    if (lang == 'am') return "የወጪ አስታዋሽ";
    return "Expense Reminders";
  }

  String _getTranslatedBudgetNotifications(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إشعارات الميزانية";
    if (lang == 'am') return "የበጀት ማሳወቂያዎች";
    return "Budget Notifications";
  }

  String _getTranslatedLowBalanceAlerts(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تنبيهات الرصيد المنخفض";
    if (lang == 'am') return "የዝቅተኛ ሚዛን ማንቂያዎች";
    return "Low Balance Alerts";
  }

  String _getTranslatedSaveFailed(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "فشل حفظ الإعداد";
    if (lang == 'am') return "ቅንብሩን ማስቀመጥ አልተሳካም";
    return "Failed to save setting";
  }
}
