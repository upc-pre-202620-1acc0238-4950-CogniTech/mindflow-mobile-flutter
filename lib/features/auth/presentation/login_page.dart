import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/google_glyph_icon.dart';
import '../../../l10n/app_localizations.dart';
import 'forgot_password_page.dart';
import 'login_view_model.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<LoginViewModel>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final session = await _viewModel.submit(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (session != null && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('M',
                        style: TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.loginTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600, letterSpacing: -0.015)),
                  const SizedBox(height: 6),
                  Text(l10n.loginSubtitle,
                      style: TextStyle(fontSize: 16, height: 1.5, color: colors.textSecondary)),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _viewModel.isLoading ? null : () {},
                    icon: GoogleGlyphIcon(color: colors.text),
                    label: Text(l10n.continueWithGoogle),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: colors.text,
                      side: const BorderSide(color: Color(0xFFB8C0CF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: Divider(color: colors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(l10n.orUseEmail,
                            style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                      ),
                      Expanded(child: Divider(color: colors.border)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.emailLabel,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: l10n.emailHint),
                  ),
                  const SizedBox(height: 14),
                  Text(l10n.passwordLabel,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _viewModel.obscurePassword,
                    decoration: InputDecoration(
                      hintText: l10n.passwordHint,
                      suffixIcon: TextButton(
                        onPressed: _viewModel.toggleObscurePassword,
                        child: Text(
                          _viewModel.obscurePassword ? l10n.showPassword : l10n.hidePassword,
                          style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                      ),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(l10n.forgotPasswordLink,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: colors.primary)),
                    ),
                  ),
                  if (_viewModel.errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)),
                  ],
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _viewModel.isLoading ? null : _submit,
                    child: _viewModel.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.signIn),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(l10n.newToMindflow, style: TextStyle(color: colors.textSecondary)),
                        const SizedBox(width: 6),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                          ),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(l10n.createAccount,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, color: colors.primary)),
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
