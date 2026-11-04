import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Same Terms and Conditions / Privacy Policy text published on the
/// Landing Page (`assets/legal/terms.html` / `privacy.html`) and in the
/// report's Anexo A, kept in sync by hand across the three surfaces.
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  static const _sections = [
    (
      '1. Acceptance of terms',
      'By accessing or using MindFlow (the "App"), developed by the CogniTech team as an academic project at UPC, you agree to these Terms and Conditions. If you do not agree, do not use the App. MindFlow is a self-care and reflection tool: it does not replace care from a psychologist, psychiatrist, or other health professional, and the AI assistant does not give diagnoses or treatments. If you feel you are at risk or might harm yourself, seek help immediately: Line 113, option 5 (mental health, Peru\'s Ministry of Health) or 106 (SAMU).'
    ),
    (
      '2. Eligibility and accounts',
      'You must be 18 years or older and have the legal capacity to accept these terms. You can sign up with your email and password or with your Google account. You are responsible for keeping your login credentials secure and for all activity under your account; the information you provide when registering must be accurate. You can delete your account from the app: this removes your journal, habits, and AI conversations, though some payment or support records may be kept for legal or accounting obligations.'
    ),
    (
      '3. Use of the App',
      'You may use MindFlow for lawful personal purposes only. You must not attempt unauthorized access to other users\' data, compromise the App\'s security, or use the AI assistant to obtain content that promotes harm to yourself or others. AI-generated insights (via the Google Gemini API) are informational, may contain errors, and are not a clinical diagnosis.'
    ),
    (
      '4. Subscriptions and payments',
      'Freemium is free, with the basic journal, habit, and assistant features. Premium costs USD 4.99 per month (plus taxes depending on your country), is charged through Stripe — MindFlow does not store your card details — and renews every month until you cancel by writing to cognitech.mindflow@gmail.com; the subscription stays active until the end of the period already paid. Periods already started are not refunded, except where the law requires it or the charge was our mistake.'
    ),
    (
      '5. Privacy and data',
      'The content of your journal entries and your conversations with the assistant is stored encrypted with AES-256. We do not sell your data or use it for advertising, and we do not use the content of your entries or conversations to train our own or third-party models. Export features are provided for your personal use and for sharing with professionals you choose; you are responsible for how you share exported data.'
    ),
    (
      '6. Limitation of liability',
      'MindFlow is provided "as is": it is developed in an academic context and may have interruptions, errors, or changes. We do not guarantee that it will always be available or that AI responses will be accurate or suitable for your situation. To the extent permitted by law, we are not liable for indirect damages arising from use of the App or for decisions you make based on AI responses.'
    ),
    (
      '7. Changes and contact',
      'We may update these Terms. If the change is significant, we will notify you in the app or on the site before it takes effect; continued use afterward means you accept the change. For questions: cognitech.mindflow@gmail.com.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text('Last updated: October 2026',
                style: TextStyle(fontSize: 13, color: colors.textSecondary)),
            const SizedBox(height: 16),
            for (final (title, body) in _sections) ...[
              Text(title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(body, style: TextStyle(fontSize: 15, height: 1.5, color: colors.text)),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}
