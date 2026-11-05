import 'package:flutter/material.dart';

import '../storage/local_prefs.dart';

class LocaleController extends ChangeNotifier {
  static const _key = 'app_locale';
  final LocalPrefs _prefs;

  LocaleController({required LocalPrefs prefs}) : _prefs = prefs {
    _load();
  }

  /// MindFlow's main language is Spanish, so it's the default regardless of
  /// device locale until the user picks English in Settings.
  Locale? locale = const Locale('es');

  Future<void> _load() async {
    final code = await _prefs.getString(_key);
    if (code != null) {
      locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(String languageCode) async {
    locale = Locale(languageCode);
    notifyListeners();
    await _prefs.setString(_key, languageCode);
  }
}
