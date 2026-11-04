import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/login_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../subscriptions/presentation/plans_page.dart';
import '../../support/presentation/support_page.dart';
import '../../terms/presentation/terms_page.dart';
import 'pin_entry_dialog.dart';
import 'settings_view_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SettingsViewModel>();
  }

  Future<void> _togglePin(bool enable) async {
    if (enable) {
      final pin = await PinEntryDialog.show(context,
          title: 'Set a 4-digit PIN', subtitle: 'Ask for this code when you open the app.');
      if (pin == null || pin.length != 4) return;
      if (!mounted) return;
      final confirmPin = await PinEntryDialog.show(context, title: 'Confirm your PIN');
      if (confirmPin != pin) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('PINs did not match.')));
        }
        return;
      }
      final error = await _viewModel.setPin(pin);
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } else {
      final pin = await PinEntryDialog.show(context,
          title: 'Enter your PIN', subtitle: 'Confirm your PIN to turn off the lock.');
      if (pin == null || pin.length != 4) return;
      final error = await _viewModel.removePin(pin);
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Future<void> _logOut() async {
    await _viewModel.logOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = _viewModel.profile;
            final initial =
                (profile?.displayName.isNotEmpty ?? false) ? profile!.displayName[0].toUpperCase() : '?';

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              children: [
                const Text('Settings',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.01)),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()))
                      .then((_) => _viewModel.refreshAfterProfileEdit()),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: colors.tintBlue,
                        child: Text(initial,
                            style: TextStyle(fontWeight: FontWeight.w600, color: colors.primary)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile?.displayName ?? '',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                            Text('Edit profile', style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colors.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: colors.border.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
                  child: const Text('Your entries are private to you. Nobody at your company sees them.',
                      style: TextStyle(fontSize: 14)),
                ),
                _SectionLabel('Privacy'),
                _SettingsSwitchRow(
                  title: 'PIN lock',
                  subtitle: 'Ask for a 4-digit code when you open the app',
                  value: _viewModel.hasPin,
                  enabled: !_viewModel.isMutatingPin,
                  onChanged: _togglePin,
                ),
                _SettingsNavRow(
                  title: 'Export my data',
                  subtitle: 'PDF or CSV',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Open the Insights tab to export your data.')));
                  },
                ),
                _SectionLabel('Experience'),
                _SettingsSwitchRow(
                  title: 'Dark mode',
                  subtitle: 'Easier on the eyes at night',
                  value: _viewModel.isDarkMode,
                  onChanged: _viewModel.setDarkMode,
                ),
                _LanguageRow(viewModel: _viewModel),
                _SettingsSwitchRow(
                  title: 'Habit reminders',
                  subtitle: 'Saved as your preference on this device',
                  value: _viewModel.habitReminders,
                  onChanged: _viewModel.setHabitReminders,
                ),
                _SectionLabel('Plan'),
                _SettingsNavRow(
                  title: _viewModel.plan == 'premium' ? 'Premium plan' : 'Free plan',
                  subtitle: _viewModel.plan == 'premium' ? 'Thanks for supporting MindFlow' : 'See plans',
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const PlansPage()))
                      .then((_) => _viewModel.refreshAfterProfileEdit()),
                ),
                _SectionLabel('Help'),
                _SettingsNavRow(
                  title: 'Crisis support',
                  subtitle: 'Línea 113, option 5 · free, 24 h',
                  titleColor: colors.crisisText,
                  onTap: () => launchUrl(Uri.parse('tel:113')),
                ),
                _SettingsNavRow(
                  title: 'Support and FAQ',
                  subtitle: 'Send a ticket or read common questions',
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const SupportPage())),
                ),
                _SettingsNavRow(
                  title: 'Terms and privacy',
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TermsPage())),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: _logOut,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: colors.text,
                    side: const BorderSide(color: Color(0xFFB8C0CF)),
                  ),
                  child: const Text('Log out'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child:
          Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.border))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}

class _SettingsNavRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SettingsNavRow({required this.title, this.subtitle, this.titleColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.border))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500, color: titleColor ?? colors.text)),
                  if (subtitle != null)
                    Text(subtitle!, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final SettingsViewModel viewModel;
  const _LanguageRow({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final current = viewModel.localeController.locale?.languageCode ?? 'en';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.border))),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text('App language', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFB8C0CF)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: ['en', 'es'].map((code) {
                final selected = current == code;
                return InkWell(
                  onTap: () => viewModel.setLanguage(code),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF1B2333) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(code.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : const Color(0xFF1B2333))),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
