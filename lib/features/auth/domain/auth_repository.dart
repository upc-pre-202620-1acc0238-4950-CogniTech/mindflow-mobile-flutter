import 'auth_session.dart';

abstract class AuthRepository {
  /// POST /users/sign-up. Returns nothing usable to sign in with: the
  /// backend issues no token on sign-up, so callers must sign in next.
  Future<void> signUp({required String email, required String password, String? name});

  Future<AuthSession> signIn({required String email, required String password});

  Future<AuthSession> googleAuth({required String credential});

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({required String token, required String newPassword});

  /// Whether a session token is already stored on this device.
  Future<bool> hasSession();

  Future<void> signOut();
}
