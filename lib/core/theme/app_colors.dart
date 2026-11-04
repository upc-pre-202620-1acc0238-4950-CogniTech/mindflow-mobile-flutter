import 'package:flutter/material.dart';

/// Color tokens from the MindFlow Workday v2 design handoff.
class AppColors {
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color primary;
  final Color link;
  final Color success;
  final Color successText;
  final Color warningText;
  final Color warningSurface;
  final Color crisis;
  final Color crisisText;
  final Color crisisSurface;
  final Color tintBlue;
  final Color tintGreen;
  final Color border;
  final Color inputBorder;
  final Color wordCloudAccent;

  const AppColors({
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.primary,
    required this.link,
    required this.success,
    required this.successText,
    required this.warningText,
    required this.warningSurface,
    required this.crisis,
    required this.crisisText,
    required this.crisisSurface,
    required this.tintBlue,
    required this.tintGreen,
    required this.border,
    required this.inputBorder,
    required this.wordCloudAccent,
  });

  static const light = AppColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF1B2333),
    textSecondary: Color(0xFF5A6070),
    primary: Color(0xFF2B6AD9),
    link: Color(0xFF2B6AD9),
    success: Color(0xFF23805A),
    successText: Color(0xFF1B6A49),
    warningText: Color(0xFF8A5A00),
    warningSurface: Color(0xFFFFF6E0),
    crisis: Color(0xFF8E2F2B),
    crisisText: Color(0xFF8E2F2B),
    crisisSurface: Color(0xFFFFFFFF),
    tintBlue: Color(0xFFEEF4FE),
    tintGreen: Color(0xFFEDF9F3),
    border: Color(0xFFE1E5EC),
    inputBorder: Color(0xFF7B8497),
    wordCloudAccent: Color(0xFF2B6AD9),
  );

  static const dark = AppColors(
    background: Color(0xFF0F1420),
    surface: Color(0xFF161C2B),
    text: Color(0xFFE8ECF3),
    textSecondary: Color(0xFFA3ABBD),
    primary: Color(0xFF2B6AD9),
    link: Color(0xFF8DB2F8),
    success: Color(0xFF23805A),
    successText: Color(0xFF7BD3A6),
    warningText: Color(0xFFF2C46D),
    warningSurface: Color(0xFF2B2412),
    crisis: Color(0xFF8E2F2B),
    crisisText: Color(0xFFF0A19D),
    crisisSurface: Color(0xFF2D1A1A),
    tintBlue: Color(0xFF1A2742),
    tintGreen: Color(0xFF12281F),
    border: Color(0xFF263044),
    inputBorder: Color(0xFF6B7590),
    wordCloudAccent: Color(0xFFA89CFF),
  );
}

class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  final AppColors colors;
  const AppColorsTheme(this.colors);

  @override
  AppColorsTheme copyWith({AppColors? colors}) =>
      AppColorsTheme(colors ?? this.colors);

  @override
  AppColorsTheme lerp(ThemeExtension<AppColorsTheme>? other, double t) {
    if (other is! AppColorsTheme) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColorsTheme>()!.colors;
}
