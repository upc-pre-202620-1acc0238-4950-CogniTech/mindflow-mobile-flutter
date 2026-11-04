import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../application/forgot_password_use_case.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final ForgotPasswordUseCase forgotPassword;

  ForgotPasswordViewModel({required this.forgotPassword});

  bool isLoading = false;
  bool sent = false;
  String? errorMessage;

  Future<void> submit({required String email}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await forgotPassword.execute(email: email);
      sent = true;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
