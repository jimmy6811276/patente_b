import 'package:flutter/foundation.dart';

import '../l10n/app_lang.dart';
import '../models/license_category.dart';
import '../models/models.dart';
import 'fast_track_access.dart';
import 'local_store.dart';

/// Single source of truth for the offline app.
///
/// Everything (questions, vocabulary, progress, mistakes, exams, bookmarks)
/// lives in the on-device SQLite database. No network calls anywhere.
class AppState extends ChangeNotifier {
  AppState({LocalStore? store, this.userName = 'Studente'})
      : _store = store ?? LocalStore();

  final LocalStore _store;
  final String userName;

  bool _loading = true;
  String? _error;
  List<Chapter> _chapters = const [];
  List<VocabularyItem> _vocabulary = const [];
  List<MistakeItem> _mistakes = const [];
  AppStats _stats = const AppStats();
  Map<String, bool> _fastTrack = const <String, bool>{};
  bool _fastTrackUnlocked = false;
  bool _offlineReady = false;
  AppLang _lang = AppLang.it;
  bool _langChosen = false;
  LicenseCategory _selectedLicense = LicenseCategory.b;
  bool _readableFont = false;
  bool _dailyChallengeDone = false;
  List<ExamRecord> _examHistory = const [];
  int _ftMaxSlide = 0;
  bool _ftMasteryPassed = false;
  int _ftMasteryScore = 0;

  bool get loading => _loading;
  String? get error => _error;
  List<Chapter> get chapters => _chapters;
  List<VocabularyItem> get vocabulary => _vocabulary;
  List<MistakeItem> get mistakes => _mistakes;
  AppStats get stats => _stats;
  Map<String, bool> get fastTrackDone => _fastTrack;
  bool get fastTrackUnlocked => _fastTrackUnlocked;
  bool get offlineReady => _offlineReady;
  AppLang get lang => _lang;
  bool get langChosen => _langChosen;
  LicenseCategory get selectedLicense => _selectedLicense;
  bool get readableFont => _readableFont;
  bool get dailyChallengeDone => _dailyChallengeDone;
  List<ExamRecord> get examHistory => _examHistory;
  int get ftMaxSlide => _ftMaxSlide;
  bool get ftMasteryPassed => _ftMasteryPassed;
  int get ftMasteryScore => _ftMasteryScore;
  LocalStore get store => _store;

  Future<void> init() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _store.open();
      _offlineReady = true;
      await refresh();
    } catch (e, st) {
      _error = e.toString();
      debugPrint('DB init failed: $e\n$st');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _chapters = await _store.getChapters();
    _vocabulary = await _store.getVocabulary();
    _mistakes = await _store.getMistakes();
    _stats = await _store.getStats();
    _fastTrack = await _store.getFastTrackState();
    _fastTrackUnlocked = await _store.isFastTrackUnlocked();
    _lang = AppLang.fromCode(await _store.getLanguageCode());
    _langChosen = await _store.hasChosenLanguage();
    _selectedLicense =
        LicenseCategory.fromCode(await _store.getSelectedLicenseCode());
    _readableFont = await _store.isReadableFont();
    _dailyChallengeDone = await _store.isDailyChallengeDone();
    _examHistory = await _store.getExamHistory();
    _ftMaxSlide = await _store.getFtMaxSlide();
    _ftMasteryPassed = await _store.isFtMasteryPassed();
    _ftMasteryScore = await _store.getFtMasteryScore();
    notifyListeners();
  }

  Future<void> markFtSlideReached(int index) async {
    await _store.setFtMaxSlide(index);
    if (index > _ftMaxSlide) {
      _ftMaxSlide = index;
      notifyListeners();
    }
  }

  Future<void> setFtMasteryResult({required bool passed, required int scorePct}) async {
    await _store.setFtMasteryPassed(passed: passed, scorePct: scorePct);
    _ftMasteryPassed = passed;
    _ftMasteryScore = scorePct;
    notifyListeners();
  }

  /// Chooses the interface language and remembers that the first-run
  /// picker has been answered, so it never interrupts again.
  Future<void> setLanguage(AppLang lang) async {
    _lang = lang;
    _langChosen = true;
    notifyListeners();
    await _store.setLanguageCode(lang.code);
  }

  Future<void> setSelectedLicense(LicenseCategory license) async {
    _selectedLicense = license;
    notifyListeners();
    await _store.setSelectedLicenseCode(license.code);
  }

  Future<void> setReadableFont(bool enabled) async {
    _readableFont = enabled;
    notifyListeners();
    await _store.setReadableFont(enabled);
  }

  Future<void> completeDailyChallenge() async {
    await _store.markDailyChallengeDone();
    _dailyChallengeDone = true;
    notifyListeners();
  }

  /// Returns false when the username/password pair does not match.
  Future<bool> unlockFastTrack({
    required String username,
    required String password,
  }) async {
    if (!FastTrackAccess.verify(username: username, password: password)) {
      return false;
    }
    await _store.setFastTrackUnlocked(true);
    _fastTrackUnlocked = true;
    notifyListeners();
    return true;
  }

  Future<void> lockFastTrack() async {
    await _store.setFastTrackUnlocked(false);
    _fastTrackUnlocked = false;
    notifyListeners();
  }

  Future<void> setFastTrackTask(String id, bool done) async {
    _fastTrack = {..._fastTrack, id: done};
    notifyListeners();
    await _store.setFastTrackTask(id, done);
  }

  Future<List<QuizQuestion>> loadQuiz({
    int limit = 30,
    int? chapterId,
  }) {
    return _store.randomQuestions(limit: limit, chapterId: chapterId);
  }

  Future<List<QuizQuestion>> loadHardQuiz({int limit = 20}) =>
      _store.hardQuestions(limit: limit);

  Future<List<QuizQuestion>> loadQuickQuiz({int limit = 10}) =>
      _store.randomQuestions(limit: limit);

  Future<List<QuizQuestion>> loadDailyChallenge({int limit = 10}) =>
      _store.randomQuestions(limit: limit);

  Future<List<QuizQuestion>> loadExam() => _store.randomQuestions(limit: 30);

  Future<List<QuizQuestion>> loadBookmarks() => _store.bookmarkQuestions();

  Future<List<QuizQuestion>> loadMistakeQuiz() async {
    if (_mistakes.isEmpty) return const [];
    return _mistakes.take(20).map((m) => m.question).toList();
  }

  Future<void> answer(QuizQuestion question, bool correct) async {
    await _store.recordAnswer(question: question, correct: correct);
    await refresh();
  }

  Future<void> finishExam({
    required int total,
    required int correct,
    required int wrong,
  }) async {
    await _store.recordExam(total: total, correct: correct, wrong: wrong);
    await refresh();
  }

  Future<void> resetProgress() async {
    await _store.resetProgress();
    await refresh();
  }

  Future<bool> isBookmarked(String questionId) => _store.isBookmarked(questionId);

  Future<void> toggleBookmark(String questionId) async {
    await _store.toggleBookmark(questionId);
    notifyListeners();
  }

  Chapter? chapterById(int id) {
    for (final c in _chapters) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<WeakTopic> get weakTopics {
    final withData = _chapters.where((c) => c.seen >= 3).toList()
      ..sort((a, b) => a.accuracy.compareTo(b.accuracy));
    return withData
        .take(5)
        .map(
          (c) => WeakTopic(
            nameIt: c.nameIt,
            nameEn: c.nameEn,
            accuracy: c.accuracy,
            seen: c.seen,
          ),
        )
        .toList();
  }

  int get totalQuestions =>
      _chapters.fold(0, (sum, c) => sum + c.totalQuestions);
}
