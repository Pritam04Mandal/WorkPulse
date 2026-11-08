import 'package:flutter/material.dart';

/// Colour tokens from the WorkPulse design canvas.
abstract final class AppColors {
  static const background = Color(0xFF0E0F11);
  static const surface = Color(0xFF16181B);
  static const border = Color(0xFF23262B);
  static const borderStrong = Color(0xFF2A2E34);
  static const divider = Color(0xFF1C1F23);

  static const text = Color(0xFFE6E8EB);
  static const textSecondary = Color(0xFFCDD2D8);
  static const textTertiary = Color(0xFFB4BAC3);
  static const muted = Color(0xFF8B919A);

  static const accent = Color(0xFF3DD6B0);
  static const onAccent = Color(0xFF0B0C0E);
  static const accentTint = Color(0xFF123A31);

  static const coding = Color(0xFF6EA8FE);
  static const ai = Color(0xFFB49CFF);
  static const meetings = Color(0xFFF0A35E);
  static const other = Color(0xFF4A4F57);

  /// Also marks inferred and sample data.
  static const amber = Color(0xFFF0A35E);
  static const amberBorder = Color(0xFF5A3F24);
  static const amberTint = Color(0xFF221A12);

  static const destructive = Color(0xFFC9473D);
  static const destructiveText = Color(0xFFFF8A80);
}

abstract final class AppFonts {
  static const sans = 'Inter';
  static const mono = 'JetBrains Mono';
}

/// Type styles that sit outside the Material text theme.
abstract final class AppText {
  /// Durations, counts and identifiers.
  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.text,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
  );

  static const overline = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.72,
    color: AppColors.muted,
  );

  static const caption = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 12,
    height: 1.5,
    color: AppColors.muted,
  );
}
