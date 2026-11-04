import '../domain/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase({required this.repository});

  Future<void> execute({required String email, required String password, String? name}) {
    return repository.signUp(email: email, password: password, name: name);
  }
}
