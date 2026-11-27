import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Client-side gate for the Fast Track section.
///
/// The credential is never stored in plaintext: only a salted SHA-256 digest
/// of the username and of the password is compiled into the app.
///
/// IMPORTANT — this is a deterrent, not cryptographic security. The app runs
/// entirely on the device with no server, so a determined person can still
/// extract the binary and patch out this check. It reliably keeps the section
/// out of reach of ordinary users, which is what it is for. If the section ever
/// needs to protect something with real value, it has to be validated by a
/// server or the content has to be encrypted with a key derived from the
/// password.
abstract final class FastTrackAccess {
  /// Changing the salt invalidates every credential hash below it.
  static const _salt = 'pBfTsalt2026';

  /// sha256('u|$_salt|jamshaid')
  static const _userHash =
      'e4d7a1c6f7b9b5246506c95f70d6acd780f8e510e43068a8ca5e2ad16113faf8';

  /// sha256('p|$_salt|ARIF')
  static const _passHash =
      '030bd00802677849add792d12abedb0b2dd7ddff713bd755b8c4f8bc4e57875e';

  /// Username is case-insensitive; password is case-sensitive.
  static bool verify({required String username, required String password}) {
    final user = _digest('u', username.trim().toLowerCase());
    final pass = _digest('p', password);
    // Non-short-circuit on purpose: both digests are always computed.
    return _equals(user, _userHash) & _equals(pass, _passHash);
  }

  static String _digest(String kind, String value) =>
      sha256.convert(utf8.encode('$kind|$_salt|$value')).toString();

  /// Length-independent, content-constant comparison.
  static bool _equals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
