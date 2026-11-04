import 'package:flutter/services.dart';

/// Talks to MainActivity.kt to set FLAG_SECURE on Android — blanks the
/// app in the recent-apps switcher and blocks screenshots/recording.
/// No-op on platforms other than Android (iOS has no equivalent flag;
/// the toggle still saves the user's preference).
class PrivacyChannel {
  static const _channel = MethodChannel('pe.edu.upc.mindflow_workday/privacy');

  Future<void> setHideInSwitcher(bool enabled) async {
    try {
      await _channel.invokeMethod('setHideInSwitcher', {'enabled': enabled});
    } on MissingPluginException {
      // Not Android — nothing to do natively.
    }
  }
}
