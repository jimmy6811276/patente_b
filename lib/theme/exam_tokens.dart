import 'package:flutter/material.dart';

/// Visual tokens matching the Ministero / Quiz Patenti 3.0 station UI
/// (same language as the web MotorizzazioneExam simulation).
abstract final class ExamTokens {
  static const bgTop = Color(0xFFCFD9E6);
  static const bgMid = Color(0xFFD9E2EC);
  static const bgBottom = Color(0xFFC5D0DE);

  static const panelTop = Color(0xFFEEF3F8);
  static const panelBottom = Color(0xFFDDE6F0);
  static const panelBorder = Color(0xFF9AAFC4);

  static const ink = Color(0xFF1B2433);
  static const inkSoft = Color(0xFF31455F);
  static const muted = Color(0xFF51657E);
  static const label = Color(0xFF1E4D8C);

  static const vero = Color(0xFF0F7A4D);
  static const veroSoft = Color(0xFFF4FFF8);
  static const falso = Color(0xFFC43C3C);
  static const falsoSoft = Color(0xFFFFF5F5);

  static const gridAnswered = Color(0xFF1E4D8C);
  static const gridBorder = Color(0xFF7F93AA);
  static const flag = Color(0xFFE8B84A);

  static const italiaGreen = Color(0xFF009246);
  static const italiaWhite = Color(0xFFFFFFFF);
  static const italiaRed = Color(0xFFCE2B37);

  static const LinearGradient shellGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgMid, bgBottom],
    stops: [0, 0.4, 1],
  );

  static const LinearGradient bezelGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [panelTop, panelBottom],
  );

  static const TextStyle mitEyebrow = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.6,
    color: label,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: ink,
    letterSpacing: 0,
    height: 1.2,
  );

  static const TextStyle statement = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: Color(0xFF122033),
    height: 1.35,
    letterSpacing: 0,
  );

  static const TextStyle chapter = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: muted,
  );
}
