import 'package:flutter/material.dart';

/// Patente B — premium midnight navy + neon accents (from design showcase).
abstract final class AppColors {
  static const navy = Color(0xFF07101F);
  static const navyDeep = Color(0xFF040910);
  static const navyMid = Color(0xFF0C162C);
  static const navyCard = Color(0xFF121C34);
  static const navyElevated = Color(0xFF1A2644);
  static const navyGlass = Color(0xB3141F3A);

  static const electric = Color(0xFF2F7BFF);
  static const electricSoft = Color(0xFF5B9BFF);
  static const electricGlow = Color(0x662F7BFF);

  static const neon = Color(0xFF2EE66D);
  static const neonSoft = Color(0xFF5CFF8F);
  static const neonDim = Color(0xFF12301E);
  static const neonGlow = Color(0x662EE66D);

  static const red = Color(0xFFFF3B46);
  static const redSoft = Color(0xFFFF6B73);
  static const redDim = Color(0xFF3A1418);
  static const redGlow = Color(0x66FF3B46);

  static const orange = Color(0xFFFF9F1A);
  static const orangeDim = Color(0xFF3A2710);
  static const orangeGlow = Color(0x66FF9F1A);

  static const pink = Color(0xFFFF2D6A);
  static const pinkDim = Color(0xFF3A1020);
  static const pinkGlow = Color(0x66FF2D6A);

  static const gold = Color(0xFFFFD60A);
  static const goldDim = Color(0xFF3A3210);

  static const textPrimary = Color(0xFFF5F7FF);
  static const textSecondary = Color(0xFFA9B4CE);
  static const textMuted = Color(0xFF6E7A97);

  static const flagGreen = Color(0xFF009246);
  static const flagWhite = Color(0xFFF4F4F4);
  static const flagRed = Color(0xFFCE2B37);

  static const stroke = Color(0x28FFFFFF);
  static const strokeStrong = Color(0x40FFFFFF);

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0E1A33), navy, navyDeep],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient electricGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5BA0FF), Color(0xFF1A5FE0)],
  );

  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5CFF8F), Color(0xFF12B84E)],
  );

  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5A8A), Color(0xFFE0114D)],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC14D), Color(0xFFFF8A00)],
  );

  static const LinearGradient ringGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7CFFAE), neon, Color(0xFF00C2FF)],
  );
}
