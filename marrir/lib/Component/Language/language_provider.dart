import 'package:flutter/material.dart';
import 'package:marrir/Component/Language/lang.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLang = 'en';

  String get currentLang => _currentLang;

  void changeLanguage(String langCode) {
    _currentLang = langCode;
    notifyListeners();
  }

  String t(String key) {
    return AppStrings.translations[_currentLang]?[key] ?? key;
  }
}
