import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../models/models.dart';
import 'app_lang.dart';

/// Typed access to every user-facing string.
///
/// Everything is resolved through [p] so adding a language means extending
/// [AppLang] and filling in the second branch — the compiler keeps call sites
/// honest because they go through named getters instead of raw keys.
class L10n {
  const L10n(this.lang);

  final AppLang lang;

  static L10n of(BuildContext context) =>
      L10n(context.watch<AppState>().lang);

  /// Read without subscribing — for one-shot use inside callbacks.
  static L10n read(BuildContext context) =>
      L10n(context.read<AppState>().lang);

  bool get isEn => lang.isEnglish;

  String p(String it, String en) => isEn ? en : it;

  // ── Content helpers ────────────────────────────────────────────────────────
  /// Chapter/topic name in the active language.
  String chapterName(Chapter c) => isEn ? c.nameEn : c.nameIt;

  String topicName(WeakTopic t) => isEn ? t.nameEn : t.nameIt;

  String secondaryChapterName(Chapter c) => isEn ? c.nameIt : c.nameEn;

  /// Question statement in the active language.
  String questionText(QuizQuestion q) => isEn ? q.textEn : q.textIt;

  /// The counterpart language, shown smaller underneath.
  String questionTextSecondary(QuizQuestion q) => isEn ? q.textIt : q.textEn;

  String fastTrackTitle(FastTrackTask t) => isEn ? t.titleEn : t.titleIt;

  String fastTrackTitleSecondary(FastTrackTask t) =>
      isEn ? t.titleIt : t.titleEn;

  String vocabularyTerm(VocabularyItem v) => isEn ? v.termEn : v.termIt;

  String vocabularyTermSecondary(VocabularyItem v) =>
      isEn ? v.termIt : v.termEn;

  String get trueLabel => p('VERO', 'TRUE');
  String get falseLabel => p('FALSO', 'FALSE');

  String answerLabel(bool isTrue) =>
      isTrue ? p('Vero', 'True') : p('Falso', 'False');

  // ── Navigation ─────────────────────────────────────────────────────────────
  String get navHome => p('Home', 'Home');
  String get navStats => p('Stats', 'Stats');
  String get navChapters => p('Capitoli', 'Chapters');
  String get navSettings => p('Impostazioni', 'Settings');
  String get navQuiz => p('Quiz', 'Quiz');
  String get navProfile => p('Profilo', 'Profile');

  String get appTitle => p('Patente B', 'Patente B');

  // ── Readiness ──────────────────────────────────────────────────────────────
  String get readinessAlmost => p('Quasi pronto', 'Almost ready');
  String get readinessGood => p('Buon progresso', 'Good progress');
  String get readinessPreparing => p('In preparazione', 'Getting there');
  String get readinessStart => p('Inizia', 'Start');
  String get progressCaption => p('Progresso', 'Progress');
  String get progressCaptionStart => p('Inizia', 'Start');

  String readinessLabel(AppStats s) {
    if (s.readiness >= 0.85) return readinessAlmost;
    if (s.readiness >= 0.6) return readinessGood;
    if (s.readiness > 0) return readinessPreparing;
    return readinessStart;
  }

  // ── Home ───────────────────────────────────────────────────────────────────
  String greeting(String name) {
    final n = name.trim();
    if (n.isEmpty || n.toLowerCase() == 'studente' || n.toLowerCase() == 'student') {
      return p('Ciao', 'Hi');
    }
    return p('Ciao $n', 'Hi $n');
  }

  String get homeSubtitle =>
      p('Il tuo coach per l\'esame', 'Your exam coach');
  String get offlineBadge => p('Offline', 'Offline');
  String get onlineBadge => p('Online', 'Online');
  String get nextActionLabel =>
      p('Prossimo passo', 'Next step');
  String get reviewTopic => p('Rivedi', 'Review');
  String get startFirstQuiz => p('Inizia il primo quiz', 'Start your first quiz');
  String get startQuizCta => p('Inizia quiz', 'Start quiz');
  String get continueQuizCta => p('Continua', 'Continue');
  String get continueSection => p('Continua', 'Continue');
  String get featuredModesSection => p('In evidenza', 'Featured');
  String get studyPathsSection => p('Percorsi di studio', 'Study paths');
  String get weakVisualSection => p('Capitoli deboli', 'Weak chapters');
  String get continueWhereLeft => p('Continua da dove eri', 'Continue where you left off');
  String get mistakesToReview => p('Errori da rivedere', 'Mistakes to review');
  String get weakChaptersSection => p('Capitoli deboli', 'Weak chapters');
  String get officialExamInfo => p(
      'Esame ufficiale: 30 domande, 20 minuti, massimo 3 errori.',
      'Official exam: 30 questions, 20 minutes, max 3 errors.');
  String get statStreak => p('Streak', 'Streak');
  String get statAccuracy => p('Accuratezza', 'Accuracy');
  String get statQuestions => p('Domande', 'Questions');
  String streakValue(int days) => p('$days giorni', '$days days');
  String daysShort(int d) => p('$d gg', '${d}d');
  String get streakLabel => p('giorni streak', 'day streak');
  String get accuracyLabel => p('accuratezza', 'accuracy');
  String get fastTrackSubtitle =>
      p('Admin · pass in 1–4 giorni', 'Admin · pass in 1–4 days');
  String get quizTitle => p('Quiz', 'Quiz');
  String questionsCount(int n) => p('$n domande', '$n questions');
  String get simulationTitle => p('Simulazione', 'Mock exam');
  String get officialExam => p('Esame ufficiale', 'Official format');
  String get myMistakes => p('I miei errori', 'My mistakes');
  String toReview(int n) => p('$n da rivedere', '$n to review');
  String get privateBadge => p('Privato', 'Private');

  // ── Stats ──────────────────────────────────────────────────────────────────
  String get statsTitle => p('Statistiche', 'Statistics');
  String get statsSubtitle =>
      p('Learning intelligence · solo dati locali', 'Learning intelligence · local data only');
  String get tabGeneral => p('Generale', 'Overview');
  String get tabWeak => p('Debolezze', 'Weak spots');
  String get tabTrend => p('Trend', 'Trend');
  String answersCount(int n) => p('$n risposte', '$n answers');
  String get ready => p('pronto', 'ready');
  String get last7Days => p('Ultimi 7 giorni', 'Last 7 days');
  String streakDays(int n) => p('$n giorni', '$n days');
  String get completeFirstQuiz =>
      p('Completa il primo quiz per vedere il tuo andamento.',
          'Finish your first quiz to see your progress.');
  String get hardestTopics =>
      p('Argomenti più difficili', 'Hardest topics');
  String get weakHint => p(
      'Rispondi ad almeno 3 domande per capitolo per generare i punti deboli.',
      'Answer at least 3 questions per chapter to surface weak spots.');
  String get nextReview => p('Prossima revisione', 'Next review');
  String get startQuizForReview =>
      p('Inizia un quiz per attivare il ripasso', 'Start a quiz to enable review');
  String spacedRepetition(int days) => p('Spaced repetition · $days giorni stimati',
      'Spaced repetition · est. $days days');
  String passProbability(int pct) => p(
      'Probabilità di superamento stimata: $pct% '
      '(stima da accuratezza, copertura capitoli e simulazioni)',
      'Estimated pass probability: $pct% '
      '(based on accuracy, chapter coverage and mock exams)');

  // ── Chapters ───────────────────────────────────────────────────────────────
  String get chaptersTitle => p('Capitoli', 'Chapters');
  String chaptersSubtitle(int chapters, int questions) => p(
      '$chapters capitoli · $questions domande offline',
      '$chapters chapters · $questions offline questions');
  String get searchChapter => p('Cerca capitolo…', 'Search chapter…');
  String get noChaptersFound => p('Nessun capitolo trovato', 'No chapters found');
  String totalChapters(int n) => p('Totale: $n Capitoli', 'Total: $n chapters');
  String get diffEasy => p('Facile', 'Easy');
  String get diffMedium => p('Medio', 'Medium');
  String get diffHard => p('Difficile', 'Hard');

  String difficulty(Difficulty d) => switch (d) {
        Difficulty.easy => diffEasy,
        Difficulty.medium => diffMedium,
        Difficulty.hard => diffHard,
      };

  // ── Quiz ───────────────────────────────────────────────────────────────────
  String get loadingLocalDb =>
      p('Caricamento dal database locale…', 'Loading from local database…');
  String get noBookmarks => p('Nessun segnalibro', 'No bookmarks yet');
  String get noQuestionsAvailable =>
      p('Nessuna domanda disponibile', 'No questions available');
  String get bookmarkHint => p(
      'Tocca il segnalibro durante un quiz per salvare le domande qui.',
      'Tap the bookmark during a quiz to save questions here.');
  String get mistakeHint => p(
      'Fai prima qualche quiz per raccogliere errori da ripassare.',
      'Take a few quizzes first to collect mistakes for review.');
  String get back => p('Torna', 'Back');
  String get sessionComplete => p('Sessione completata', 'Session complete');
  String correctWrongPct(int correct, int wrong, int pct) => p(
      '$correct corrette · $wrong errori · $pct%',
      '$correct correct · $wrong wrong · $pct%');
  String get progressSaved =>
      p('Progressi salvati nel database locale', 'Progress saved to the local database');
  String get close => p('Chiudi', 'Close');
  String get hint => p('Suggerimento', 'Hint');
  String get english => p('English', 'Italiano');
  String get correct => p('✓ Corretto', '✓ Correct');
  String get incorrect => p('✕ Errato', '✕ Wrong');
  String correctAnswer(bool isTrue) =>
      p('Risposta corretta: ${isTrue ? trueLabel : falseLabel}',
          'Correct answer: ${isTrue ? trueLabel : falseLabel}');
  String get next => p('Prossima', 'Next');
  String get seeResult => p('Vedi risultato', 'See result');
  String get defaultSignLabel => p('Segnale', 'Sign');
  String get tagSigns => p('segnaletica', 'road signs');
  String get tagNumbers => p('numeri', 'numbers');
  String chapterShort(int id) => p('cap. $id', 'ch. $id');

  // ── Exam ───────────────────────────────────────────────────────────────────
  String get examLobbyTitle => p('Simulazione\nEsame', 'Mock\nExam');
  String get examLobbySubtitle => p(
      'Formato ufficiale Ministero:\n30 domande · 20 minuti · massimo 3 errori',
      'Official ministry format:\n30 questions · 20 minutes · max 3 errors');
  String get rule30 => p('30 domande Vero / Falso', '30 true / false questions');
  String get ruleCountdown => p('Countdown circolare 20:00', 'Circular 20:00 countdown');
  String get ruleThreshold => p('Soglia: ≤ 3 errori', 'Pass mark: ≤ 3 errors');
  String get noSimulationYet => p('Nessuna simulazione ancora', 'No mock exams yet');
  String attemptsAndPasses(int attempts, int passes) =>
      p('$attempts tentativi · $passes superati', '$attempts attempts · $passes passed');
  String get preparing => p('Preparazione…', 'Preparing…');
  String get startSimulation => p('Inizia simulazione', 'Start mock exam');
  String get questionsFromLocal => p('Domande selezionate dal database locale',
      'Questions drawn from the local database');
  String get passedTitle => p('Esame SUPERATO', 'Exam PASSED');
  String get failedTitle => p('Esame NON SUPERATO', 'Exam FAILED');
  String examResult(int correct, int wrong, int answered, int total) => p(
      '$correct corrette · $wrong errori (max 3)\nRisposte: $answered/$total',
      '$correct correct · $wrong wrong (max 3)\nAnswered: $answered/$total');
  String get resultSaved => p('Esito salvato nel database locale',
      'Result saved to the local database');
  String get backHome => p('Torna alla home', 'Back to home');
  String get scoreCorrect => p('Corrette', 'Correct');
  String get scoreErrors => p('Errori · max 3', 'Errors · max 3');
  String get scoreQuestion => p('Domanda', 'Question');
  String get markForReview => p('Segna per revisione', 'Flag for review');
  String get markedForReview => p('Segnata per revisione', 'Flagged for review');
  String get previous => p('Precedente', 'Previous');
  String get skip => p('Salta', 'Skip');
  String get advance => p('Avanti', 'Next');
  String get submit => p('Consegna', 'Submit');
  String get timeRemaining => p('rimanente', 'left');

  // ── Mistakes ───────────────────────────────────────────────────────────────
  String get mistakesTitle => p('I miei errori', 'My mistakes');
  String savedMistakes(int n) => p('$n errori salvati', '$n saved mistakes');
  String get groupedByChapter =>
      p('Raggruppati per capitolo · spaced repetition', 'Grouped by chapter · spaced repetition');
  String get retry => p('Riprova', 'Retry');
  String get mistakesReview => p('Ripasso errori', 'Mistake review');
  String chapterBadge(int id) => p('Cap. $id', 'Ch. $id');
  String wrongTimes(int n) => p('$n× errata', '$n× wrong');
  String correctIs(bool isTrue) =>
      p('Corretta: ${isTrue ? trueLabel : falseLabel}', 'Correct: ${isTrue ? trueLabel : falseLabel}');
  String get noMistakes => p('Nessun errore salvato', 'No mistakes saved');
  String get noMistakesHint => p(
      'Le risposte sbagliate verranno raccolte qui automaticamente per il ripasso.',
      'Wrong answers are collected here automatically for focused review.');

  // ── Settings ───────────────────────────────────────────────────────────────
  String get settingsTitle => p('Impostazioni', 'Settings');
  String get languageTitle => p('Lingua', 'Language');
  String get languageSubtitle =>
      p('Interfaccia e contenuti', 'Interface and content');
  String get italian => p('Italiano', 'Italiano');
  String get englishLang => p('Inglese', 'English');
  String get translationEnglish =>
      p('Traduzione durante lo studio', 'Study translation');
  String get translationSubtitle => p(
      'Off = solo esame · Frase = traduzione intera · Parola = parola per parola',
      'Off = exam-only · Sentence = full translation · Word = word by word');
  String get translationOff => p('Solo IT/EN', 'Off (exam)');
  String get translationSentence => p('Per frase', 'By sentence');
  String get translationWord => p('Parola per parola', 'Word by word');
  String get translationOffShort => p('Off', 'Off');
  String get translationSentenceShort => p('Frase', 'Sentence');
  String get translationWordShort => p('Parole', 'Words');
  String get wordModeHint => p(
      'Ogni parola italiana ha la traduzione sotto. Ideale per studiare.',
      'Each Italian word has its translation underneath. Ideal for study.');
  String get haptics => p('Feedback aptico', 'Haptic feedback');
  String get hapticsSubtitle => p('Vibrazione su risposte', 'Vibrate on answers');
  String get offlineMode => p('Sempre offline', 'Always offline');
  String get offlineSubtitle => p(
      'Database e immagini inclusi — nessuna rete richiesta',
      'Database and images bundled — no network required');
  String get audio => p('Audio pronuncia', 'Pronunciation audio');
  String get audioSubtitle => p(
      'In arrivo nella prossima versione',
      'Coming in a future update');
  String get examNavTitle => p('Mappa domande', 'Question map');
  String get examAnswered => p('Risposte', 'Answered');
  String get examFlagged => p('Segnate', 'Flagged');
  String get examRemaining => p('Rimanenti', 'Left');
  String get jumpToQuestion => p('Vai alla domanda', 'Go to question');
  String get localDatabase => p('Database locale', 'Local database');
  String get lblChapters => p('Capitoli', 'Chapters');
  String get lblQuestions => p('Domande', 'Questions');
  String get lblVocab => p('Vocaboli', 'Words');
  String get lblAnswers => p('Risposte registrate', 'Recorded answers');
  String get allIncluded => p(
      'Tutti i contenuti sono inclusi nell\'app. Nessuna API, nessun download di immagini, nessuna connessione richiesta.',
      'All content is bundled with the app. No API, no image downloads, no connection required.');
  String get bookmarks => p('Segnalibri', 'Bookmarks');
  String get bookmarksSubtitle => p(
      'Domande salvate durante i quiz', 'Questions saved during quizzes');
  String get resetProgress => p('Azzera progressi', 'Reset progress');
  String get resetSubtitle =>
      p('Cancella risposte, errori ed esami', 'Clears answers, mistakes and exams');
  String get resetDialogTitle => p('Azzerare i progressi?', 'Reset your progress?');
  String get resetDialogBody => p(
      'Verranno cancellati risposte, errori, segnalibri ed esiti degli esami. Le domande restano disponibili.',
      'Answers, mistakes, bookmarks and exam results will be deleted. Questions stay available.');
  String get cancel => p('Annulla', 'Cancel');
  String get reset => p('Azzera', 'Reset');
  String get progressReset => p('Progressi azzerati nel database locale',
      'Progress reset in the local database');
  String get fastTrackSectionRow => p('Fast Track', 'Fast Track');
  String get fastTrackUnlockedLocal =>
      p('Sbloccato su questo dispositivo', 'Unlocked on this device');
  String get fastTrackLockedCreds =>
      p('Protetto da credenziali', 'Protected by credentials');
  String get lock => p('Blocca', 'Lock');
  String get fastTrackLockedToast =>
      p('Fast Track bloccato di nuovo', 'Fast Track locked again');
  String buildInfo(String version) => p(
      'Intelligent bilingual driving-theory platform\nBuild $version · Flutter iOS + Android',
      'Intelligent bilingual driving-theory platform\nBuild $version · Flutter iOS + Android');

  // ── Fast Track ─────────────────────────────────────────────────────────────
  String get fastTrackScreenTitle => p('Fast Track', 'Fast Track');
  String get ftAdminOnly => p('SOLO ADMIN', 'ADMIN ONLY');
  String get ftHeaderSub => p(
      'Sprint privato · niente italiano richiesto',
      'Private sprint · no Italian needed');
  String get ftTabPass => p('Pass', 'Pass');
  String get ftTabMethod => p('Metodo', 'Method');
  String get ftTabTriggers => p('Trigger', 'Triggers');
  String get ftTabAbsolutes => p('Assoluti', 'Absolutes');
  String get ftTabCheat => p('Cheat', 'Cheat');
  String get ftTabSigns => p('Segnali', 'Signs');
  String get ftTabPlan => p('Piano', 'Plan');
  String get ftPassBadge => p('PROMESSA PASS 100%', 'PASS PROMISE 100%');
  String get ftPassHeadline => p(
      'Zero italiano: forme + combinazioni + francobolli di lettere → passi.',
      'Zero Italian: shapes + combos + letter stamps → you pass.');
  String get ftPassBody => p(
      'Non leggi la frase. Riconosci la forma del segnale, una combinazione kill, o un gruppo di lettere memorizzato, poi tocchi VERO o FALSO.',
      'You do not read the sentence. You recognize the sign shape, a kill combo, or a memorized letter cluster, then tap VERO or FALSO.');
  String get ftQLabel => p('domande', 'questions');
  String get ftMinLabel => p('minuti', 'minutes');
  String get ftErrLabel => p('errori max', 'errors max');
  String get ftWhoTitle => p('Per chi è', 'Who this is for');
  String get ftWhoBody => p(
      'Solo admin e pochi utenti speciali. Non conosci l\'italiano. Devi passare in 1–4 giorni. Memorizzi forme, combinazioni e francobolli — non leggi teoria.',
      'Only admin and a few special users. You do not know Italian. You must pass in 1–4 days. You memorize shapes, combos and letter stamps — you do not read theory.');
  String get ftMustMemorize => p('Devi memorizzare', 'You must memorize');
  String get ftMust1 => p('Le 5 famiglie VISIVE (forma + colore)', 'The 5 VISUAL families (shape + color)');
  String get ftMust2 => p('Le combinazioni kill (es. triangolo + vieta)', 'Kill combos (e.g. triangle + vieta)');
  String get ftMust3 => p('I 25 francobolli di lettere (spot → tap)', 'The 25 letter stamps (spot → tap)');
  String get ftMust4 => p('Assoluti (solo/sempre/mai) come tendenza', 'Absolutes (solo/sempre/mai) as a lean');
  String get ftMust5 => p('La scansione in 5 secondi su ogni domanda', 'The 5-second scan on every question');
  String get ftSimpleRule => p('Regola semplice', 'Simple rule');
  String get ftSimpleRuleBody => p(
      'Non tradurre. Guarda la forma, cerca una combo o un francobollo di lettere, tocca VERO/FALSO. Mai giudicare il “senso” della frase.',
      'Do not translate. Check the shape, hunt a combo or letter stamp, tap VERO/FALSO. Never judge the “meaning” of the sentence.');
  String get ftStartDrill => p('Inizia drill', 'Start drill');
  String get ftMethodHeadline => p(
      'Non leggi l\'italiano. Leggi forma + lettere.',
      'You do not read Italian. You read shape + letters.');
  String get ftMethodBody => p(
      'Ogni domanda è una frase fissa. Guardi il segnale, cerchi una combo o un francobollo, tocchi VERO o FALSO. Massimo 10–15 secondi a domanda.',
      'Every question is a fixed sentence. Look at the sign, hunt a combo or letter stamp, tap VERO or FALSO. Max 10–15 seconds per question.');
  String get ftFiveSecond => p('Ordine in 5 secondi', 'Five-second order');
  String get ftScoreLayers => p('Livelli di punteggio', 'Score layers');
  String get ftScoreHint => p(
      'Più livelli memorizzi, più alto è il tuo punteggio atteso.',
      'The more layers you memorize, the higher your expected score.');
  String get ftTriggersIntro => p(
      'I 25 francobolli sono cluster di lettere. Non capisci la parola: la riconosci e tocchi. L\'inglese è solo un ponte di memoria.',
      'The 25 stamps are letter clusters. You do not understand the word: you spot it and tap. English is only a memory bridge.');
  String ftPurityLine(int pct, num n) =>
      p('Affidabilità $pct% · $n casi', 'Reliability $pct% · $n hits');
  String get ftVetoTitle => p('Parole assolute → spesso FALSO', 'Absolute words → often FALSO');
  String ftVetoBody(String pct) => p(
      'solo / sempre / tutti / mai / esclusivamente… tendono a FALSO (~$pct%). È una tendenza, non una regola assoluta. Se c\'è un trigger, il trigger vince.',
      'solo / sempre / tutti / mai / esclusivamente… lean FALSO (~$pct%). This is a lean, not a hard rule. If a trigger is present, the trigger wins.');
  String get ftGreenTitle => p('Parole verdi → spesso VERO', 'Green words → often VERO');
  String get ftCheatTitle => p('Cheat sheet — memoria veloce', 'Cheat sheet — fast memory');
  String get ftCheatBody => p(
      'Ponte in inglese semplice. Impara il ponte, riconosci la parola italiana all\'esame.',
      'Simple English bridges. Learn the bridge, spot the Italian word in the exam.');
  String get ftSafeWords => p('Parole SAFE → VERO', 'SAFE words → VERO');
  String get ftTrapWords => p('Parole TRAP → FALSO', 'TRAP words → FALSO');
  String get ftFamiliesTitle => p('Cinque famiglie di forma', 'Five shape families');
  String get ftSignCardsTitle => p('Carte segnale top', 'Top sign cards');
  String get ftPlanTitle => p('Piano 1–4 giorni', '1–4 day plan');
  String get ftPlanBody => p(
      'Segui i blocchi in ordine. Non saltare all\'esame finché non hai memorizzato trigger + assoluti + cheat sheet.',
      'Follow the blocks in order. Do not jump to the exam until you have memorized triggers + absolutes + cheat sheet.');
  String get ftPassFooter => p(
      'Ricorda tutti i tricks e le regole → passi al 100%.',
      'Remember every trick and rule → you pass 100%.');
  String get ftGuidedSub => p(
      'Zero Italian · forme · combo · francobolli',
      'Zero Italian · shapes · combos · stamps');
  String get ftGuidedPathIntro => p(
      'Prima forme e combinazioni. Poi francobolli. Poi test memoria. Solo dopo l\'esame.',
      'First shapes and combos. Then letter stamps. Then memory test. Only then the exam.');
  String get ftFollowPath => p('Segui questo percorso', 'Follow this path');
  String get ftStep1Title => p('1. Impara tutte le regole', '1. Learn every rule');
  String ftStep1Sub(int current, int total) => p(
      'Slide $current di $total · una regola alla volta',
      'Slide $current of $total · one rule at a time');
  String get ftStartLearning => p('Inizia a imparare', 'Start learning');
  String get ftReviewRules => p('Rivedi le regole', 'Review the rules');
  String get ftStep2Title => p('2. Test memoria regole', '2. Rules memory test');
  String get ftStep2Ready =>
      p('Pronto: quiz solo sulle regole (non sull\'esame)', 'Ready: quiz on rules only (not the exam)');
  String get ftStep2Locked =>
      p('Bloccato finché non finisci tutte le slide', 'Locked until you finish every slide');
  String ftStep2Done(int pct) =>
      p('Superato · $pct%', 'Passed · $pct%');
  String get ftTakeRulesTest => p('Fai il test regole', 'Take rules test');
  String get ftStep3Title => p('3. Esame ufficiale', '3. Official exam');
  String get ftStep3Ready =>
      p('Sbloccato: ora puoi fare la simulazione', 'Unlocked: you can take the mock exam');
  String get ftStep3Locked =>
      p('Bloccato finché non passi il test regole (≥85%)', 'Locked until you pass the rules test (≥85%)');
  String get ftOpenExam => p('Apri l\'esame', 'Open exam');
  String get ftHowItWorks => p('Come funziona', 'How it works');
  String get ftHowItWorksBody => p(
      'Percorso completo Zero Italian: forme, job di forma, griglia forma×verbo, 25 francobolli, ambiti di capitolo, gemelli-trappola, verdi/assoluti, 44 carte segnale. Poi test memoria (≥85%) e esame.',
      'Full Zero Italian path: shapes, shape jobs, shape×verb grid, 25 letter stamps, chapter scopes, twin traps, greens/absolutes, 44 sign cards. Then memory test (≥85%) and exam.');
  String get ftFinishSlidesFirst => p(
      'Prima finisci tutte le slide delle regole.',
      'Finish all rule slides first.');
  String get ftPassRulesFirst => p(
      'Prima passa il test memoria regole (≥85%).',
      'Pass the rules memory test first (≥85%).');
  String ftLessonProgress(int current, int total) =>
      p('Regola $current / $total', 'Rule $current / $total');
  String get ftLearnedNext => p('Ho imparato → prossima', 'I learned this → next');
  String get ftFinishLesson => p('Ho finito le regole', 'I finished the rules');
  String get ftExample => p('ESEMPIO', 'EXAMPLE');
  String get ftRulesTestTitle => p('Test memoria regole', 'Rules memory test');
  String get ftRulesTestHint => p(
      'Questo NON è l\'esame ufficiale — solo le regole Fast Track',
      'This is NOT the official exam — Fast Track rules only');
  String get ftSeeResult => p('Vedi risultato', 'See result');
  String get ftMasteryPassTitle => p('Regole memorizzate', 'Rules memorized');
  String get ftMasteryFailTitle => p('Ancora non abbastanza', 'Not enough yet');
  String ftMasteryScore(int correct, int total, int pct) =>
      p('$correct / $total corrette · $pct%', '$correct / $total correct · $pct%');
  String get ftMasteryPassBody => p(
      'Ora puoi aprire l\'esame. Se ricordi tutte le regole, passi al 100%.',
      'You can open the exam now. If you remember all the rules, you pass 100%.');
  String get ftMasteryFailBody => p(
      'Ripassa le slide e riprova il test. Serve almeno 85%.',
      'Review the slides and retry the test. You need at least 85%.');
  String get ftGoExam => p('Vai all\'esame', 'Go to exam');
  String get ftRetryRules => p('Riprova il test', 'Retry the test');
  String get ftResetTitle => p('Reset pratica regole', 'Reset rules practice');
  String get ftResetHint => p(
      'Ricomincia lezioni + test da zero per memorizzare di nuovo',
      'Restart lessons + test from zero to memorize again');
  String get ftResetBody => p(
      'Cancella il progresso delle slide e il test memoria. Potrai ripassare tutte le regole e rifare il test. L\'esame ufficiale non viene cancellato.',
      'Clears slide progress and the memory test. You can re-learn every rule and retake the test. The official exam history is not cleared.');
  String get ftResetConfirm => p('Reset ora', 'Reset now');
  String get ftResetDone => p(
      'Pratica Fast Track resettata. Riparti dalla lezione 1.',
      'Fast Track practice reset. Start again from lesson 1.');
  String ftCoverageLine(int stamps, int matrix, int cards, int jobs) => p(
      'Copertura: $stamps francobolli · $matrix celle griglia · $cards carte segnale · $jobs job di forma',
      'Coverage: $stamps letter stamps · $matrix grid cells · $cards sign cards · $jobs shape jobs');
  String get turboPlan => p('Piano Turbo', 'Turbo Plan');
  String get turboPlanSubtitle => p(
      'Zero italiano → pronto per l\'esame\nin 1–4 giorni intensivi',
      'Zero Italian → exam ready\nin 1–4 intensive days');
  String percentComplete(int pct) =>
      p('$pct% completato', '$pct% complete');
  String get day1 => p('Giorno 1', 'Day 1');
  String get day1Sub => p('Fondamenta + segnali di pericolo', 'Foundations + danger signs');
  String get day2 => p('Giorno 2', 'Day 2');
  String get day2Sub => p('Limiti, distanza, mini-esame', 'Limits, distance, mini exam');
  String get vocabularyEssentials =>
      p('Vocabolario essenziale', 'Essential vocabulary');
  String get showAll => p('Tutti', 'All');
  String get showLess => p('Meno', 'Less');
  String get startPlan => p('Inizia il Piano', 'Start the plan');
  String get continuePlan => p('Continua il Piano', 'Continue the plan');
  String get fastTrackQuiz => p('Fast Track Quiz', 'Fast Track Quiz');
  String get featureTricks => p('Tricks', 'Tricks');
  String get featureSigns => p('Segnali', 'Signs');
  String chapterShortFT(int id) => p('Cap. $id', 'Ch. $id');

  // ── Fast Track gate ────────────────────────────────────────────────────────
  String get reservedArea => p('Area riservata', 'Restricted area');
  String get privateSectionBody => p(
      'Area admin riservata.\nPer chi non parla italiano e deve passare l\'esame in 1–4 giorni.\nInserisci le credenziali dell\'amministratore.',
      'Private admin area.\nFor people who do not speak Italian and must pass in 1–4 days.\nEnter the administrator credentials.');
  String get username => p('Nome utente', 'Username');
  String get password => p('Password', 'Password');
  String get unlock => p('Sblocca', 'Unlock');
  String get verifying => p('Verifica…', 'Checking…');
  String get invalidCredentials =>
      p('Credenziali non valide. Riprova.', 'Invalid credentials. Try again.');
  String get fillBothFields =>
      p('Inserisci nome utente e password.', 'Enter a username and password.');
  String get tooManyAttempts => p(
      'Troppi tentativi. Attendi qualche secondo prima di riprovare.',
      'Too many attempts. Wait a few seconds before trying again.');
  String get deviceVerified => p(
      'Accesso verificato sul dispositivo · nessun dato inviato',
      'Verified on device · nothing is sent');

  // ── Loading / errors ───────────────────────────────────────────────────────
  String get preparingDb =>
      p('Preparazione del database locale…', 'Preparing the local database…');
  String get dbUnavailable =>
      p('Database locale non disponibile', 'Local database unavailable');
  String get retryBtn => p('Riprova', 'Retry');

  // ── First-run language picker ──────────────────────────────────────────────
  String get chooseLanguage => p('Scegli la lingua', 'Choose your language');
  String get chooseLanguageBody => p(
      'Puoi cambiarla in qualsiasi momento dalle impostazioni.',
      'You can change it anytime in settings.');
  String get welcomeTitle => p('Benvenuto', 'Welcome');
  String get continueLabel => p('Continua', 'Continue');

  // ── Advanced hub ───────────────────────────────────────────────────────────
  String get chooseLicense => p('Scegli la patente', 'Choose your license');
  String get studyModes => p('Modalità di studio', 'Study modes');
  String get practiceSection => p('Pratica', 'Practice');
  String get examSection => p('Esame e ripasso', 'Exam & review');
  String get studySection => p('Studio', 'Study');
  String get toolsSection => p('Strumenti', 'Tools');
  String get hubChapters => p('Capitoli', 'Chapters');
  String get hubSigns => p('Segnali', 'Signs');
  String get signsAtlasTitle => p('Atlante segnali', 'Signs atlas');
  String get signsAtlasSubtitle => p(
      'Tutti i diagrammi ministeriali, cerca e apri il capitolo',
      'Every ministerial diagram — search and open the chapter');
  String get searchSign => p('Cerca segnale o capitolo', 'Search sign or chapter');
  String get noSignsFound => p('Nessun segnale trovato', 'No signs found');
  String get signsAtlasTileSub => p('Sfoglia tutti i cartelli', 'Browse every road sign');
  String get practiceAllTitle => p('Tutte le domande', 'All questions');
  String get practiceAllSub => p('Banca completa in ordine casuale', 'Full bank in random order');
  String get hubHard => p('Difficili', 'Hard');
  String get hubDaily => p('Sfida', 'Daily');
  String get hubBookmarks => p('Segnalibri', 'Bookmarks');
  String get hubQuick => p('Rapido', 'Quick');
  String get hubTimed => p('A tempo', 'Timed');
  String get hubWeak => p('Punti deboli', 'Weak spots');
  String get hubVocab => p('Vocabolario', 'Vocabulary');
  String get hubMini => p('Mini esame', 'Mini exam');
  String get hubStats => p('Progressi', 'Progress');
  String get dailyAvailable => p('Disponibile', 'Available');
  String get dailyDone => p('Completata', 'Done');
  String get hardSubtitle => p('Domande toste', 'Tough questions');
  String get signsSubtitle => p('Giochi interattivi', 'Interactive games');
  String get dailySubtitle => p('10 domande oggi', '10 questions today');
  String get hubBookmarksSub => p('Salvate offline', 'Saved offline');
  String get chaptersShort => p('Per argomento', 'By topic');
  String get quickSub => p('10 domande veloci', '10 quick questions');
  String get timedSub => p('15 sec a domanda', '15 sec per question');
  String get weakSub => p('Ripasso intelligente', 'Smart review');
  String get vocabSub => p('Parole chiave IT/EN', 'Key words IT/EN');
  String get miniSub => p('15 domande', '15 questions');
  String get statsSub => p('Andamento e storico', 'Trends & history');
  String get vocabTitle => p('Vocabolario stradale', 'Road vocabulary');
  String get vocabSubtitle =>
      p('Tocca la carta per mostrare la traduzione', 'Tap the card to show the translation');
  String get vocabTapHint => p('Tocca per girare', 'Tap to flip');
  String get vocabShuffle => p('Casuale', 'Shuffle');
  String get vocabEmpty => p('Nessun termine disponibile', 'No terms available');
  String get doneLabel => p('Fine', 'Done');
  String get allModes => p('Tutto il percorso', 'Full toolkit');

  String get comingSoonTitle => p('In preparazione', 'Coming soon');
  String comingSoonBody(String code) => p(
      'Il database ufficiale per la patente $code arriverà a breve.\n'
      'Nel frattempo Patente B è completamente disponibile offline.',
      'The official question bank for licence $code is on the way.\n'
      'Patente B is fully available offline in the meantime.');
  String get backToB => p('Torna a Patente B', 'Back to Patente B');
  String get playableNow => p('Disponibile ora', 'Available now');

  // ── Sign games ─────────────────────────────────────────────────────────────
  String get signGamesTitle => p('Giochi sui segnali', 'Sign games');
  String get guessSign => p('Indovina il segnale', 'Guess the sign');
  String get guessSignSub =>
      p('Guarda il cartello e scegli il nome corretto', 'Look at the sign and pick the right name');
  String get fourSigns => p('4 segnali 1 parola', '4 signs 1 word');
  String get fourSignsSub =>
      p('Trova il segnale che corrisponde alla parola', 'Find the sign that matches the word');
  String get whichSign => p('Quale segnale è?', 'Which sign is this?');
  String get pickMatchingSign =>
      p('Quale segnale corrisponde?', 'Which sign matches?');
  String get correctShort => p('Corretto!', 'Correct!');
  String get wrongShort => p('Sbagliato', 'Wrong');
  String get playAgain => p('Gioca ancora', 'Play again');
  String scoreLabel(int score, int total) =>
      p('Punteggio $score/$total', 'Score $score/$total');

  // ── Daily / hard / quick ───────────────────────────────────────────────────
  String get dailyChallengeTitle => p('Sfida del giorno', 'Daily challenge');
  String get hardQuizTitle => p('Quiz difficili', 'Hard quiz');
  String get quickQuizTitle => p('Quiz rapido', 'Quick quiz');
  String get dailyAlreadyDone =>
      p('Hai già completato la sfida di oggi. Torna domani!',
          'You already finished today’s challenge. Come back tomorrow!');

  // ── Exam history / readable font ───────────────────────────────────────────
  String get examHistory => p('Storico esami', 'Exam history');
  String get noExamsYet =>
      p('Nessuna simulazione ancora. Prova un esame ufficiale.',
          'No mock exams yet. Try an official simulation.');
  String get examPassedShort => p('Superato', 'Passed');
  String get examFailedShort => p('Non superato', 'Failed');
  String examHistoryLine(int correct, int wrong) =>
      p('$correct corrette · $wrong errori', '$correct correct · $wrong wrong');
  String get readableFont => p('Lettura facilitata', 'Readable text');
  String get readableFontSub => p(
      'Spaziatura più ampia per una lettura più chiara',
      'Wider spacing for clearer reading');
}
