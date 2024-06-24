import 'dart:convert';

import 'package:flutter/material.dart';

class TranslationService {
  late Map<String, dynamic> _translations;

  Future<void> loadTranslations(BuildContext context) async {
    String jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/translations.json');
    _translations = json.decode(jsonString);
  }

  String translate(String language, String key) {
    return _translations[language]?[key] ?? '';
  }
}
