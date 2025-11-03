import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('es');
  
  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isSpanish => _locale.languageCode == 'es';
  bool get isEnglish => _locale.languageCode == 'en';

  LanguageProvider() {
    _loadLanguage();
  }

  void _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString('languageCode') ?? 'es';
      _locale = Locale(langCode);
      notifyListeners();
    } catch (e) {
      // If shared_preferences fails, use default language
      _locale = const Locale('es');
      notifyListeners();
    }
  }

  void setLanguage(Locale locale) async {
    _locale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', locale.languageCode);
    } catch (e) {
      // If shared_preferences fails, continue with language change
      // The language will reset on app restart, but at least the app won't crash
    }
  }

  void toggleLanguage() {
    setLanguage(_locale.languageCode == 'en' ? const Locale('es') : const Locale('en'));
  }
}

