import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';

/// Haptics gated by the Settings toggle.
abstract final class AppHaptics {
  static bool _enabled(BuildContext? context) {
    if (context == null) return true;
    try {
      return context.read<AppState>().hapticsEnabled;
    } catch (_) {
      return true;
    }
  }

  static void selection([BuildContext? context]) {
    if (_enabled(context)) HapticFeedback.selectionClick();
  }

  static void light([BuildContext? context]) {
    if (_enabled(context)) HapticFeedback.lightImpact();
  }

  static void medium([BuildContext? context]) {
    if (_enabled(context)) HapticFeedback.mediumImpact();
  }

  static void heavy([BuildContext? context]) {
    if (_enabled(context)) HapticFeedback.heavyImpact();
  }
}
