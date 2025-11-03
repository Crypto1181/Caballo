import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/translation_service.dart';

extension TranslationExtension on BuildContext {
  String t(String key) {
    final languageProvider = Provider.of<LanguageProvider>(this, listen: false);
    return TranslationService.translate(key, languageProvider.languageCode);
  }
  
  LanguageProvider get language => Provider.of<LanguageProvider>(this, listen: false);
}

