/// How the second language appears under exam/quiz statements.
enum TranslationMode {
  /// Italian-only (or English-only) — real exam style.
  off,

  /// Full sentence in the other language under the statement.
  sentence,

  /// Word-by-word parallel gloss under each token.
  word,
}

extension TranslationModeX on TranslationMode {
  String get storageValue => switch (this) {
        TranslationMode.off => 'off',
        TranslationMode.sentence => 'sentence',
        TranslationMode.word => 'word',
      };

  static TranslationMode fromStorage(String? raw) {
    switch (raw) {
      case 'off':
        return TranslationMode.off;
      case 'word':
        return TranslationMode.word;
      case 'sentence':
      default:
        return TranslationMode.sentence;
    }
  }
}
