import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/di/service_locator.dart';
import 'core/l10n/locale_controller.dart';
import 'core/navigation/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/pin_lock_page.dart';
import 'features/settings/infrastructure/pin_api.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MindFlow's primary language is Spanish, so every DateFormat call
  // without an explicit locale (most of the app) renders day/month names
  // in Spanish by default.
  await initializeDateFormatting('es');
  Intl.defaultLocale = 'es';
  setupDependencies();
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
/// [LoginPage] otherwise.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

enum _GateDestination { loggedOut, needsPin, loggedIn }

class _AuthGateState extends State<AuthGate> {
  late final Future<_GateDestination> _destination = _resolve();

  Future<_GateDestination> _resolve() async {
    final hasSession = await getIt<AuthRepository>().hasSession();
    if (!hasSession) return _GateDestination.loggedOut;
    final hasPin = await getIt<PinApi>().status();
    return hasPin ? _GateDestination.needsPin : _GateDestination.loggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_GateDestination>(
      future: _destination,
      builder: (context, snapshot) {
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
        }
      },
    );
  }
}
