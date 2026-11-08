import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.accent,
      onSecondary: AppColors.onAccent,
      surface: AppColors.background,
      onSurface: AppColors.text,
      surfaceContainer: AppColors.surface,
      outline: AppColors.borderStrong,
      outlineVariant: AppColors.border,
      error: AppColors.destructiveText,
      onError: AppColors.onAccent,
    );

    const buttonSize = Size.fromHeight(52);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    const buttonText = TextStyle(
      fontFamily: AppFonts.sans,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      fontFamily: AppFonts.sans,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.64,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.26,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.24,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.22,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        bodyLarge: TextStyle(fontSize: 15, height: 1.5, letterSpacing: 0),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5, letterSpacing: 0),
        bodySmall: TextStyle(fontSize: 13, height: 1.5, letterSpacing: 0),
      ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.borderStrong),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: AppColors.textSecondary,
          shape: buttonShape,
          textStyle: buttonText.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.accent : AppColors.muted,
          );
        }),
      ),
    );
  }
}
