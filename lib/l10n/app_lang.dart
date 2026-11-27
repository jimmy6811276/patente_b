/// Supported UI languages.
///
/// The question bank itself already ships bilingual (Italian + English) text,
/// so switching language also switches which text is *primary* on screen.
enum AppLang {
  it('it', 'Italiano', 'Italiano'),
  en('en', 'English', 'English');

  const AppLang(this.code, this.nativeName, this.englishName);

  final String code;
  final String nativeName;
  final String englishName;

  bool get isEnglish => this == AppLang.en;

  static AppLang fromCode(String? code) =>
      code == 'en' ? AppLang.en : AppLang.it;
}
