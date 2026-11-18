import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mindflow_workday/core/network/api_client.dart';
import 'package:mindflow_workday/core/network/api_exception.dart';
import 'package:mindflow_workday/core/storage/token_storage.dart';
import 'package:mindflow_workday/features/auth/application/google_auth_use_case.dart';
import 'package:mindflow_workday/features/auth/application/sign_in_use_case.dart';
import 'package:mindflow_workday/features/auth/domain/auth_repository.dart';
import 'package:mindflow_workday/features/auth/presentation/login_page.dart';
import 'package:mindflow_workday/features/auth/presentation/login_view_model.dart';
import 'package:mindflow_workday/l10n/app_localizations.dart';
import 'package:mindflow_workday/features/auth/domain/auth_session.dart';
import 'package:mindflow_workday/features/settings/infrastructure/pin_api.dart';
import 'package:mindflow_workday/core/theme/app_theme.dart';
import 'package:mindflow_workday/main.dart';

class FakeAuthRepository implements AuthRepository {
  bool session = true;
  int signOuts = 0;

  @override
  Future<bool> hasSession() async => session;

  @override
  Future<void> signOut() async {
    signOuts++;
    session = false;
  }

  @override
  Future<AuthSession> signIn({required String email, required String password}) => throw UnimplementedError();
  @override
  Future<AuthSession> googleAuth({required String credential}) => throw UnimplementedError();
  @override
  Future<void> signUp({required String email, required String password, String? name}) => throw UnimplementedError();
  @override
  Future<void> forgotPassword({required String email}) => throw UnimplementedError();
  @override
  Future<void> resetPassword({required String token, required String newPassword}) => throw UnimplementedError();
}

class FakePinApi extends PinApi {
  final Future<bool> Function() onStatus;
  FakePinApi(this.onStatus) : super(client: _unusedClient());

  @override
  Future<bool> status() => onStatus();
}

ApiClient _unusedClient() => ApiClient(tokenStorage: TokenStorage());

void main() {
  final getIt = GetIt.instance;

  setUp(() async => getIt.reset());

  testWidgets('shows a retry screen (not an endless spinner) when the server is unreachable', (tester) async {
    final auth = FakeAuthRepository();
    getIt.registerSingleton<AuthRepository>(auth);
    getIt.registerSingleton<PinApi>(FakePinApi(() async => throw const ApiException(0, 'sin red')));

    await tester.pumpWidget(const MaterialApp(home: AuthGate()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
    expect(auth.signOuts, 0);
  });

  testWidgets('retry runs the check again and recovers', (tester) async {
    getIt.registerSingleton<AuthRepository>(FakeAuthRepository());
    var calls = 0;
    getIt.registerSingleton<PinApi>(FakePinApi(() async {
      calls++;
      if (calls == 1) throw const ApiException(503, 'caído');
      throw const ApiException(0, 'sigue sin red');
    }));

    await tester.pumpWidget(const MaterialApp(home: AuthGate()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('an expired token (401) signs the user out and lands on the login screen', (tester) async {
    final auth = FakeAuthRepository();
    getIt.registerSingleton<AuthRepository>(auth);
    getIt.registerSingleton<PinApi>(FakePinApi(() async => throw const ApiException(401, 'expirado')));
    getIt.registerFactory<LoginViewModel>(() => LoginViewModel(
          signIn: SignInUseCase(repository: auth),
          googleAuth: GoogleAuthUseCase(repository: auth),
        ));

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AuthGate(),
    ));
    await tester.pumpAndSettle();

    expect(auth.signOuts, 1);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
  });
}
