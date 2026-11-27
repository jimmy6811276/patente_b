import 'package:flutter/material.dart';

/// Advanced study-app palette — cool light canvas + ink + emerald.
/// Inspired by top learning apps (clear path, solid tiles) without purple/cream clichés.
abstract final class AppColors {
  static const canvas = Color(0xFFF3F6FB);
  static const canvasDeep = Color(0xFFE8EEF7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFF8FAFD);

  static const ink = Color(0xFF0B1220);
  static const inkSoft = Color(0xFF243047);
  static const textPrimary = Color(0xFF0B1220);
  static const textSecondary = Color(0xFF5B6B82);
  static const textMuted = Color(0xFF8A97AB);

  static const emerald = Color(0xFF00A86B);
  static const emeraldSoft = Color(0xFF1ECF86);
  static const emeraldDim = Color(0xFFE3F8EF);
  static const emeraldGlow = Color(0x3300A86B);

  static const blue = Color(0xFF1A73E8);
  static const blueSoft = Color(0xFF4B94F0);
  static const blueDim = Color(0xFFE8F1FC);
  static const blueGlow = Color(0x331A73E8);

  static const coral = Color(0xFFE5484D);
  static const coralSoft = Color(0xFFFF6B6F);
  static const coralDim = Color(0xFFFDECEC);
  static const coralGlow = Color(0x33E5484D);

  static const amber = Color(0xFFF5A524);
  static const amberDim = Color(0xFFFFF4DF);
  static const amberGlow = Color(0x33F5A524);

  static const violet = Color(0xFF6E56CF);
  static const violetDim = Color(0xFFF0EDFA);

  // Legacy aliases so existing screens keep compiling while we migrate.
  static const navy = canvas;
  static const navyDeep = canvas;
  static const navyMid = canvasDeep;
  static const navyCard = surface;
  static const navyElevated = surfaceElevated;
  static const navyGlass = Color(0xE6FFFFFF);

  static const electric = blue;
  static const electricSoft = blueSoft;
  static const electricGlow = blueGlow;

  static const neon = emerald;
  static const neonSoft = emeraldSoft;
  static const neonDim = emeraldDim;
  static const neonGlow = emeraldGlow;

  static const red = coral;
  static const redSoft = coralSoft;
  static const redDim = coralDim;
  static const redGlow = coralGlow;

  static const orange = amber;
  static const orangeDim = amberDim;
  static const orangeGlow = amberGlow;

  static const pink = Color(0xFFE548A0);
  static const pinkDim = Color(0xFFFCEAF5);
  static const pinkGlow = Color(0x33E548A0);

  static const gold = amber;
  static const goldDim = amberDim;

  static const flagGreen = Color(0xFF009246);
  static const flagWhite = Color(0xFFF4F4F4);
  static const flagRed = Color(0xFFCE2B37);

  static const stroke = Color(0x1A0B1220);
  static const strokeStrong = Color(0x280B1220);

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF7F9FC), canvas, canvasDeep],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient electricGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4B94F0), Color(0xFF1558C0)],
  );

  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2AD687), Color(0xFF008F5A)],
  );

  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6BA8), Color(0xFFD12B7A)],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC14D), Color(0xFFE08A00)],
  );

  static const LinearGradient ringGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2AD687), Color(0xFF1A73E8)],
  );
}
