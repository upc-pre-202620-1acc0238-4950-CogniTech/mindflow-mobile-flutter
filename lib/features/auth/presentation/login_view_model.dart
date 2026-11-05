import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../application/google_auth_use_case.dart';
import '../application/sign_in_use_case.dart';
import '../domain/auth_session.dart';

class LoginViewModel extends ChangeNotifier {
  final SignInUseCase signIn;
  final GoogleAuthUseCase googleAuth;

  LoginViewModel({required this.signIn, required this.googleAuth});

  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<AuthSession?> submit({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final session = await signIn.execute(email: email, password: password);
      return session;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return null;
    } catch (_) {
      errorMessage = 'No se pudo conectar. Revisa tu conexión e intenta de nuevo.';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthSession?> submitGoogle(String credential) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      return await googleAuth.execute(credential: credential);
    } on ApiException catch (e) {
      errorMessage = e.message;
      return null;
    } catch (_) {
      errorMessage = 'No se pudo conectar. Revisa tu conexión e intenta de nuevo.';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
