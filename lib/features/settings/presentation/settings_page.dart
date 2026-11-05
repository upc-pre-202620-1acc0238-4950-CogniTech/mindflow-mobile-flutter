import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../ai_feedback/presentation/ai_feedback_history_page.dart';
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
          title: 'Crea un PIN de 4 dígitos', subtitle: 'Se pedirá este código al abrir la app.');
      if (pin == null || pin.length != 4) return;
      if (!mounted) return;
      final confirmPin = await PinEntryDialog.show(context, title: 'Confirma tu PIN');
      if (confirmPin != pin) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Los PIN no coinciden.')));
        }
        return;
      }
      final error = await _viewModel.setPin(pin);
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } else {
      final pin = await PinEntryDialog.show(context,
          title: 'Ingresa tu PIN', subtitle: 'Confirma tu PIN para desactivar el bloqueo.');
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
                const Text('Ajustes',
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
                            Text('Editar perfil', style: TextStyle(fontSize: 14, color: colors.textSecondary)),
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
                  child: const Text('Tus entradas son privadas. Nadie en tu empresa puede verlas.',
                      style: TextStyle(fontSize: 14)),
                ),
                _SectionLabel('Privacidad'),
                _SettingsSwitchRow(
                  title: 'Bloqueo con PIN',
                  subtitle: 'Pide un código de 4 dígitos al abrir la app',
                  value: _viewModel.hasPin,
                  enabled: !_viewModel.isMutatingPin,
                  onChanged: _togglePin,
                ),
                _SettingsNavRow(
                  title: 'Exportar mis datos',
                  subtitle: 'PDF o CSV',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Abre la pestaña de Análisis para exportar tus datos.')));
                  },
                ),
                _SectionLabel('Experiencia'),
                _SettingsSwitchRow(
                  title: 'Modo oscuro',
                  subtitle: 'Más cómodo para los ojos de noche',
                  value: _viewModel.isDarkMode,
                  onChanged: _viewModel.setDarkMode,
                ),
                _LanguageRow(viewModel: _viewModel),
                _SettingsSwitchRow(
                  title: 'Recordatorios de hábitos',
                  subtitle: 'Se guarda como tu preferencia en este dispositivo',
                  value: _viewModel.habitReminders,
                  onChanged: _viewModel.setHabitReminders,
                ),
                _SectionLabel('Plan'),
                _SettingsNavRow(
                  title: _viewModel.plan == 'premium' ? 'Plan Premium' : 'Plan gratuito',
                  subtitle: _viewModel.plan == 'premium' ? 'Gracias por apoyar a MindFlow' : 'Ver planes',
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const PlansPage()))
                      .then((_) => _viewModel.refreshAfterProfileEdit()),
                ),
                _SectionLabel('Ayuda'),
                _SettingsNavRow(
                  title: 'Apoyo en crisis',
                  subtitle: 'Línea 113, opción 5 · gratis, 24 h',
                  titleColor: colors.crisisText,
                  onTap: () => launchUrl(Uri.parse('tel:113')),
                ),
                _SettingsNavRow(
                  title: 'Soporte y preguntas frecuentes',
                  subtitle: 'Envía un ticket o lee preguntas comunes',
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const SupportPage())),
                ),
                _SettingsNavRow(
                  title: 'Comentarios sobre la IA',
                  subtitle: 'Tus calificaciones de las respuestas y decisiones de MindFlow AI',
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const AiFeedbackHistoryPage())),
                ),
                _SettingsNavRow(
                  title: 'Términos y privacidad',
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
                  child: const Text('Cerrar sesión'),
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
    final current = viewModel.localeController.locale?.languageCode ?? 'es';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.border))),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Idioma', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text('Solo afecta las pantallas de inicio de sesión',
                    style: TextStyle(fontSize: 13)),
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
                  onTap: selected
                      ? null
                      : () {
                          viewModel.setLanguage(code);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(code == 'es'
                                  ? 'Idioma cambiado a Español (se aplica al instante en las pantallas de inicio de sesión).'
                                  : 'Language switched to English (applies instantly on the sign-in screens).'),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        },
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
