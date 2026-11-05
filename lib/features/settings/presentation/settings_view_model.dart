import 'package:flutter/material.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/platform/privacy_channel.dart';
import '../../../core/storage/local_prefs.dart';
import '../../../core/theme/theme_controller.dart';
import '../../auth/domain/auth_repository.dart';
import '../../profile/application/get_profile_use_case.dart';
import '../../profile/domain/user_profile.dart';
import '../../subscriptions/application/get_my_subscription_use_case.dart';
import '../../subscriptions/domain/subscription_plan.dart';
import '../infrastructure/pin_api.dart';

class SettingsViewModel extends ChangeNotifier {
  static const _hideInSwitcherKey = 'hide_in_switcher';
  static const _remindersKey = 'habit_reminders';

  final GetProfileUseCase getProfile;
  final PinApi pinApi;
  final GetMySubscriptionUseCase getMySubscription;
  final AuthRepository authRepository;
  final ThemeController themeController;
  final LocaleController localeController;
  final LocalPrefs prefs;
  final PrivacyChannel privacyChannel;

  SettingsViewModel({
    required this.getProfile,
    required this.pinApi,
    required this.getMySubscription,
    required this.authRepository,
    required this.themeController,
    required this.localeController,
    required this.prefs,
    required this.privacyChannel,
  }) {
    _load();
  }

  bool isLoading = true;
  String? errorMessage;
  UserProfile? profile;
  String plan = 'freemium';

  bool hasPin = false;
  bool isMutatingPin = false;
  bool hideInSwitcher = false;
  bool habitReminders = false;

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        getProfile.execute(),
        pinApi.status(),
        getMySubscription.execute(),
        prefs.getBool(_hideInSwitcherKey),
        prefs.getBool(_remindersKey),
      ]);
      profile = results[0] as UserProfile;
      hasPin = results[1] as bool;
      plan = (results[2] as CurrentSubscription).plan;
      hideInSwitcher = (results[3] as bool?) ?? false;
      habitReminders = (results[4] as bool?) ?? true;
    } catch (_) {
      errorMessage = 'No se pudieron cargar algunos ajustes.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> setPin(String pin) async {
    isMutatingPin = true;
    notifyListeners();
    try {
      await pinApi.set(pin);
      hasPin = true;
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      isMutatingPin = false;
      notifyListeners();
    }
  }

  /// Verifies [pin] and removes it if correct. Returns an error message,
  /// or null on success.
  Future<String?> removePin(String pin) async {
    isMutatingPin = true;
    notifyListeners();
    try {
      final valid = await pinApi.verify(pin);
      if (!valid) return 'PIN incorrecto.';
      await pinApi.remove();
      hasPin = false;
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      isMutatingPin = false;
      notifyListeners();
    }
  }

  Future<void> setHideInSwitcher(bool enabled) async {
    hideInSwitcher = enabled;
    notifyListeners();
    await prefs.setBool(_hideInSwitcherKey, enabled);
    await privacyChannel.setHideInSwitcher(enabled);
  }

  Future<void> setHabitReminders(bool enabled) async {
    habitReminders = enabled;
    notifyListeners();
    await prefs.setBool(_remindersKey, enabled);
  }

  Future<void> setDarkMode(bool enabled) => themeController.setDark(enabled);
  bool get isDarkMode => themeController.isDark;

  Future<void> setLanguage(String code) => localeController.setLocale(code);

  Future<void> logOut() => authRepository.signOut();

  /// Re-fetches the profile and plan after returning from Profile or Plans.
  Future<void> refreshAfterProfileEdit() async {
    try {
      final results = await Future.wait([getProfile.execute(), getMySubscription.execute()]);
      profile = results[0] as UserProfile;
      plan = (results[1] as CurrentSubscription).plan;
      notifyListeners();
    } catch (_) {
      // Keep the previously loaded values if this fails.
    }
  }
}
