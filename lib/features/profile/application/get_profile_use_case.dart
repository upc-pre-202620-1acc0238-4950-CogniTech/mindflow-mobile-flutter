import '../domain/user_profile.dart';
import '../infrastructure/profile_api.dart';

class GetProfileUseCase {
  final ProfileApi api;
  GetProfileUseCase({required this.api});

  Future<UserProfile> execute() => api.getProfile();
}
