import '../../../core/storage/token_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import 'auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;
  final TokenStorage tokenStorage;

  
  AuthRepositoryImpl({required this.api, required this.tokenStorage});

  AuthSession _sessionFromJson(Map<String, dynamic> json) => AuthSession(
        id: json['id'] as int,
        email: json['email'] as String,
        token: json['token'] as String,
      );

  @override
  Future<void> signUp({required String email, required String password, String? name}) {
    return api.signUp(email: email, password: password, name: name);
  }

  @override
  Future<AuthSession> signIn({required String email, required String password}) async {
    final json = await api.signIn(email: email, password: password);
    final session = _sessionFromJson(json);
    await tokenStorage.save(session.token);
    return session;
  }

  
  @override
  Future<AuthSession> googleAuth({required String credential}) async {
    final json = await api.googleAuth(credential: credential);
    final session = _sessionFromJson(json);
    await tokenStorage.save(session.token);
    return session;
  }
  
  @override
  Future<void> forgotPassword({required String email}) {
    return api.forgotPassword(email: email);
  }

  @override
  Future<void> resetPassword({required String token, required String newPassword}) {
    return api.resetPassword(token: token, newPassword: newPassword);
  }

  @override
  Future<bool> hasSession() async {
    final token = await tokenStorage.read();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> signOut() => tokenStorage.clear();
  
}
