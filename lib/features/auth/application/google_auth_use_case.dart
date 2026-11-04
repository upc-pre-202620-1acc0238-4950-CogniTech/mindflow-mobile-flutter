import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';

class GoogleAuthUseCase {
  final AuthRepository repository;
  GoogleAuthUseCase({required this.repository});

  Future<AuthSession> execute({required String credential}) {
    return repository.googleAuth(credential: credential);
  }
}
