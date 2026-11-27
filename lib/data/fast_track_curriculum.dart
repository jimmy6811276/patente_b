import 'dart:math';

import 'fast_track_playbook.dart';
import 'fast_track_tricks.dart';

enum FtSlideKind {
  cover,
  path,
  exam,
  shape,
  combo,
  job,
  matrixIntro,
  matrix,
  order,
  trigger,
  scoped,
  swap,
  greenIntro,
  green,
  vetoIntro,
  veto,
  conflict,
  cheatIntro,
  safe,
  trap,
  signIntro,
  sign,
  score,
  plan,
  finish,
}

class FtSlide {
  const FtSlide({
    required this.id,
    required this.kind,
    required this.section,
    required this.title,
    required this.body,
    this.accent,
    this.badge,
    this.hint,
    this.example,
    this.detail,
    this.imageAsset,
  });

  final String id;
  final FtSlideKind kind;
  final String section;
  final String title;
  final String body;
  final String? accent;
  final String? badge;
  final String? hint;
  final String? example;
  final String? detail;
  final String? imageAsset;
}

class FtQuizItem {
  const FtQuizItem({
    required this.id,
    required this.prompt,
    required this.subtitle,
    required this.correctLabel,
    required this.options,
    this.imageAsset,
  });

  final String id;
  final String prompt;
  final String subtitle;
  final String correctLabel;
  final List<String> options;
  final String? imageAsset;
}

/// Guided Zero-Italian Fast Track: visual families → kill combos → letter stamps.
class FastTrackCurriculum {
  FastTrackCurriculum(this.tricks, {this.isEn = true});

  final FastTrackTricks tricks;
  final bool isEn;

  String _t(String it, String en) => isEn ? en : it;

  static String? _familyAsset(String fam) {
    return switch (fam.toUpperCase()) {
      'TRIANGLE' => 'assets/images/14.png',
      'RED CIRCLE' => 'assets/images/84.png',
      'BLUE CIRCLE' => 'assets/images/96.png',
      'PRIORITY' => 'assets/images/45.png',
      'SQUARE' => 'assets/images/154.png',
      _ => null,
    };
  }

  static String? _imgAsset(dynamic raw) {
    final s = (raw as String?)?.trim();
    if (s == null || s.isEmpty) return null;
    if (s.startsWith('assets/')) return s;
    return 'assets/images/$s';
  }

  List<FtSlide> buildSlides() {
    final slides = <FtSlide>[
      FtSlide(
        id: 'cover',
        kind: FtSlideKind.cover,
        section: _t('Missione', 'Mission'),
        title: _t(
          'Non sai l\'italiano. Non serve. Passi con forme + combinazioni + lettere.',
          'You do not know Italian. You do not need to. You pass with shapes + combos + letter stamps.',
        ),
        body: _t(
          'All\'esame NON leggi la frase. Guardi il segnale, cerchi una combinazione o un gruppo di lettere memorizzato, tocchi VERO o FALSO. Obiettivo: 27+/30 senza capire l\'italiano.',
          'In the exam you do NOT read the sentence. You look at the sign, spot a combo or a memorized letter cluster, tap VERO or FALSO. Goal: 27+/30 without understanding Italian.',
        ),
        badge: 'ZERO ITALIAN',
      ),
      FtSlide(
        id: 'path',
        kind: FtSlideKind.path,
        section: _t('Percorso', 'Path'),
        title: _t('Ordine obbligatorio', 'Mandatory order'),
        body: _t(
          '1) 5 famiglie VISIVE (forma + colore)\n2) Combinazioni che uccidono la domanda in 1 secondo\n3) 25 francobolli di lettere (spot → tap)\n4) Parole assolute (tendenza)\n5) Test memoria → poi esame\n\nMai “capire” la frase. Solo pattern.',
          '1) 5 VISUAL families (shape + color)\n2) Kill combinations that finish a question in 1 second\n3) 25 letter stamps (spot → tap)\n4) Absolute words (lean)\n5) Memory test → then exam\n\nNever “understand” the sentence. Patterns only.',
        ),
      ),
      FtSlide(
        id: 'exam',
        kind: FtSlideKind.exam,
        section: _t('Esame', 'Exam'),
        title: _t('Protocollo esame in ~5 minuti di scansione', 'Exam protocol — ~5 minutes of scanning'),
        body: _t(
          '30 domande · 20 minuti · max 3 errori.\nMetà domande hanno un segnale. La forma decide prima delle parole.\nTu fai 5 passi per domanda (vedi Ordine). Se non scatta nulla in 10–15 s, scegli e vai avanti.',
          '30 questions · 20 minutes · max 3 errors.\nHalf the questions show a sign. Shape decides before words.\nYou run 5 steps per question (see Order). If nothing fires in 10–15 s, pick and move on.',
        ),
        accent: '30 / 20 / 3',
        hint: _t(
          'Non è teoria. È riconoscimento: metallo + lettere.',
          'This is not theory. It is recognition: metal + letters.',
        ),
      ),
    ];

    // Visual families from playbook (with real sign images)
    var fi = 0;
    for (final fam in FtPlaybook.families) {
      fi++;
      slides.add(
        FtSlide(
          id: 'shape_$fi',
          kind: FtSlideKind.shape,
          section: _t('Visivo', 'Visual'),
          title: _t('Famiglia ${fam.fam}', 'Family ${fam.fam}'),
          accent: fam.fam,
          badge: 'SHAPE $fi/5',
          imageAsset: fam.asset,
          body: _t(
            '${fam.famEn} · ${fam.shape}\n\nFA solo: ${fam.onlyDoes}\nNON può: ${fam.neverDoes}\n\nKILL: ${fam.killVerbs}',
            '${fam.famEn} · ${fam.shape}\n\nONLY does: ${fam.onlyDoes}\nNEVER does: ${fam.neverDoes}\n\nKILL: ${fam.killVerbs}',
          ),
          hint: _t(
            'Memorizza la forma. All\'esame riconosci il metallo in 1 secondo.',
            'Memorize the shape. In the exam you name the metal in 1 second.',
          ),
        ),
      );
    }

    // Kill combos (playbook)
    var ci = 0;
    for (final combo in FtPlaybook.combos) {
      ci++;
      slides.add(
        FtSlide(
          id: 'combo_$ci',
          kind: FtSlideKind.combo,
          section: _t('Combinazioni', 'Combos'),
          title: combo.title,
          accent: combo.tap,
          badge: combo.tap,
          imageAsset: combo.asset,
          body: '${combo.rule}\n\n${combo.why}',
          hint: _t(
            'Questa è una regola da esame: vedi la combo → tocchi ${combo.tap}. Fine.',
            'This is an exam rule: see the combo → tap ${combo.tap}. Done.',
          ),
        ),
      );
    }

    // Job rules — wrong verbs on a shape family (perfect bank cells)
    var ji = 0;
    for (final raw in tricks.jobRules) {
      final m = raw as Map<String, dynamic>;
      ji++;
      final fam = '${m['fam']}';
      final items = (m['items'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      final lines = items
          .map((it) => '«${it['word']}» → ${it['ans']} (${it['ok']}/${it['n']})')
          .join('\n');
      final firstImg = items.isNotEmpty
          ? _imgAsset((items.first['example'] as Map?)?['img'])
          : _familyAsset(fam);
      slides.add(
        FtSlide(
          id: 'job_$ji',
          kind: FtSlideKind.job,
          section: _t('Lavoro della forma', 'Shape job'),
          title: _t(
            '$fam solo ${m['job']} — verbi sbagliati = FALSO',
            '$fam only ${m['job']} — wrong verbs = FALSO',
          ),
          accent: fam,
          badge: '${m['ok']}/${m['n']}',
          imageAsset: firstImg ?? _familyAsset(fam),
          body: _t(
            'Forma: ${m['shape']}\n\nSe vedi queste lettere SU questa forma → FALSO:\n$lines\n\nNon leggere la frase. Forma + lettere.',
            'Shape: ${m['shape']}\n\nIf you see these letters ON this shape → FALSO:\n$lines\n\nDo not read the sentence. Shape + letters.',
          ),
          hint: _t(
            'Regola da esame: la forma ha UN lavoro. Un verbo fuori lavoro = FALSO.',
            'Exam rule: the shape has ONE job. A verb outside that job = FALSO.',
          ),
        ),
      );
    }

    // Family × verb matrix (high-purity cells first, then the rest)
    slides.add(
      FtSlide(
        id: 'matrix_intro',
        kind: FtSlideKind.matrixIntro,
        section: _t('Griglia', 'Grid'),
        title: _t(
          'Griglia forma × verbo — 26 celle misurabili',
          'Shape × verb grid — 26 measured cells',
        ),
        body: _t(
          'Quando non scatta un francobollo: riconosci la FORMA, poi le lettere del VERBO.\nOgni cella ha già un VERO/FALSO dalla banca. Spot → tap. Zero italiano.',
          'When no letter stamp fires: name the SHAPE, then spot the VERB letters.\nEach cell already has a VERO/FALSO from the bank. Spot → tap. Zero Italian.',
        ),
        badge: 'MATRIX',
      ),
    );
    final matrixSorted = [...tricks.matrix]
      ..sort((a, b) {
        final pa = ((a as Map)['purity'] as num?) ?? 0;
        final pb = ((b as Map)['purity'] as num?) ?? 0;
        return pb.compareTo(pa);
      });
    var mi = 0;
    for (final raw in matrixSorted) {
      final m = raw as Map<String, dynamic>;
      mi++;
      final fam = '${m['fam']}';
      final verb = '${m['verb']}';
      final label = '${m['label']}';
      final purity = (((m['purity'] as num?) ?? 0) * 100).round();
      slides.add(
        FtSlide(
          id: 'matrix_$mi',
          kind: FtSlideKind.matrix,
          section: _t('Griglia', 'Grid'),
          title: _t('Cella $mi/26', 'Cell $mi/26'),
          accent: '$fam + «$verb»',
          badge: label,
          imageAsset: _familyAsset(fam),
          body: _t(
            'Forma: ${m['shape']}\nVerbo EN: ${m['verbEn']}\n\nSPOT forma + lettere «$verb» → TAP $label\n($purity% · ${m['n']} casi)',
            'Shape: ${m['shape']}\nVerb EN: ${m['verbEn']}\n\nSPOT shape + letters «$verb» → TAP $label\n($purity% · ${m['n']} hits)',
          ),
          hint: _t(
            'Non tradurre. Solo forma + cluster di lettere.',
            'Do not translate. Shape + letter cluster only.',
          ),
          detail: _t('Capitolo ${m['ch']}', 'Chapter ${m['ch']}'),
        ),
      );
    }

    // 5-second order from playbook
    for (final step in FtPlaybook.scan) {
      slides.add(
        FtSlide(
          id: 'order_${step.n}',
          kind: FtSlideKind.order,
          section: _t('Scansione 5 sec', '5-sec scan'),
          title: _t('Passo ${step.n}: ${step.title}', 'Step ${step.n}: ${step.title}'),
          body: step.detail,
          accent: '${step.n}',
          badge: 'SCAN',
          hint: _t(
            'Memorizza questo passo. Lo usi su OGNI domanda.',
            'Memorize this step. You use it on EVERY question.',
          ),
        ),
      );
    }

    // 25 letter stamps — coach from playbook, bank for purity/example
    var ti = 0;
    for (final raw in tricks.deck) {
      final m = raw as Map<String, dynamic>;
      ti++;
      final phrase = '${m['phrase']}';
      final label = '${m['label']}';
      final coach = FtPlaybook.triggers[phrase];
      final scopeNote = (m['scope'] as String?) ?? 'whole bank';
      final img = (m['img'] as String?)?.trim();
      slides.add(
        FtSlide(
          id: 'trigger_$ti',
          kind: FtSlideKind.trigger,
          section: _t('Francobollo', 'Letter stamp'),
          title: _t('SPOT → TAP', 'SPOT → TAP'),
          accent: '«$phrase»',
          badge: label,
          imageAsset: _imgAsset(img),
          body: coach != null
              ? '${coach.action}\n\n${coach.mnemonic}'
              : _t(
                  'Vedi queste lettere → rispondi $label. Non tradurre.',
                  'See these letters → answer $label. Do not translate.',
                ),
          hint: _t(
            'Non giudicare il significato. Solo lettere → $label. Ambito: $scopeNote',
            'Do not judge meaning. Letters only → $label. Scope: $scopeNote',
          ),
          example: (m['example'] is Map)
              ? '${(m['example'] as Map)['it']}\n→ ${(m['example'] as Map)['ans']}'
              : null,
          detail: _t(
            'Banca: ${((m['purity'] as num) * 100).round()}% · ${m['n']} casi · $scopeNote',
            'Bank: ${((m['purity'] as num) * 100).round()}% · ${m['n']} hits · $scopeNote',
          ),
        ),
      );
    }

    // Chapter-scoped stamps — only safe inside one chapter/shape
    if (tricks.scoped.isNotEmpty) {
      slides.add(
        FtSlide(
          id: 'scoped_intro',
          kind: FtSlideKind.scoped,
          section: _t('Ambito', 'Scope'),
          title: _t(
            '9 francobolli VALIDI SOLO in un capitolo',
            '9 letter stamps VALID ONLY in one chapter',
          ),
          body: _t(
            'Fuori dal loro capitolo possono mentire. Impara: lettere + capitolo/forma insieme.',
            'Outside their chapter they can lie. Learn: letters + chapter/shape together.',
          ),
          badge: 'SCOPED',
        ),
      );
    }
    var sciScoped = 0;
    for (final raw in tricks.scoped) {
      final m = raw as Map<String, dynamic>;
      sciScoped++;
      slides.add(
        FtSlide(
          id: 'scoped_$sciScoped',
          kind: FtSlideKind.scoped,
          section: _t('Ambito', 'Scope'),
          title: _t('Solo capitolo ${m['ch']}', 'Chapter ${m['ch']} only'),
          accent: '«${m['word']}»',
          badge: '${m['label']}',
          imageAsset: _familyAsset(
            switch (m['ch'] as int?) {
              2 => 'TRIANGLE',
              3 => 'RED CIRCLE',
              4 => 'BLUE CIRCLE',
              5 => 'PRIORITY',
              8 => 'SQUARE',
              10 => 'SQUARE',
              _ => '',
            },
          ),
          body: _t(
            '${m['en']}\n\nCapitolo: ${m['ch']} · ${m['chName']}\nSPOT queste lettere SOLO lì → ${m['label']}\n(${m['pct']}% · ${m['n']} casi)',
            '${m['en']}\n\nChapter: ${m['ch']} · ${m['chName']}\nSPOT these letters ONLY there → ${m['label']}\n(${m['pct']}% · ${m['n']} hits)',
          ),
          hint: _t(
            'Se la forma/capitolo non combacia → IGNORA questo francobollo.',
            'If the shape/chapter does not match → IGNORE this stamp.',
          ),
        ),
      );
    }

    // Twin / swap demos — same base, one trap word flips answer
    var swi = 0;
    for (final raw in tricks.swapDemos) {
      final m = raw as Map<String, dynamic>;
      swi++;
      slides.add(
        FtSlide(
          id: 'swap_$swi',
          kind: FtSlideKind.swap,
          section: _t('Gemelli', 'Twins'),
          title: '${m['kind']}',
          accent: '«${m['toWord']}»',
          badge: '${m['falseAnswer']}',
          body: _t(
            'Vero (base):\n${m['trueIt']}\n→ VERO\n\nTrappola (stessa idea + «${m['toWord']}»):\n${m['falseIt']}\n→ ${m['falseAnswer']}\n\nPonte: ${m['watch']}',
            'True (base):\n${m['trueEn']}\n→ VERO\n\nTrap (same idea + «${m['toWord']}»):\n${m['falseEn']}\n→ ${m['falseAnswer']}\n\nBridge: ${m['watch']}',
          ),
          hint: _t(
            'Non leggere: se entra la parola-trappola (${m['toWord']}) → ${m['falseAnswer']}.',
            'Do not read: if the trap word (${m['toWord']}) appears → ${m['falseAnswer']}.',
          ),
          detail: '${m['ok']}/${m['n']}',
        ),
      );
    }

    // Green lean words
    slides.add(
      FtSlide(
        id: 'green_intro',
        kind: FtSlideKind.greenIntro,
        section: _t('Verdi', 'Greens'),
        title: _t('Parole verdi → spesso VERO (tendenza)', 'Green words → often VERO (lean)'),
        body: _t(
          'Non sono francobolli 100%. Se non c\'è un francobollo più forte, queste lettere spingono a VERO.',
          'Not 100% stamps. If no stronger stamp fired, these letters lean VERO.',
        ),
        badge: 'LEAN',
      ),
    );
    var gi = 0;
    for (final raw in tricks.green) {
      final m = raw as Map<String, dynamic>;
      gi++;
      slides.add(
        FtSlide(
          id: 'green_$gi',
          kind: FtSlideKind.green,
          section: _t('Verdi', 'Greens'),
          title: _t('Parola verde', 'Green word'),
          accent: '«${m['word']}»',
          badge: 'VERO ~${(m['veroPct'] as num).round()}%',
          body: _t(
            'EN: ${m['en']}\nSPOT «${m['word']}» senza francobollo FALSO → pensa VERO.\n(${m['n']} casi)',
            'EN: ${m['en']}\nSPOT «${m['word']}» with no FALSO stamp → lean VERO.\n(${m['n']} hits)',
          ),
          hint: _t(
            'Tendenza, non legge. Un francobollo FALSO vince sempre.',
            'A lean, not a law. A FALSO stamp always wins.',
          ),
        ),
      );
    }

    slides.add(
      FtSlide(
        id: 'veto_intro',
        kind: FtSlideKind.vetoIntro,
        section: _t('Assoluti', 'Absolutes'),
        title: _t('Parole ASSOLUTE = tendenza FALSO', 'ABSOLUTE words = FALSO lean'),
        body: _t(
          'solo / sempre / tutti / mai / esclusivamente… → ~72% FALSO.\nÈ una TENDENZA, non una legge.\nSe c\'è ANCHE un francobollo (richiede, moderare…), vince il francobollo.',
          'solo / sempre / tutti / mai / esclusivamente… → ~72% FALSO.\nIt is a LEAN, not a law.\nIf a letter stamp is ALSO present (richiede, moderare…), the stamp wins.',
        ),
        badge: 'LEAN ~72%',
      ),
    );

    var vi = 0;
    for (final raw in tricks.veto) {
      final m = raw as Map<String, dynamic>;
      vi++;
      slides.add(
        FtSlide(
          id: 'veto_$vi',
          kind: FtSlideKind.veto,
          section: _t('Assoluti', 'Absolutes'),
          title: _t('Francobollo assoluto', 'Absolute stamp'),
          accent: '«${m['word']}»',
          badge: 'FALSO ~${(m['falsoPct'] as num).round()}%',
          body: _t(
            'Vedi «${m['word']}» e NESSUN francobollo VERO → pensa FALSO.\nEN: ${m['en']}',
            'See «${m['word']}» and NO green stamp → think FALSO.\nEN: ${m['en']}',
          ),
          hint: _t(
            'Non leggere la frase. Solo lettere + assenza di stamp verdi.',
            'Do not read the sentence. Letters + absence of green stamps only.',
          ),
          detail: '${m['tier']}',
        ),
      );
    }

    final conflict = tricks.conflict;
    slides.add(
      FtSlide(
        id: 'conflict',
        kind: FtSlideKind.conflict,
        section: _t('Conflitto', 'Conflict'),
        title: _t('REGOLA D\'ORO: francobollo batte assoluto', 'GOLDEN RULE: stamp beats absolute'),
        body: _t(
          'Stessa frase: francobollo + solo/sempre/mai… → segui il francobollo.\nNella banca il francobollo vince quasi sempre (${conflict['triggerWins']} vs ${conflict['vetoWins']}).',
          'Same sentence: stamp + solo/sempre/mai… → follow the stamp.\nIn the bank the stamp wins almost always (${conflict['triggerWins']} vs ${conflict['vetoWins']}).',
        ),
        badge: 'STAMP WINS',
        hint: _t(
          'Esempio: richiede + solo → VERO (richiede vince).',
          'Example: richiede + solo → VERO (richiede wins).',
        ),
      ),
    );

    slides.add(
      FtSlide(
        id: 'cheat_intro',
        kind: FtSlideKind.cheatIntro,
        section: _t('Ponti', 'Bridges'),
        title: _t('Ponti di memoria (riconoscere lettere)', 'Memory bridges (spot letters)'),
        body: _t(
          'Ogni parola ha un ponte inglese solo per RICORDARLA. All\'esame non traduci: riconosci le lettere e tocchi.',
          'Each word has an English bridge only to REMEMBER it. In the exam you do not translate: you spot letters and tap.',
        ),
      ),
    );

    var si = 0;
    for (final raw in tricks.safeWords) {
      final m = raw as Map<String, dynamic>;
      si++;
      final word = '${m['word']}';
      final coach = FtPlaybook.triggers[word];
      slides.add(
        FtSlide(
          id: 'safe_$si',
          kind: FtSlideKind.safe,
          section: _t('Safe → VERO', 'Safe → VERO'),
          title: _t('SAFE — spot → VERO', 'SAFE — spot → VERO'),
          accent: '«$word»',
          badge: 'VERO',
          body: coach?.mnemonic ?? '${m['bridge']}',
          hint: coach?.action ?? '${m['bridge']}',
        ),
      );
    }

    var tri = 0;
    for (final raw in tricks.trapWords) {
      final m = raw as Map<String, dynamic>;
      tri++;
      final word = '${m['word']}';
      final coach = FtPlaybook.triggers[word];
      slides.add(
        FtSlide(
          id: 'trap_$tri',
          kind: FtSlideKind.trap,
          section: _t('Trap → FALSO', 'Trap → FALSO'),
          title: _t('TRAP — spot → FALSO', 'TRAP — spot → FALSO'),
          accent: '«$word»',
          badge: 'FALSO',
          body: coach?.mnemonic ?? '${m['bridge']}',
          hint: coach?.action ?? '${m['bridge']}',
        ),
      );
    }

    slides.add(
      FtSlide(
        id: 'sign_intro',
        kind: FtSlideKind.signIntro,
        section: _t('Carte segnale', 'Sign cards'),
        title: _t('Segnali più tirati: parole verdi / rosse', 'Top drawn signs: green / red words'),
        body: _t(
          '1) Guarda la forma\n2) Cerca una parola VERDE (→ VERO) o ROSSA (→ FALSO)\n3) Se nessuna parola → usa la maggioranza della carta\nAncora: non leggere l\'italiano, cerca lettere.',
          '1) Check the shape\n2) Hunt a GREEN word (→ VERO) or RED word (→ FALSO)\n3) If none → use the card majority\nAgain: do not read Italian — hunt letters.',
        ),
      ),
    );

    var sci = 0;
    for (final raw in tricks.signCards) {
      final m = raw as Map<String, dynamic>;
      sci++;
      final logic = m['logic'] as Map<String, dynamic>? ?? {};
      final vero = ((m['veroWords'] as List?) ?? []).join(', ');
      final falso = ((m['falsoWords'] as List?) ?? []).join(', ');
      final cardImg = _imgAsset(m['img']) ??
          _imgAsset((m['example'] as Map?)?['img']);
      slides.add(
        FtSlide(
          id: 'sign_$sci',
          kind: FtSlideKind.sign,
          section: _t('Carte', 'Cards'),
          title: '${m['topicIt']}',
          accent: '${m['majority']}',
          badge: 'CARD $sci/${tricks.signCards.length}',
          imageAsset: cardImg,
          body: (logic['test'] as String?) ??
              _t(
                'Niente parola? Usa maggioranza ${m['majority']}.',
                'No word? Use majority ${m['majority']}.',
              ),
          hint: [
            if (vero.isNotEmpty) 'GREEN → VERO: $vero',
            if (falso.isNotEmpty) 'RED → FALSO: $falso',
            if ((logic['link'] as String?)?.isNotEmpty == true) '${logic['link']}',
          ].join('\n'),
        ),
      );
    }

    slides.add(
      FtSlide(
        id: 'plan_examday',
        kind: FtSlideKind.plan,
        section: _t('Giorno esame', 'Exam day'),
        title: _t('Come passi senza italiano', 'How you pass without Italian'),
        body: _t(
          '• Forma del segnale (1 s)\n• Combo kill? (vieta su triangolo…)\n• Francobollo lettere? (richiede → VERO, le catene → FALSO…)\n• Assoluto senza stamp? → FALSO lean\n• Tocca e passa — non tradurre mai\n\nSe memorizzi forme + combo + 25 francobolli, l\'esame diventa una scansione.',
          '• Sign shape (1 s)\n• Kill combo? (vieta on triangle…)\n• Letter stamp? (richiede → VERO, le catene → FALSO…)\n• Absolute with no stamp? → FALSO lean\n• Tap and move — never translate\n\nIf you memorize shapes + combos + 25 stamps, the exam becomes a scan.',
        ),
        badge: 'EXAM DAY',
      ),
    );

    slides.add(
      FtSlide(
        id: 'finish',
        kind: FtSlideKind.finish,
        section: _t('Fatto', 'Done'),
        title: _t(
          'Hai il protocollo Zero Italian. Ora il test memoria.',
          'You have the Zero Italian protocol. Now the memory test.',
        ),
        body: _t(
          'Il prossimo passo NON è l\'esame ufficiale. È un test su forme, combinazioni e francobolli. Se li ricordi, apri l\'esame.',
          'Next is NOT the official exam. It is a test on shapes, combos and letter stamps. If you remember them, open the exam.',
        ),
        badge: 'NEXT → TEST',
      ),
    );

    return slides;
  }

  /// Quiz: shapes, combos, matrix, stamps, twins — not ministerial reading.
  List<FtQuizItem> buildRulesQuiz({int limit = 40}) {
    final items = <FtQuizItem>[];

    for (final fam in FtPlaybook.families) {
      items.add(
        FtQuizItem(
          id: 'q_shape_${fam.fam}',
          prompt: _t(
            '${fam.fam} (${fam.shape}). Può VIETARE?',
            '${fam.fam} (${fam.shape}). Can it FORBID?',
          ),
          subtitle: fam.neverDoes,
          correctLabel: fam.fam == 'RED CIRCLE' ? 'YES' : 'NO',
          options: const ['YES', 'NO'],
          imageAsset: fam.asset,
        ),
      );
    }

    for (final combo in FtPlaybook.combos) {
      items.add(
        FtQuizItem(
          id: 'q_combo_${combo.title}',
          prompt: combo.rule,
          subtitle: combo.why,
          correctLabel: combo.tap,
          options: const ['VERO', 'FALSO'],
          imageAsset: combo.asset,
        ),
      );
    }

    for (final raw in tricks.jobRules) {
      final m = raw as Map<String, dynamic>;
      final itemsJob = (m['items'] as List<dynamic>? ?? const []);
      if (itemsJob.isEmpty) continue;
      final first = itemsJob.first as Map<String, dynamic>;
      items.add(
        FtQuizItem(
          id: 'q_job_${m['fam']}_${first['word']}',
          prompt: _t(
            '${m['fam']} + lettere «${first['word']}» → ?',
            '${m['fam']} + letters «${first['word']}» → ?',
          ),
          subtitle: _t(
            'Forma che ${m['job']} — verbo fuori lavoro',
            'Shape that ${m['job']} — verb outside its job',
          ),
          correctLabel: '${first['ans']}',
          options: const ['VERO', 'FALSO'],
          imageAsset: _imgAsset((first['example'] as Map?)?['img']) ??
              _familyAsset('${m['fam']}'),
        ),
      );
    }

    for (final raw in tricks.matrix) {
      final m = raw as Map<String, dynamic>;
      final purity = ((m['purity'] as num?) ?? 0);
      if (purity < 0.75) continue; // quiz only high-confidence cells
      items.add(
        FtQuizItem(
          id: 'q_matrix_${m['fam']}_${m['verb']}',
          prompt: _t(
            'Forma ${m['fam']} + lettere «${m['verb']}» → ?',
            'Shape ${m['fam']} + letters «${m['verb']}» → ?',
          ),
          subtitle: '${m['verbEn']} · ${((purity) * 100).round()}%',
          correctLabel: '${m['label']}',
          options: const ['VERO', 'FALSO'],
          imageAsset: _familyAsset('${m['fam']}'),
        ),
      );
    }

    for (final raw in tricks.deck) {
      final m = raw as Map<String, dynamic>;
      final phrase = '${m['phrase']}';
      final label = '${m['label']}';
      final coach = FtPlaybook.triggers[phrase];
      items.add(
        FtQuizItem(
          id: 'q_trig_$phrase',
          prompt: _t(
            'Vedi le lettere «$phrase». Cosa tocchi?',
            'You see the letters «$phrase». What do you tap?',
          ),
          subtitle: coach?.action ?? '${m['en']}',
          correctLabel: label,
          options: const ['VERO', 'FALSO'],
          imageAsset: _imgAsset(m['img']),
        ),
      );
    }

    for (final raw in tricks.scoped) {
      final m = raw as Map<String, dynamic>;
      items.add(
        FtQuizItem(
          id: 'q_scoped_${m['word']}',
          prompt: _t(
            'Capitolo ${m['ch']} + «${m['word']}» → ?',
            'Chapter ${m['ch']} + «${m['word']}» → ?',
          ),
          subtitle: _t(
            'Francobollo VALIDO SOLO in quel capitolo',
            'Stamp VALID ONLY in that chapter',
          ),
          correctLabel: '${m['label']}',
          options: const ['VERO', 'FALSO'],
        ),
      );
    }

    for (final raw in tricks.swapDemos) {
      final m = raw as Map<String, dynamic>;
      items.add(
        FtQuizItem(
          id: 'q_swap_${m['toWord']}',
          prompt: _t(
            'Entra la trappola «${m['toWord']}» → ?',
            'Trap word «${m['toWord']}» appears → ?',
          ),
          subtitle: '${m['watch']}',
          correctLabel: '${m['falseAnswer']}',
          options: const ['VERO', 'FALSO'],
        ),
      );
    }

    for (final raw in tricks.safeWords) {
      final m = raw as Map<String, dynamic>;
      items.add(
        FtQuizItem(
          id: 'q_safe_${m['word']}',
          prompt: _t(
            '«${m['word']}» → VERO o FALSO?',
            '«${m['word']}» → VERO or FALSO?',
          ),
          subtitle: '${m['bridge']}',
          correctLabel: 'VERO',
          options: const ['VERO', 'FALSO'],
        ),
      );
    }

    for (final raw in tricks.trapWords) {
      final m = raw as Map<String, dynamic>;
      items.add(
        FtQuizItem(
          id: 'q_trap_${m['word']}',
          prompt: _t(
            '«${m['word']}» → VERO o FALSO?',
            '«${m['word']}» → VERO or FALSO?',
          ),
          subtitle: '${m['bridge']}',
          correctLabel: 'FALSO',
          options: const ['VERO', 'FALSO'],
        ),
      );
    }

    items.add(
      FtQuizItem(
        id: 'q_conflict',
        prompt: _t(
          'Stessa frase: «richiede» + «solo». Cosa vince?',
          'Same sentence: «richiede» + «solo». What wins?',
        ),
        subtitle: _t('Francobollo batte assoluto', 'Stamp beats absolute'),
        correctLabel: 'VERO',
        options: const ['VERO', 'FALSO'],
      ),
    );

    items.shuffle(Random());
    if (items.length > limit) return items.sublist(0, limit);
    return items;
  }
}
