/// The signed-in user and the JWT the backend issued for this session.
class AuthSession {
  final int id;
  final String email;
  final String token;

  const AuthSession({required this.id, required this.email, required this.token});
}
