import 'dart:math';

import 'fast_track_tricks.dart';

enum FtSlideKind {
  cover,
  path,
  exam,
  shape,
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
  });

  final String id;
  final FtSlideKind kind;
  final String section;
  final String title;
  final String body;
  final String? accent; // big Italian word / shape
  final String? badge; // VERO / FALSO / SAFE / TRAP
  final String? hint;
  final String? example;
  final String? detail;
}

class FtQuizItem {
  const FtQuizItem({
    required this.id,
    required this.prompt,
    required this.subtitle,
    required this.correctLabel,
    required this.options,
  });

  final String id;
  final String prompt;
  final String subtitle;
  final String correctLabel;
  final List<String> options;
}

/// Builds the guided deck + rules quiz from the same website tricks payload.
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
        section: _t('Inizio', 'Start'),
        title: _t(
          'Se memorizzi tutti i tricks e le regole, passi al 100%.',
          'If you remember all tricks and rules, you pass 100%.',
        ),
        body: _t(
          'Questo è un percorso guidato. Una regola per slide. Poi un test solo sulle regole. Solo dopo puoi fare l\'esame.',
          'This is a guided path. One rule per slide. Then a test on the rules only. Only after that you can take the exam.',
        ),
        badge: 'ADMIN',
      ),
      FtSlide(
        id: 'path',
        kind: FtSlideKind.path,
        section: _t('Percorso', 'Path'),
        title: _t('Segui questo percorso, in ordine', 'Follow this path, in order'),
        body: _t(
          '1) Impara ogni regola\n2) Fai il test memoria regole\n3) Solo allora apri l\'esame\n\nNon saltare. Non leggere teoria italiana.',
          '1) Learn every rule\n2) Take the rules memory test\n3) Only then open the exam\n\nDo not skip. Do not read Italian theory.',
        ),
      ),
      FtSlide(
        id: 'exam',
        kind: FtSlideKind.exam,
        section: _t('Esame', 'Exam'),
        title: _t('Come è fatto l\'esame', 'How the exam works'),
        body: _t(
          '30 domande · 20 minuti · massimo 3 errori.\nOgni domanda è una frase fissa. Tu cerchi UNA parola o UNA forma, poi tocchi VERO o FALSO.',
          '30 questions · 20 minutes · max 3 errors.\nEvery question is a fixed sentence. You look for ONE word or ONE shape, then tap VERO or FALSO.',
        ),
        accent: '30 / 20 / 3',
      ),
    ];

    // Five shapes
    var fi = 0;
    for (final raw in tricks.families) {
      final m = raw as Map<String, dynamic>;
      fi++;
      slides.add(
        FtSlide(
          id: 'shape_$fi',
          kind: FtSlideKind.shape,
          section: _t('Forme', 'Shapes'),
          title: _t('Impara questa famiglia di forma', 'Learn this shape family'),
          accent: '${m['fam']}',
          body: '${m['famEn']}\n${m['shape']}',
          hint: _t(
            'Ora impara questa regola: la forma dice la famiglia.',
            'Learn this rule now: the shape tells the family.',
          ),
          badge: 'SHAPE $fi/5',
        ),
      );
    }

    // 5-second order
    for (final raw in tricks.order) {
      final m = raw as Map<String, dynamic>;
      slides.add(
        FtSlide(
          id: 'order_${m['n']}',
          kind: FtSlideKind.order,
          section: _t('Ordine 5 sec', '5-sec order'),
          title: _t('Passo ${m['n']}: ${m['t']}', 'Step ${m['n']}: ${m['t']}'),
          body: '${m['d']}',
          accent: '${m['n']}',
          hint: _t(
            'Memorizza questo passo. Lo usi su ogni domanda.',
            'Memorize this step. You use it on every question.',
          ),
          badge: 'ORDER',
        ),
      );
    }

    // 25 triggers — one slide each
    var ti = 0;
    for (final raw in tricks.deck) {
      final m = raw as Map<String, dynamic>;
      ti++;
      final label = '${m['label']}';
      slides.add(
        FtSlide(
          id: 'trigger_$ti',
          kind: FtSlideKind.trigger,
          section: _t('Trigger', 'Triggers'),
          title: _t('Impara questa regola ora', 'Learn this rule now'),
          accent: '«${m['phrase']}»',
          badge: label,
          body: '${m['en']}\n\n${m['why']}',
          hint: (m['test'] as String?)?.isNotEmpty == true
              ? '${m['test']}'
              : _t('Quando vedi questa parola → $label', 'When you see this word → $label'),
          example: (m['example'] is Map)
              ? '${(m['example'] as Map)['it']}\n→ ${(m['example'] as Map)['ans']}'
              : null,
          detail: _t(
            'Affidabilità ${((m['purity'] as num) * 100).round()}% · ${m['n']} casi',
            'Reliability ${((m['purity'] as num) * 100).round()}% · ${m['n']} hits',
          ),
        ),
      );
    }

    slides.add(
      FtSlide(
        id: 'veto_intro',
        kind: FtSlideKind.vetoIntro,
        section: _t('Assoluti', 'Absolutes'),
        title: _t('Parole assolute → spesso FALSO', 'Absolute words → often FALSO'),
        body: _t(
          'solo / sempre / tutti / mai / esclusivamente… tendono a FALSO (~71%). È una tendenza. Se c\'è un trigger, il trigger vince.',
          'solo / sempre / tutti / mai / esclusivamente… lean FALSO (~71%). It is a lean. If a trigger is present, the trigger wins.',
        ),
        badge: 'VETO',
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
          title: _t('Impara questa parola assoluta', 'Learn this absolute word'),
          accent: '«${m['word']}»',
          badge: 'FALSO ~${(m['falsoPct'] as num).round()}%',
          body: '${m['en']}',
          hint: _t(
            'Se vedi questa parola e NON c\'è un trigger → pensa FALSO.',
            'If you see this word and there is NO trigger → think FALSO.',
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
        title: _t('Regola d\'oro: il trigger batte la parola assoluta', 'Golden rule: trigger beats absolute word'),
        body: _t(
          'Se nella stessa frase c\'è un trigger E una parola assoluta, segui il trigger. Il trigger vince quasi sempre (${conflict['triggerWins']} vs ${conflict['vetoWins']} nei clash).',
          'If the same sentence has a trigger AND an absolute word, follow the trigger. The trigger wins almost always (${conflict['triggerWins']} vs ${conflict['vetoWins']} in clashes).',
        ),
        badge: 'TRIGGER WINS',
      ),
    );

    slides.add(
      FtSlide(
        id: 'cheat_intro',
        kind: FtSlideKind.cheatIntro,
        section: _t('Cheat', 'Cheat'),
        title: _t('Cheat sheet: ponti di memoria', 'Cheat sheet: memory bridges'),
        body: _t(
          'Ogni parola ha un ponte in inglese semplice. Impara il ponte. All\'esame riconosci la parola italiana.',
          'Every word has a simple English bridge. Learn the bridge. In the exam you spot the Italian word.',
        ),
      ),
    );

    var si = 0;
    for (final raw in tricks.safeWords) {
      final m = raw as Map<String, dynamic>;
      si++;
      slides.add(
        FtSlide(
          id: 'safe_$si',
          kind: FtSlideKind.safe,
          section: _t('Safe → VERO', 'Safe → VERO'),
          title: _t('Parola SAFE — impara ora', 'SAFE word — learn now'),
          accent: '«${m['word']}»',
          badge: 'VERO',
          body: '${m['en']}',
          hint: '${m['bridge']}',
        ),
      );
    }

    var tri = 0;
    for (final raw in tricks.trapWords) {
      final m = raw as Map<String, dynamic>;
      tri++;
      slides.add(
        FtSlide(
          id: 'trap_$tri',
          kind: FtSlideKind.trap,
          section: _t('Trap → FALSO', 'Trap → FALSO'),
          title: _t('Parola TRAP — impara ora', 'TRAP word — learn now'),
          accent: '«${m['word']}»',
          badge: 'FALSO',
          body: '${m['en']}',
          hint: '${m['bridge']}',
        ),
      );
    }

    slides.add(
      FtSlide(
        id: 'sign_intro',
        kind: FtSlideKind.signIntro,
        section: _t('Segnali', 'Signs'),
        title: _t('Carte segnale: parole verdi e rosse', 'Sign cards: green and red words'),
        body: _t(
          'Per i segnali più frequenti: prima la forma, poi cerca una parola verde (VERO) o rossa (FALSO). Se non c\'è parola → usa la maggioranza della carta.',
          'For the most common signs: first the shape, then look for a green word (VERO) or red word (FALSO). If no word → use the card majority.',
        ),
      ),
    );

    var sci = 0;
    for (final raw in tricks.signCards.take(12)) {
      final m = raw as Map<String, dynamic>;
      sci++;
      final logic = m['logic'] as Map<String, dynamic>? ?? {};
      final vero = ((m['veroWords'] as List?) ?? []).join(', ');
      final falso = ((m['falsoWords'] as List?) ?? []).join(', ');
      slides.add(
        FtSlide(
          id: 'sign_$sci',
          kind: FtSlideKind.sign,
          section: _t('Segnali', 'Signs'),
          title: '${m['topicIt']}',
          accent: '${m['majority']}',
          badge: 'CARD $sci',
          body: (logic['test'] as String?) ?? '',
          hint: [
            if (vero.isNotEmpty) 'VERO: $vero',
            if (falso.isNotEmpty) 'FALSO: $falso',
          ].join('\n'),
        ),
      );
    }

    // Score layers briefly
    for (final raw in tricks.scoreMath) {
      final m = raw as Map<String, dynamic>;
      slides.add(
        FtSlide(
          id: 'score_${m['key']}',
          kind: FtSlideKind.score,
          section: _t('Punteggio', 'Score'),
          title: '${m['title']}',
          body: '${m['desc']}',
          accent: (m['score'] as num).toStringAsFixed(1),
          badge: _t('livello', 'layer'),
        ),
      );
    }

    for (final raw in tricks.plan) {
      final m = raw as Map<String, dynamic>;
      final items = ((m['items'] as List?) ?? []).join('\n• ');
      slides.add(
        FtSlide(
          id: 'plan_${m['day']}',
          kind: FtSlideKind.plan,
          section: _t('Piano', 'Plan'),
          title: '${m['day']}',
          body: '• $items',
        ),
      );
    }

    slides.add(
      FtSlide(
        id: 'finish',
        kind: FtSlideKind.finish,
        section: _t('Fatto', 'Done'),
        title: _t(
          'Hai visto tutte le regole. Ora il test memoria.',
          'You have seen every rule. Now the memory test.',
        ),
        body: _t(
          'Il prossimo passo NON è l\'esame ufficiale. È un test solo sulle regole. Se le ricordi tutte, poi apri l\'esame.',
          'The next step is NOT the official exam. It is a test on the rules only. If you remember them all, then open the exam.',
        ),
        badge: 'NEXT → TEST',
      ),
    );

    return slides;
  }

  /// Quiz on rules themselves — not ministerial exam questions.
  List<FtQuizItem> buildRulesQuiz({int limit = 24}) {
    final items = <FtQuizItem>[];

    for (final raw in tricks.deck) {
      final m = raw as Map<String, dynamic>;
      final label = '${m['label']}';
      items.add(
        FtQuizItem(
          id: 'q_trig_${m['phrase']}',
          prompt: _t(
            'Vedi la parola «${m['phrase']}». Cosa rispondi?',
            'You see the word «${m['phrase']}». What do you answer?',
          ),
          subtitle: '${m['en']}',
          correctLabel: label,
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
            '«${m['word']}» è SAFE o TRAP?',
            'Is «${m['word']}» SAFE or TRAP?',
          ),
          subtitle: '${m['bridge']}',
          correctLabel: 'SAFE',
          options: const ['SAFE', 'TRAP'],
        ),
      );
    }

    for (final raw in tricks.trapWords) {
      final m = raw as Map<String, dynamic>;
      items.add(
        FtQuizItem(
          id: 'q_trap_${m['word']}',
          prompt: _t(
            '«${m['word']}» è SAFE o TRAP?',
            'Is «${m['word']}» SAFE or TRAP?',
          ),
          subtitle: '${m['bridge']}',
          correctLabel: 'TRAP',
          options: const ['SAFE', 'TRAP'],
        ),
      );
    }

    for (final raw in tricks.veto.take(8)) {
      final m = raw as Map<String, dynamic>;
      items.add(
        FtQuizItem(
          id: 'q_veto_${m['word']}',
          prompt: _t(
            'Parola assoluta «${m['word']}» senza trigger. Tendi a…',
            'Absolute word «${m['word']}» with no trigger. You lean…',
          ),
          subtitle: '${m['en']} · ~${(m['falsoPct'] as num).round()}% FALSO',
          correctLabel: 'FALSO',
          options: const ['VERO', 'FALSO'],
        ),
      );
    }

    items.shuffle(Random());
    if (items.length > limit) return items.sublist(0, limit);
    return items;
  }
}
