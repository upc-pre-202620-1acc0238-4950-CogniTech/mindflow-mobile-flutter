import '../domain/user_profile.dart';
import '../infrastructure/profile_api.dart';

class UpdateProfileUseCase {
  final ProfileApi api;
  UpdateProfileUseCase({required this.api});

  Future<UserProfile> execute({String? name, String? occupation}) =>
      api.updateProfile(name: name, occupation: occupation);
}
