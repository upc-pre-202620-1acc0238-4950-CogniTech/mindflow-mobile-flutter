import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/domain/auth_repository.dart';
import '../../auth/presentation/login_page.dart';
import 'profile_view_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileViewModel _viewModel;
  final _nameController = TextEditingController();
  final _occupationController = TextEditingController();
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProfileViewModel>();
    _viewModel.addListener(_hydrateOnce);
  }

  void _hydrateOnce() {
    if (_hydrated || _viewModel.profile == null) return;
    _hydrated = true;
    _nameController.text = _viewModel.profile!.name ?? '';
    _occupationController.text = _viewModel.profile!.occupation ?? '';
  }

  @override
  void dispose() {
    _viewModel.removeListener(_hydrateOnce);
    _nameController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
            'This cannot be undone. Consider exporting your data first.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete permanently', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await _viewModel.delete();
    if (ok && mounted) {
      await getIt<AuthRepository>().signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final profile = _viewModel.profile;
            if (profile == null) {
              return Center(
                  child: Text(_viewModel.errorMessage ?? 'Could not load profile.',
                      style: TextStyle(color: colors.crisisText)));
            }
            final initial = profile.displayName.isNotEmpty ? profile.displayName[0].toUpperCase() : '?';

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: colors.tintBlue,
                        child: Text(initial,
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: colors.primary)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text('Your avatar uses your initial.',
                            style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Full name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(controller: _nameController),
                  const SizedBox(height: 12),
                  const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    enabled: false,
                    controller: TextEditingController(text: profile.email),
                    decoration: InputDecoration(filled: true, fillColor: colors.border.withValues(alpha: 0.2)),
                  ),
                  const SizedBox(height: 12),
                  const Text('Occupation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(controller: _occupationController),
                  const SizedBox(height: 16),
                  if (_viewModel.errorMessage != null && !_viewModel.saved) ...[
                    Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)),
                    const SizedBox(height: 8),
                  ],
                  ElevatedButton(
                    onPressed: _viewModel.isSaving
                        ? null
                        : () => _viewModel.save(
                            name: _nameController.text.trim(),
                            occupation: _occupationController.text.trim()),
                    child: _viewModel.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save changes'),
                  ),
                  if (_viewModel.saved)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text('Changes saved',
                          style: TextStyle(color: colors.successText, fontWeight: FontWeight.w600)),
                    ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE6C3C1)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Danger zone',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600, color: colors.crisisText)),
                        const SizedBox(height: 6),
                        const Text(
                            'Deleting your account permanently removes your profile, journal entries and habits.'),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: _viewModel.isDeleting ? null : _confirmDelete,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.crisisText,
                            side: const BorderSide(color: Color(0xFFB3433F)),
                          ),
                          child: _viewModel.isDeleting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Delete my account'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
