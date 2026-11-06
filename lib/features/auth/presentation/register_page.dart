import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../terms/presentation/terms_page.dart';
import 'login_view_model.dart';
import 'register_view_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final RegisterViewModel _viewModel;
  late final LoginViewModel _loginViewModel;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<RegisterViewModel>();
    _loginViewModel = getIt<LoginViewModel>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final ok = await _viewModel.submit(
      name: _nameController.text.trim(),
      email: email,
      password: password,
    );
    if (!mounted) return;
    if (ok) {
      // Sign-up issues no token; sign the user in right after, same flow
      // the Android app follows.
      final session = await _loginViewModel.submit(email: email, password: password);
      if (!mounted) return;
      if (session != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppShell()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.registerTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600, letterSpacing: -0.015)),
                  const SizedBox(height: 6),
                  Text(l10n.registerSubtitle,
                      style: TextStyle(fontSize: 16, height: 1.5, color: colors.textSecondary)),
                  const SizedBox(height: 20),
                  Text(l10n.fullNameLabel,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: l10n.fullNameHint),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.emailLabel,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: l10n.emailHint),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.createPasswordLabel,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: l10n.createPasswordHint,
                      suffixIcon: TextButton(
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        child: Text(
                          _obscurePassword ? l10n.showPassword : l10n.hidePassword,
                          style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _viewModel.toggleAgreed,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: _viewModel.agreedToTerms
                                      ? colors.primary
                                      : colors.inputBorder,
                                  width: 2),
                              color: _viewModel.agreedToTerms ? colors.primary : colors.surface,
                            ),
                            child: _viewModel.agreedToTerms
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 14, height: 1.4, color: colors.text),
                                children: [
                                  TextSpan(text: l10n.acceptTermsPrefix),
                                  TextSpan(
                                    text: l10n.termsOfService,
                                    style: TextStyle(
                                        color: colors.primary, fontWeight: FontWeight.w600),
                                    recognizer: _openTerms(context),
                                  ),
                                  TextSpan(text: l10n.acceptTermsAnd),
                                  TextSpan(
                                    text: l10n.privacyPolicy,
                                    style: TextStyle(
                                        color: colors.primary, fontWeight: FontWeight.w600),
                                    recognizer: _openTerms(context),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_viewModel.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)),
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: (_viewModel.isLoading || !_viewModel.agreedToTerms)
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _viewModel.agreedToTerms ? colors.primary : colors.inputBorder,
                    ),
                    child: _viewModel.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.createMyAccount),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(l10n.alreadyHaveAccount,
                            style: TextStyle(color: colors.textSecondary)),
                        const SizedBox(width: 6),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(l10n.signIn,
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

  GestureRecognizer _openTerms(BuildContext context) {
    return TapGestureRecognizer()
      ..onTap = () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const TermsPage()));
  }
}
