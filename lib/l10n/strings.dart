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
  String get navStats => p('Statistiche', 'Stats');
  String get navChapters => p('Capitoli', 'Chapters');
  String get navSettings => p('Impostazioni', 'Settings');

  String get appTitle => p('Patente B', 'Patente B');

  // ── Readiness ──────────────────────────────────────────────────────────────
  String get readinessAlmost => p('Quasi pronto', 'Almost ready');
  String get readinessGood => p('Buon progresso', 'Good progress');
  String get readinessPreparing => p('In preparazione', 'Getting there');
  String get readinessStart => p('Inizia il percorso', 'Start your journey');

  String readinessLabel(AppStats s) {
    if (s.readiness >= 0.85) return readinessAlmost;
    if (s.readiness >= 0.6) return readinessGood;
    if (s.readiness > 0) return readinessPreparing;
    return readinessStart;
  }

  // ── Home ───────────────────────────────────────────────────────────────────
  String greeting(String name) => p('Ciao $name', 'Hi $name');
  String get homeSubtitle =>
      p('Il tuo coach intelligente per l\'esame', 'Your smart exam coach');
  String get offlineBadge => p('OFFLINE', 'OFFLINE');
  String get nextActionLabel =>
      p('Prossima azione consigliata', 'Suggested next step');
  String get reviewTopic => p('Rivedi', 'Review');
  String get startFirstQuiz => p('Inizia il primo quiz', 'Start your first quiz');
  String daysShort(int d) => p('$d gg', '${d}d');
  String get streakLabel => p('giorni streak', 'day streak');
  String get accuracyLabel => p('accuratezza', 'accuracy');
  String get fastTrackSubtitle => p('1–2 giorni turbo', '1–2 day sprint');
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
      'Le risposte sbagliate verranno raccolte qui automaticamente e ripassate con la spaced repetition.',
      'Wrong answers are collected here automatically and revisited with spaced repetition.');

  // ── Settings ───────────────────────────────────────────────────────────────
  String get settingsTitle => p('Impostazioni', 'Settings');
  String get languageTitle => p('Lingua', 'Language');
  String get languageSubtitle =>
      p('Interfaccia e contenuti', 'Interface and content');
  String get italian => p('Italiano', 'Italiano');
  String get englishLang => p('Inglese', 'English');
  String get translationEnglish =>
      p('Traduzione seconda lingua', 'Second-language translation');
  String get translationSubtitle => p(
      'Mostra l\'altra lingua sotto ogni domanda',
      'Show the other language under each question');
  String get haptics => p('Feedback aptico', 'Haptic feedback');
  String get hapticsSubtitle => p('Vibrazione su risposte', 'Vibrate on answers');
  String get offlineMode => p('Modalità offline', 'Offline mode');
  String get offlineSubtitle => p(
      'Contenuti sempre disponibili senza rete', 'Content always available without a network');
  String get audio => p('Audio pronuncia', 'Pronunciation audio');
  String get audioSubtitle => p('Lettura parole chiave', 'Read key words aloud');
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
  String get turboPlan => p('Piano Turbo', 'Turbo Plan');
  String get turboPlanSubtitle => p(
      'Zero italiano → pronto per l\'esame\nin 1–2 giorni intensivi',
      'Zero Italian → exam ready\nin 1–2 intensive days');
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
      'Questa sezione è privata.\nInserisci le credenziali fornite dall\'amministratore.',
      'This section is private.\nEnter the credentials provided by the administrator.');
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
  String get chooseLicense => p('Scegli la patente', 'Choose your licence');
  String get studyModes => p('Modalità di studio', 'Study modes');
  String get practiceSection => p('Pratica', 'Practice');
  String get examSection => p('Esame e ripasso', 'Exam & review');
  String get studySection => p('Studio', 'Study');
  String get toolsSection => p('Strumenti', 'Tools');
  String get hubChapters => p('Capitoli', 'Chapters');
  String get hubSigns => p('Segnali', 'Signs');
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
