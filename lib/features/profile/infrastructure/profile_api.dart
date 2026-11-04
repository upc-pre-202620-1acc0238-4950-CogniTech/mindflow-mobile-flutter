import '../../../core/network/api_client.dart';
import '../domain/user_profile.dart';

class ProfileApi {
  final ApiClient client;
  ProfileApi({required this.client});

  Future<UserProfile> getProfile() async {
    final json = await client.get('/users/profile');
    return UserProfile.fromJson(json as Map<String, dynamic>);
  }

  Future<UserProfile> updateProfile({String? name, String? occupation}) async {
    final json = await client.put('/users/profile', body: {
      if (name != null) 'name': name,
      if (occupation != null) 'occupation': occupation,
    });
    return UserProfile.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteAccount() => client.delete('/users');
}
