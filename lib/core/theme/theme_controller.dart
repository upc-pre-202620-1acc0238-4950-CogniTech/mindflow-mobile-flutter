import 'package:flutter/material.dart';

import '../storage/local_prefs.dart';

class ThemeController extends ChangeNotifier {
  static const _key = 'dark_mode_enabled';
  final LocalPrefs _prefs;

  ThemeController({required LocalPrefs prefs}) : _prefs = prefs {
    _load();
  }

  ThemeMode mode = ThemeMode.system;

  Future<void> _load() async {
    final enabled = await _prefs.getBool(_key);
    if (enabled != null) {
      mode = enabled ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  /// Whether the app is *currently rendering* dark, including when [mode]
  /// is [ThemeMode.system] — so the Settings toggle matches what's on
  /// screen instead of only reflecting an explicit user override.
  bool get isDark {
    if (mode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return mode == ThemeMode.dark;
  }

  Future<void> setDark(bool enabled) async {
    mode = enabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _prefs.setBool(_key, enabled);
  }
}
