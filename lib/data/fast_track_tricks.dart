import 'dart:convert';

import 'package:flutter/services.dart';

/// Bundled Fast Track protocol (website `/10113198194` parity subset + mobile coach).
class FastTrackTricks {
  FastTrackTricks._(this.raw);

  final Map<String, dynamic> raw;

  static FastTrackTricks? _cache;

  static Future<FastTrackTricks> load({bool forceReload = false}) async {
    if (!forceReload && _cache != null) return _cache!;
    final text = await rootBundle.loadString('assets/data/fast_track_tricks.json');
    _cache = FastTrackTricks._(jsonDecode(text) as Map<String, dynamic>);
    return _cache!;
  }

  static void clearCache() => _cache = null;

  Map<String, dynamic> get meta => raw['meta'] as Map<String, dynamic>;
  List<dynamic> get scoreMath => raw['scoreMath'] as List<dynamic>? ?? const [];
  List<dynamic> get deck => raw['deck'] as List<dynamic>? ?? const [];
  List<dynamic> get veto => raw['veto'] as List<dynamic>? ?? const [];
  List<dynamic> get green => raw['green'] as List<dynamic>? ?? const [];
  List<dynamic> get signCards => raw['signCards'] as List<dynamic>? ?? const [];
  List<dynamic> get plan => raw['plan'] as List<dynamic>? ?? const [];
  List<dynamic> get order => raw['order'] as List<dynamic>? ?? const [];
  List<dynamic> get matrix => raw['matrix'] as List<dynamic>? ?? const [];
  List<dynamic> get shapes => raw['shapes'] as List<dynamic>? ?? const [];
  List<dynamic> get speed => raw['speed'] as List<dynamic>? ?? const [];
  Map<String, dynamic> get conflict =>
      (raw['conflict'] as Map<String, dynamic>?) ?? const {};
  Map<String, dynamic> get cheat =>
      (raw['cheat'] as Map<String, dynamic>?) ?? const {};

  List<dynamic> get families => (cheat['families'] as List<dynamic>?) ?? const [];
  List<dynamic> get safeWords => (cheat['safe'] as List<dynamic>?) ?? const [];
  List<dynamic> get trapWords => (cheat['trap'] as List<dynamic>?) ?? const [];
  List<dynamic> get jobRules => (cheat['jobRules'] as List<dynamic>?) ?? const [];
  List<dynamic> get shapeWord => (cheat['shapeWord'] as List<dynamic>?) ?? const [];
  List<dynamic> get scoped => (cheat['scoped'] as List<dynamic>?) ?? const [];
  List<dynamic> get chapterCombos => (cheat['combos'] as List<dynamic>?) ?? const [];
  List<dynamic> get swapDemos => (cheat['swapDemos'] as List<dynamic>?) ?? const [];
}
