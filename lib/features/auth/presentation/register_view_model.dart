import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../application/sign_up_use_case.dart';

class RegisterViewModel extends ChangeNotifier {
  final SignUpUseCase signUp;

  RegisterViewModel({required this.signUp});

  bool isLoading = false;
  bool agreedToTerms = false;
  String? errorMessage;

  void toggleAgreed() {
    agreedToTerms = !agreedToTerms;
    notifyListeners();
  }

  /// Returns true on success; the page is responsible for signing the
  /// user in next, since `/sign-up` does not issue a token.
  Future<bool> submit({required String name, required String email, required String password}) async {
    if (!agreedToTerms) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await signUp.execute(email: email, password: password, name: name);
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (_) {
      errorMessage = 'No se pudo conectar. Revisa tu conexión e intenta de nuevo.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
