/// Driving-license categories offered on the home strip.
///
/// Only [LicenseCategory.b] currently has a bundled question bank.
/// Other tiles open a polished "coming soon" screen so the hub matches
/// official multi-patente apps without inventing fake content.
enum LicenseCategory {
  am('AM', 'Ciclomotore', 'Moped'),
  a('A', 'Moto', 'Motorcycle'),
  b('B', 'Auto', 'Car'),
  c('C', 'Camion', 'Truck'),
  cqc('CQC', 'Professionale', 'Professional'),
  d('D', 'Autobus', 'Bus'),
  revisione('REV', 'Revisione', 'Revision');

  const LicenseCategory(this.code, this.nameIt, this.nameEn);

  final String code;
  final String nameIt;
  final String nameEn;

  bool get isPlayable => this == LicenseCategory.b;

  static LicenseCategory fromCode(String? code) {
    for (final c in LicenseCategory.values) {
      if (c.code == code) return c;
    }
    return LicenseCategory.b;
  }
}
