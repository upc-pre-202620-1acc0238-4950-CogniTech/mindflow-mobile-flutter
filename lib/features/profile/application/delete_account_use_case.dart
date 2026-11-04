import '../infrastructure/profile_api.dart';

class DeleteAccountUseCase {
  final ProfileApi api;
  DeleteAccountUseCase({required this.api});

  Future<void> execute() => api.deleteAccount();
}
