import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';

class SignInUseCase {
  final AuthRepository repository;
  SignInUseCase({required this.repository});

  Future<AuthSession> execute({required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}
