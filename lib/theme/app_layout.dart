import 'package:flutter/material.dart';

/// Shared layout tokens for the premium light study UI.
abstract final class AppLayout {
  static const double space = 8;
  static const double pagePad = 20;
  static const double cardRadius = 22;
  static const double chipRadius = 16;
  static const double navHeight = 64;
  static const double touchMin = 44;
  static const double ringSize = 132;
  static const double ringStroke = 11;

  /// Scroll clear space so content never sits under the floating bottom nav.
  static double bottomClearance(BuildContext context) {
    final safe = MediaQuery.paddingOf(context).bottom;
    return navHeight + 20 + safe;
  }
}
