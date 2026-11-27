enum Difficulty { easy, medium, hard }

class Chapter {
  const Chapter({
    required this.id,
    required this.nameIt,
    required this.nameEn,
    this.totalQuestions = 0,
    this.seen = 0,
    this.correct = 0,
  });

  final int id;
  final String nameIt;
  final String nameEn;
  final int totalQuestions;
  final int seen;
  final int correct;

  double get progress =>
      totalQuestions == 0 ? 0 : (seen / totalQuestions).clamp(0.0, 1.0);

  double get accuracy => seen == 0 ? 0 : (correct / seen).clamp(0.0, 1.0);

  bool get hasData => seen > 0;

  Difficulty get difficulty {
    if (!hasData) return Difficulty.hard;
    if (accuracy >= 0.85) return Difficulty.easy;
    if (accuracy >= 0.7) return Difficulty.medium;
    return Difficulty.hard;
  }

  Chapter copyWith({int? seen, int? correct}) => Chapter(
        id: id,
        nameIt: nameIt,
        nameEn: nameEn,
        totalQuestions: totalQuestions,
        seen: seen ?? this.seen,
        correct: correct ?? this.correct,
      );
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.chapterId,
    required this.textIt,
    required this.textEn,
    required this.correctIsTrue,
    this.image,
    this.tags = const [],
    this.chapterNameIt = '',
    this.chapterNameEn = '',
  });

  final String id;
  final int chapterId;
  final String textIt;
  final String textEn;
  final bool correctIsTrue;
  final String? image;
  final List<String> tags;
  final String chapterNameIt;
  final String chapterNameEn;

  String chapterName(bool english) =>
      english && chapterNameEn.isNotEmpty ? chapterNameEn : chapterNameIt;

  Difficulty get difficulty {
    if (tags.contains('num')) return Difficulty.hard;
    if (tags.contains('sign')) return Difficulty.easy;
    return Difficulty.medium;
  }

  String get explanationIt =>
      'Risposta corretta: ${correctIsTrue ? 'VERO' : 'FALSO'}. '
      '${textIt.isEmpty ? '' : 'Rileggi con attenzione le parole chiave del capitolo.'}';

  String get explanationEn =>
      'Correct answer: ${correctIsTrue ? 'TRUE' : 'FALSE'}. '
      'Pay attention to the key words in the Italian statement.';

  String get hintIt => tags.contains('num')
      ? 'Attenzione ai numeri: spesso la risposta cambia di poco.'
      : 'Individua la parola chiave italiana e confrontala con la traduzione.';

  String get hintEn => tags.contains('num')
      ? 'Watch the numbers: the answer often changes by very little.'
      : 'Find the key Italian word and compare it with the translation.';
}

class VocabularyItem {
  const VocabularyItem({
    required this.termIt,
    required this.termEn,
    required this.chapterId,
  });

  final String termIt;
  final String termEn;
  final int chapterId;
}

class FastTrackTask {
  const FastTrackTask({
    required this.id,
    required this.titleIt,
    required this.titleEn,
    required this.day,
    this.done = false,
    this.minutes = 15,
  });

  final String id;
  final String titleIt;
  final String titleEn;
  final int day;
  final bool done;
  final int minutes;

  FastTrackTask copyWith({bool? done}) => FastTrackTask(
        id: id,
        titleIt: titleIt,
        titleEn: titleEn,
        day: day,
        done: done ?? this.done,
        minutes: minutes,
      );
}

class WeakTopic {
  const WeakTopic({
    required this.chapterId,
    required this.nameIt,
    required this.nameEn,
    required this.accuracy,
    required this.seen,
  });

  final int chapterId;
  final String nameIt;
  final String nameEn;
  final double accuracy;
  final int seen;
}

class AppStats {
  const AppStats({
    this.readiness = 0,
    this.accuracy = 0,
    this.streak = 0,
    this.totalAnswers = 0,
    this.correctAnswers = 0,
    this.examAttempts = 0,
    this.examPasses = 0,
    this.weekAccuracy = const <double>[0, 0, 0, 0, 0, 0, 0],
  });

  final double readiness;
  final double accuracy;
  final int streak;
  final int totalAnswers;
  final int correctAnswers;
  final int examAttempts;
  final int examPasses;
  final List<double> weekAccuracy;

  int get estDaysLeft {
    if (readiness >= 0.85) return 1;
    if (readiness >= 0.6) return 3;
    if (readiness >= 0.35) return 7;
    return 14;
  }

  String get readinessLabel {
    if (readiness >= 0.85) return 'Quasi pronto';
    if (readiness >= 0.6) return 'Buon progresso';
    if (readiness > 0) return 'In preparazione';
    return 'Inizia il percorso';
  }
}

class MistakeItem {
  const MistakeItem({
    required this.question,
    required this.wrongCount,
    required this.lastWrongAt,
  });

  final QuizQuestion question;
  final int wrongCount;
  final DateTime lastWrongAt;
}

class ExamRecord {
  const ExamRecord({
    required this.id,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.passed,
    required this.createdAt,
  });

  final int id;
  final int total;
  final int correct;
  final int wrong;
  final bool passed;
  final DateTime createdAt;
}

/// One unique road-sign diagram for the Signs Atlas browser.
class SignAtlasItem {
  const SignAtlasItem({
    required this.image,
    required this.chapterId,
    required this.chapterNameIt,
    required this.chapterNameEn,
    required this.questionCount,
  });

  final String image;
  final int chapterId;
  final String chapterNameIt;
  final String chapterNameEn;
  final int questionCount;

  String chapterName(bool english) =>
      english && chapterNameEn.isNotEmpty ? chapterNameEn : chapterNameIt;
}
