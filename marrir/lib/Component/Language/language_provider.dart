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
    // Debug: Print all available keys in current language
    final currentLangTranslations = AppStrings.translations[_currentLang];
    print(
        'Available keys in $_currentLang: ${currentLangTranslations?.keys.toList()}');

    // Try current language first
    if (currentLangTranslations != null &&
        currentLangTranslations.containsKey(key)) {
      return currentLangTranslations[key]!;
    }

    // Fallback to English if not found in current language
    final englishTranslations = AppStrings.translations['en'];
    if (englishTranslations != null && englishTranslations.containsKey(key)) {
      return englishTranslations[key]!;
    }

    // Final fallback - return the key or a placeholder
    return '[Missing: $key]';
  }
}
