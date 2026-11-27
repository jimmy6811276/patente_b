import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData dark({bool readable = false}) {
    final base = ThemeData.dark(useMaterial3: true);
    // Platform-native typeface (SF Pro on iOS, Roboto on Android).
    // No font downloads: the app must work with zero network access.
    // Readable mode widens letter-spacing and line height for dyslexia support.
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
      scaffoldBackgroundColor: AppColors.navyDeep,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electric,
        secondary: AppColors.neon,
        surface: AppColors.navyCard,
        error: AppColors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: readableStyle(
          textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.4,
          ),
          extraSpace: 0.2,
        ),
        headlineMedium: readableStyle(
          textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        titleLarge: readableStyle(
          textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        titleMedium: readableStyle(
          textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        bodyLarge: readableStyle(textTheme.bodyLarge?.copyWith(height: 1.45)),
        bodyMedium: readableStyle(
          textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        labelLarge: readableStyle(
          textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: readableStyle(
          textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      dividerColor: AppColors.stroke,
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
