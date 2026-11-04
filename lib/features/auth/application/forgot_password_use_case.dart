import '../domain/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;
  ForgotPasswordUseCase({required this.repository});

  Future<void> execute({required String email}) {
    return repository.forgotPassword(email: email);
  }
}
