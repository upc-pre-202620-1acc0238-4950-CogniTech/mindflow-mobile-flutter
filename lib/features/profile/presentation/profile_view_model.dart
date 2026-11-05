import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../application/delete_account_use_case.dart';
import '../application/get_profile_use_case.dart';
import '../application/update_profile_use_case.dart';
import '../domain/user_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetProfileUseCase getProfile;
  final UpdateProfileUseCase updateProfile;
  final DeleteAccountUseCase deleteAccount;

  ProfileViewModel({
    required this.getProfile,
    required this.updateProfile,
    required this.deleteAccount,
  }) {
    _load();
  }

  bool isLoading = true;
  bool isSaving = false;
  bool saved = false;
  bool isDeleting = false;
  String? errorMessage;
  UserProfile? profile;

  Future<void> _load() async {
    try {
      profile = await getProfile.execute();
    } catch (_) {
      errorMessage = 'No se pudo cargar tu perfil.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> save({required String name, required String occupation}) async {
    isSaving = true;
    saved = false;
    errorMessage = null;
    notifyListeners();
    try {
      profile = await updateProfile.execute(name: name, occupation: occupation);
      saved = true;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> delete() async {
    isDeleting = true;
    notifyListeners();
    try {
      await deleteAccount.execute();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }
}
