/// Zero-Italian Fast Track playbook.
///
/// Audience: someone who cannot read Italian and must pass by scanning
/// shapes + letter clusters + combinations — never by "understanding" the sentence.
abstract final class FtPlaybook {
  /// How to use every trigger: spot cluster → tap. Never judge meaning.
  static const Map<String, FtTriggerCoach> triggers = {
    'moderare': FtTriggerCoach(
      spot: 'moderare',
      tap: 'VERO',
      mnemonic: 'MODERate speed → caution is always approved → VERO',
      action: 'See letters moderare anywhere → tap VERO. Do not translate.',
    ),
    'richiede': FtTriggerCoach(
      spot: 'richiede',
      tap: 'VERO',
      mnemonic: 'RICH-iede = letter stamp for VERO (16/16 in the bank)',
      action:
          'See richiede → tap VERO immediately. Do NOT ask “does a duty really follow?” — you cannot judge Italian. This letter cluster alone means VERO.',
    ),
    'brusche': FtTriggerCoach(
      spot: 'brusche',
      tap: 'VERO',
      mnemonic: 'BRUSque / abrupt danger word → VERO',
      action: 'See brusche → tap VERO. It marks a sudden-hazard sentence.',
    ),
    'improvvisamente': FtTriggerCoach(
      spot: 'improvvisamente',
      tap: 'VERO',
      mnemonic: 'IMPROV = sudden → VERO',
      action: 'See improvvisamente → tap VERO.',
    ),
    'condizioni': FtTriggerCoach(
      spot: 'condizioni',
      tap: 'VERO',
      mnemonic: 'CONDITIONS (soft wording) → VERO when a picture is shown',
      action: 'Picture + condizioni → VERO.',
    ),
    'potrebbe': FtTriggerCoach(
      spot: 'potrebbe',
      tap: 'VERO',
      mnemonic: 'POTentially / could → VERO',
      action: 'See potrebbe → tap VERO. Soft claim cannot be planted false.',
    ),
    'abbinato ad': FtTriggerCoach(
      spot: 'abbinato ad',
      tap: 'VERO',
      mnemonic: 'ABBINato = paired / combo → VERO',
      action: 'See abbinato ad (sign + panel combo wording) → tap VERO.',
    ),
    'eventuali': FtTriggerCoach(
      spot: 'eventuali',
      tap: 'VERO',
      mnemonic: 'EVENTUAL / possible → VERO with picture',
      action: 'Picture + eventuali → VERO.',
    ),
    'è consentito proseguire': FtTriggerCoach(
      spot: 'è consentito proseguire',
      tap: 'VERO',
      mnemonic: 'Blue disc + “allowed to continue” wording → VERO (ch.4 only)',
      action: 'Only on BLUE CIRCLE (ch.4). Spot this cluster → VERO.',
      scope: 'ch4',
    ),
    'preavvisa di': FtTriggerCoach(
      spot: 'preavvisa di',
      tap: 'VERO',
      mnemonic: 'SQUARE info sign advance warning → VERO (ch.8 only)',
      action: 'Only on SQUARE info signs (ch.8). Spot cluster → VERO.',
      scope: 'ch8',
    ),
    'alcune': FtTriggerCoach(
      spot: 'alcune',
      tap: 'VERO',
      mnemonic: 'alcune = SOME (not all) → VERO',
      action: 'See alcune → tap VERO.',
    ),
    'conducenti a passare': FtTriggerCoach(
      spot: 'conducenti a passare',
      tap: 'VERO',
      mnemonic: 'drivers must pass left/right of island → VERO (ch.4)',
      action: 'BLUE CIRCLE only. Spot cluster → VERO.',
      scope: 'ch4',
    ),
    'dei giorni': FtTriggerCoach(
      spot: 'dei giorni',
      tap: 'VERO',
      mnemonic: 'panel days/hours wording → VERO (ch.10 panels)',
      action: 'Supplementary panel chapter only. Spot → VERO.',
      scope: 'ch10',
    ),
    'transito': FtTriggerCoach(
      spot: 'transito',
      tap: 'FALSO',
      mnemonic: 'TRIANGLE + transito = wrong family noun → FALSO (ch.2)',
      action: 'Only on WARNING triangle. See transito → FALSO.',
      scope: 'ch2',
    ),
    'senso': FtTriggerCoach(
      spot: 'senso',
      tap: 'FALSO',
      mnemonic: 'BLUE disc + senso (one-way talk) → FALSO (ch.4)',
      action: 'Only on BLUE CIRCLE. See senso → FALSO.',
      scope: 'ch4',
    ),
    'vieta': FtTriggerCoach(
      spot: 'vieta',
      tap: 'FALSO',
      mnemonic: 'TRIANGLE never forbids → vieta on triangle = FALSO (ch.2)',
      action: 'WARNING triangle + vieta → FALSO. (On red circles, vieta can be true — check shape first.)',
      scope: 'ch2',
    ),
    'non è obbligatorio': FtTriggerCoach(
      spot: 'non è obbligatorio',
      tap: 'FALSO',
      mnemonic: 'NON + obbligatorio = denies a real duty → FALSO',
      action: 'See this exact cluster → FALSO. No reading needed.',
    ),
    'si trova solo': FtTriggerCoach(
      spot: 'si trova solo',
      tap: 'FALSO',
      mnemonic: 'trova + SOLO = invented place restriction → FALSO',
      action: 'See si trova solo → FALSO.',
    ),
    'le catene': FtTriggerCoach(
      spot: 'le catene',
      tap: 'FALSO',
      mnemonic: 'CATENE (snow chains) planted duty → FALSO',
      action: 'See le catene → FALSO.',
    ),
    'che è obbligatorio': FtTriggerCoach(
      spot: 'che è obbligatorio',
      tap: 'FALSO',
      mnemonic: 'che è obbligatorio hangs a fake duty → FALSO',
      action: 'See che è obbligatorio → FALSO.',
    ),
    'indicazione': FtTriggerCoach(
      spot: 'indicazione',
      tap: 'FALSO',
      mnemonic: 'BLUE disc is NOT info → indicazione on blue = FALSO (ch.4)',
      action: 'BLUE CIRCLE + indicazione → FALSO.',
      scope: 'ch4',
    ),
    'precedenza solo': FtTriggerCoach(
      spot: 'precedenza solo',
      tap: 'FALSO',
      mnemonic: 'priority + SOLO over-restricts → FALSO',
      action: 'See precedenza solo → FALSO.',
    ),
    'non comporta': FtTriggerCoach(
      spot: 'non comporta',
      tap: 'FALSO',
      mnemonic: 'NON comporta denies a real consequence → FALSO',
      action: 'See non comporta → FALSO.',
    ),
    'chiusa': FtTriggerCoach(
      spot: 'chiusa',
      tap: 'FALSO',
      mnemonic: 'CHIUS ≈ closed planted error → FALSO',
      action: 'See chiusa → FALSO.',
    ),
    'raffigurato a indica': FtTriggerCoach(
      spot: 'raffigurato (A) indica',
      tap: 'FALSO',
      mnemonic: 'Panel (A) named wrongly → FALSO (ch.10)',
      action: 'Panel chapter: “raffigurato (A) indica…” → FALSO.',
      scope: 'ch10',
    ),
  };

  static const List<FtVisualFamily> families = [
    FtVisualFamily(
      fam: 'TRIANGLE',
      famEn: 'Warning',
      shape: 'Red border triangle',
      img: '14.png',
      onlyDoes: 'Warns about a danger ahead',
      neverDoes: 'Never forbids, never orders',
      killVerbs: 'vieta / obbliga on a triangle → FALSO (19/19)',
    ),
    FtVisualFamily(
      fam: 'RED CIRCLE',
      famEn: 'Prohibition',
      shape: 'Red ring',
      img: '84.png',
      onlyDoes: 'Forbids or restricts',
      neverDoes: 'Never gives info, never orders an action',
      killVerbs: 'preannuncia on a red circle → usually FALSO',
    ),
    FtVisualFamily(
      fam: 'BLUE CIRCLE',
      famEn: 'Obligation',
      shape: 'Solid blue disc',
      img: '96.png',
      onlyDoes: 'Orders what you must do',
      neverDoes: 'Never forbids, never “information only”',
      killVerbs: 'vieta / indicazione / senso on blue disc → FALSO',
    ),
    FtVisualFamily(
      fam: 'PRIORITY',
      famEn: 'Priority',
      shape: 'Triangle / round / STOP octagon',
      img: '45.png',
      onlyDoes: 'Says who goes first',
      neverDoes: 'Never a generic ban sign',
      killVerbs: 'Calling it a “divieto” ban → FALSO',
    ),
    FtVisualFamily(
      fam: 'SQUARE',
      famEn: 'Information',
      shape: 'Blue or white square',
      img: '154.png',
      onlyDoes: 'Gives information / service',
      neverDoes: 'Never forbids or orders',
      killVerbs: 'vieta on a square → FALSO',
    ),
  ];

  /// Instant visual + wording combos — no Italian comprehension.
  static const List<FtCombo> combos = [
    FtCombo(
      title: 'Triangle + forbid verb',
      rule: 'Picture = red triangle AND sentence contains vieta or obbliga → FALSO',
      why: 'A warning only warns. Ban/order verbs on a triangle are planted lies.',
      tap: 'FALSO',
      img: '14.png',
    ),
    FtCombo(
      title: 'Blue disc + ban / info noun',
      rule: 'Picture = solid blue disc AND sentence has vieta, indicazione or senso → FALSO',
      why: 'Blue disc only orders. Ban talk or “information sign” talk is the trap.',
      tap: 'FALSO',
      img: '96.png',
    ),
    FtCombo(
      title: 'Sign + panel “abbinato”',
      rule: 'See abbinato ad (paired with) → VERO',
      why: 'Combo descriptions in the bank are true. Spot the letters, tap VERO.',
      tap: 'VERO',
      img: '127.png',
    ),
    FtCombo(
      title: 'Picture mismatch',
      rule: 'Words name one family, metal shows another → FALSO',
      why: 'Read the metal (shape/color), not the Italian. Wrong family = planted error.',
      tap: 'FALSO',
      img: '84.png',
    ),
    FtCombo(
      title: 'Absolute word AFTER trigger check',
      rule: 'solo / sempre / mai / esclusivamente with NO green trigger → lean FALSO (~72%)',
      why: 'Absolutes are a lean, not a law. If richiede / moderare / etc. also appears, follow the trigger.',
      tap: 'FALSO',
      img: null,
    ),
    FtCombo(
      title: 'Denied duty / denied consequence',
      rule: 'non è obbligatorio OR non comporta → FALSO',
      why: 'Exam denies something that is real. Letter cluster = FALSO. Zero reading.',
      tap: 'FALSO',
      img: null,
    ),
  ];

  static const List<FtScanStep> scan = [
    FtScanStep(
      n: 1,
      title: 'Picture first',
      detail: 'Name the shape family in 1 second (triangle / red ring / blue disc / priority / square). No Italian.',
    ),
    FtScanStep(
      n: 2,
      title: 'Kill combo?',
      detail: 'Does the sentence hand this shape a verb it can never do? If yes → FALSO.',
    ),
    FtScanStep(
      n: 3,
      title: 'Letter stamp',
      detail: 'Scan for a memorized cluster (richiede, moderare, le catene…). Spot → tap. Do not translate.',
    ),
    FtScanStep(
      n: 4,
      title: 'Absolute lean',
      detail: 'solo / sempre / mai / esclusivamente with no stamp → lean FALSO, then move on.',
    ),
    FtScanStep(
      n: 5,
      title: 'Tap and go',
      detail: 'Max ~10–15 s per question. 30 questions. You are pattern-matching, not reading.',
    ),
  ];
}

class FtTriggerCoach {
  const FtTriggerCoach({
    required this.spot,
    required this.tap,
    required this.mnemonic,
    required this.action,
    this.scope,
  });

  final String spot;
  final String tap;
  final String mnemonic;
  final String action;
  final String? scope;
}

class FtVisualFamily {
  const FtVisualFamily({
    required this.fam,
    required this.famEn,
    required this.shape,
    required this.img,
    required this.onlyDoes,
    required this.neverDoes,
    required this.killVerbs,
  });

  final String fam;
  final String famEn;
  final String shape;
  final String img;
  final String onlyDoes;
  final String neverDoes;
  final String killVerbs;

  String get asset => 'assets/images/$img';
}

class FtCombo {
  const FtCombo({
    required this.title,
    required this.rule,
    required this.why,
    required this.tap,
    this.img,
  });

  final String title;
  final String rule;
  final String why;
  final String tap;
  final String? img;

  String? get asset => img == null ? null : 'assets/images/$img';
}

class FtScanStep {
  const FtScanStep({
    required this.n,
    required this.title,
    required this.detail,
  });

  final int n;
  final String title;
  final String detail;
}
