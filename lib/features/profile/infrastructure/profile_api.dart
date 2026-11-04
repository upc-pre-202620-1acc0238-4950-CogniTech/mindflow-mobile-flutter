import '../../../core/network/api_client.dart';
import '../domain/user_profile.dart';

class ProfileApi {
  final ApiClient client;
  ProfileApi({required this.client});

  Future<UserProfile> getProfile() async {
    final json = await client.get('/users/profile');
    return UserProfile.fromJson(json as Map<String, dynamic>);
  }
}
