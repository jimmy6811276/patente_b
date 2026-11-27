import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData dark({bool readable = false}) {
    // Kept name for compatibility — this is now the advanced light study theme.
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    TextStyle? readableStyle(TextStyle? s, {double extraSpace = 0.6}) {
      if (s == null) return null;
      if (!readable) return s;
      return s.copyWith(
        letterSpacing: (s.letterSpacing ?? 0) + extraSpace,
        height: (s.height ?? 1.2) + 0.18,
        fontWeight: FontWeight.w700,
      );
    }

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.emerald,
        secondary: AppColors.blue,
        surface: AppColors.surface,
        error: AppColors.coral,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.ink,
        onError: Colors.white,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: readableStyle(
          textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            color: AppColors.ink,
          ),
        ),
        headlineMedium: readableStyle(
          textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            color: AppColors.ink,
          ),
        ),
        titleLarge: readableStyle(
          textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            color: AppColors.ink,
          ),
        ),
        titleMedium: readableStyle(
          textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            color: AppColors.ink,
          ),
        ),
        bodyLarge: readableStyle(
          textTheme.bodyLarge?.copyWith(
            height: 1.45,
            fontSize: 16,
            letterSpacing: 0,
            color: AppColors.ink,
          ),
        ),
        bodyMedium: readableStyle(
          textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
            letterSpacing: 0,
          ),
        ),
        labelLarge: readableStyle(
          textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            color: AppColors.ink,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: readableStyle(
          textTheme.titleLarge?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      dividerColor: AppColors.stroke,
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
