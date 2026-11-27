import 'dart:math';

import 'fast_track_playbook.dart';
import 'fast_track_tricks.dart';

enum FtSlideKind {
  cover,
  path,
  exam,
  shape,
  combo,
  order,
  trigger,
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

    // Kill combos
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
          imageAsset: (img != null && img.isNotEmpty) ? 'assets/images/$img' : null,
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
    for (final raw in tricks.signCards.take(16)) {
      final m = raw as Map<String, dynamic>;
      sci++;
      final logic = m['logic'] as Map<String, dynamic>? ?? {};
      final vero = ((m['veroWords'] as List?) ?? []).join(', ');
      final falso = ((m['falsoWords'] as List?) ?? []).join(', ');
      final cardImg = (m['img'] as String?)?.trim();
      slides.add(
        FtSlide(
          id: 'sign_$sci',
          kind: FtSlideKind.sign,
          section: _t('Carte', 'Cards'),
          title: '${m['topicIt']}',
          accent: '${m['majority']}',
          badge: 'CARD $sci',
          imageAsset:
              (cardImg != null && cardImg.isNotEmpty) ? 'assets/images/$cardImg' : null,
          body: (logic['test'] as String?) ?? '',
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

  /// Quiz: shapes, combos, letter stamps — not ministerial reading.
  List<FtQuizItem> buildRulesQuiz({int limit = 28}) {
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

    for (final raw in tricks.deck) {
      final m = raw as Map<String, dynamic>;
      final phrase = '${m['phrase']}';
      final label = '${m['label']}';
      final coach = FtPlaybook.triggers[phrase];
      final img = (m['img'] as String?)?.trim();
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
          imageAsset: (img != null && img.isNotEmpty) ? 'assets/images/$img' : null,
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
