import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'forgot_password_view_model.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  late final ForgotPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ForgotPasswordViewModel>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.forgotTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600, letterSpacing: -0.015)),
                  const SizedBox(height: 6),
                  Text(l10n.forgotSubtitle,
                      style: TextStyle(fontSize: 16, height: 1.5, color: colors.textSecondary)),
                  const SizedBox(height: 24),
                  Text(l10n.emailLabel,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: l10n.emailHint),
                  ),
                  const SizedBox(height: 16),
                  if (_viewModel.errorMessage != null) ...[
                    Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    onPressed: _viewModel.isLoading
                        ? null
                        : () => _viewModel.submit(email: _emailController.text.trim()),
                    child: _viewModel.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.sendResetLink),
                  ),
                  if (_viewModel.sent) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.tintGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 15, height: 1.45, color: colors.text),
                          children: [
                            TextSpan(
                                text: '${l10n.checkYourEmail} ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, color: colors.successText)),
                            TextSpan(text: l10n.resetLinkSentBody),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.backToSignIn,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                            decoration: TextDecoration.underline),
                      ),
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
