import 'dart:convert';

import 'package:flutter/services.dart';

/// Bundled subset of the website `/10113198194` tricks protocol.
class FastTrackTricks {
  FastTrackTricks._(this.raw);

  final Map<String, dynamic> raw;

  static FastTrackTricks? _cache;

  static Future<FastTrackTricks> load() async {
    if (_cache != null) return _cache!;
    final text = await rootBundle.loadString('assets/data/fast_track_tricks.json');
    _cache = FastTrackTricks._(jsonDecode(text) as Map<String, dynamic>);
    return _cache!;
  }

  Map<String, dynamic> get meta => raw['meta'] as Map<String, dynamic>;
  List<dynamic> get scoreMath => raw['scoreMath'] as List<dynamic>;
  List<dynamic> get deck => raw['deck'] as List<dynamic>;
  List<dynamic> get veto => raw['veto'] as List<dynamic>;
  List<dynamic> get green => raw['green'] as List<dynamic>;
  List<dynamic> get signCards => raw['signCards'] as List<dynamic>;
  List<dynamic> get plan => raw['plan'] as List<dynamic>;
  List<dynamic> get order => raw['order'] as List<dynamic>;
  Map<String, dynamic> get conflict => raw['conflict'] as Map<String, dynamic>;
  Map<String, dynamic> get cheat => raw['cheat'] as Map<String, dynamic>;
  List<dynamic> get families => (cheat['families'] as List<dynamic>?) ?? const [];
  List<dynamic> get safeWords => (cheat['safe'] as List<dynamic>?) ?? const [];
  List<dynamic> get trapWords => (cheat['trap'] as List<dynamic>?) ?? const [];
}
