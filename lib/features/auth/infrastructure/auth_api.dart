import '../../../core/network/api_client.dart';

/// Talks to `IAM/UsersController`. Request/response field names follow the
/// backend's global `snake_case` JSON policy.
class AuthApi {
  final ApiClient client;
  AuthApi({required this.client});

  Future<void> signUp({required String email, required String password, String? name}) {
    return client.post(
      '/users/sign-up',
      auth: false,
      body: {'email': email, 'password': password, if (name != null) 'name': name},
    );
  }

  Future<Map<String, dynamic>> signIn({required String email, required String password}) async {
    final json = await client.post(
      '/users/sign-in',
      auth: false,
      body: {'email': email, 'password': password},
    );
    return json as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> googleAuth({required String credential}) async {
    final json = await client.post(
      '/users/google-auth',
      auth: false,
      body: {'credential': credential},
    );
    return json as Map<String, dynamic>;
  }

  Future<void> forgotPassword({required String email}) {
    return client.post('/users/forgot-password', auth: false, body: {'email': email});
  }

  Future<void> resetPassword({required String token, required String newPassword}) {
    return client.post(
      '/users/reset-password',
      auth: false,
      body: {'token': token, 'new_password': newPassword},
    );
  }
}
