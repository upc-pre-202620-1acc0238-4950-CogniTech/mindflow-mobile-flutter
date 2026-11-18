import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/di/service_locator.dart';
import 'core/l10n/locale_controller.dart';
import 'core/navigation/app_shell.dart';
import 'core/network/api_client.dart';
import 'core/network/api_exception.dart';
import 'core/platform/privacy_channel.dart';
import 'core/storage/local_prefs.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/pin_lock_page.dart';
import 'features/settings/infrastructure/pin_api.dart';
import 'features/settings/presentation/settings_view_model.dart';
import 'l10n/app_localizations.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MindFlow's primary language is Spanish, so every DateFormat call
  // without an explicit locale (most of the app) renders day/month names
  // in Spanish by default.
  await initializeDateFormatting('es');
  Intl.defaultLocale = 'es';
  setupDependencies();

  // A 401 anywhere (expired token) sends the user back to the login screen.
  getIt<ApiClient>().onUnauthorized = () {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  };

  // FLAG_SECURE only lives in the running Activity: re-apply the saved
  // "hide in app switcher" preference on every cold start.
  try {
    final hide = await getIt<LocalPrefs>().getBool(SettingsViewModel.hideInSwitcherKey);
    if (hide == true) await getIt<PrivacyChannel>().setHideInSwitcher(true);
  } catch (_) {
    // Secure storage unavailable: the app still works without the flag.
  }

  runApp(const MindFlowApp());
}

class MindFlowApp extends StatelessWidget {
  const MindFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = getIt<ThemeController>();
    final localeController = getIt<LocaleController>();

    return ListenableBuilder(
      listenable: Listenable.merge([themeController, localeController]),
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'MindFlow',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeController.mode,
          locale: localeController.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AuthGate(),
        );
      },
    );
  }
}

/// Routes to [AppShell] if a session token is already stored, or
/// [LoginPage] otherwise. If the server cannot be reached it shows a retry
/// screen instead of spinning forever.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

enum _GateDestination { loggedOut, needsPin, loggedIn, unreachable }

class _AuthGateState extends State<AuthGate> {
  late Future<_GateDestination> _destination = _resolve();

  Future<_GateDestination> _resolve() async {
    final auth = getIt<AuthRepository>();
    final hasSession = await auth.hasSession();
    if (!hasSession) return _GateDestination.loggedOut;
    try {
      final hasPin = await getIt<PinApi>().status();
      return hasPin ? _GateDestination.needsPin : _GateDestination.loggedIn;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        // Expired or revoked token: start over from the login screen.
        await auth.signOut();
        return _GateDestination.loggedOut;
      }
      return _GateDestination.unreachable;
    } catch (_) {
      return _GateDestination.unreachable;
    }
  }

  void _retry() {
    setState(() {
      _destination = _resolve();
    });
  }

  Future<void> _signOut() async {
    await getIt<AuthRepository>().signOut();
    _retry();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_GateDestination>(
      future: _destination,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _Unreachable(onRetry: _retry, onSignOut: _signOut);
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        switch (snapshot.data!) {
          case _GateDestination.loggedOut:
            return const LoginPage();
          case _GateDestination.needsPin:
            return const PinLockPage();
          case _GateDestination.loggedIn:
            return const AppShell();
          case _GateDestination.unreachable:
            return _Unreachable(onRetry: _retry, onSignOut: _signOut);
        }
      },
    );
  }
}

class _Unreachable extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onSignOut;
  const _Unreachable({required this.onRetry, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 16),
              const Text('No pudimos conectar con el servidor.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Revisa tu conexión e intenta de nuevo.', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
              TextButton(onPressed: onSignOut, child: const Text('Cerrar sesión')),
            ],
          ),
        ),
      ),
    );
  }
}
