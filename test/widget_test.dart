import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patente_b/data/fast_track_access.dart';
import 'package:patente_b/data/local_store.dart';
import 'package:patente_b/l10n/app_lang.dart';
import 'package:patente_b/l10n/strings.dart';
import 'package:patente_b/models/license_category.dart';
import 'package:patente_b/models/models.dart';

void main() {
  test('bundled seed contains all chapters, questions and vocabulary', () {
    final file = File('assets/data/seed.json');
    expect(file.existsSync(), isTrue);

    final seed = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final chapters = seed['chapters'] as List;
    final questions = seed['questions'] as List;
    final vocabulary = seed['vocabulary'] as List;

    expect(chapters.length, 25);
    expect(questions.length, greaterThan(5000));
    expect(vocabulary.length, greaterThanOrEqualTo(25));

    for (final q in questions.take(200)) {
      final map = q as Map<String, dynamic>;
      expect((map['it'] as String).isNotEmpty, isTrue);
      expect((map['en'] as String).isNotEmpty, isTrue);
      expect(map['a'], anyOf(0, 1));
    }
  });

  test('chapter progress and accuracy are derived safely', () {
    const empty = Chapter(id: 1, nameIt: 'Test', nameEn: 'Test');
    expect(empty.progress, 0);
    expect(empty.accuracy, 0);
    expect(empty.difficulty, Difficulty.hard);

    const partial = Chapter(
      id: 2,
      nameIt: 'Segnali',
      nameEn: 'Signs',
      totalQuestions: 100,
      seen: 40,
      correct: 34,
    );
    expect(partial.progress, closeTo(0.4, 0.0001));
    expect(partial.accuracy, closeTo(0.85, 0.0001));
    expect(partial.difficulty, Difficulty.easy);
  });

  test('quiz explanations always expose the correct answer', () {
    const q = QuizQuestion(
      id: 'x',
      chapterId: 2,
      textIt: 'Il segnale indica un dosso.',
      textEn: 'The sign indicates a bump.',
      correctIsTrue: true,
    );
    expect(q.explanationIt, contains('VERO'));
    expect(q.hintIt, isNotEmpty);
  });

  group('Fast Track gate', () {
    test('accepts the correct credential pair', () {
      expect(
        FastTrackAccess.verify(username: 'JAMSHAID', password: 'ARIF'),
        isTrue,
      );
    });

    test('username is case-insensitive and trimmed', () {
      expect(
        FastTrackAccess.verify(username: '  Jamshaid  ', password: 'ARIF'),
        isTrue,
      );
    });

    test('password stays case-sensitive', () {
      expect(
        FastTrackAccess.verify(username: 'JAMSHAID', password: 'arif'),
        isFalse,
      );
    });

    test('rejects wrong username, wrong password, blanks and truncations', () {
      const bad = <List<String>>[
        ['JAMSHAID', 'wrong'],
        ['admin', 'ARIF'],
        ['', 'ARIF'],
        ['JAMSHAID', ''],
        ['', ''],
        ['JAMSHAID', 'ARI'], // truncated
        ['JAMSHAID', 'ARIF '], // trailing space is not trimmed
        ['JAMSHAID', 'ARIFA'],
      ];
      for (final pair in bad) {
        expect(
          FastTrackAccess.verify(username: pair[0], password: pair[1]),
          isFalse,
          reason: 'should reject ${pair[0]} / ${pair[1]}',
        );
      }
    });
  });

  group('Localisation', () {
    const it = L10n(AppLang.it);
    const en = L10n(AppLang.en);

    test('language codes round-trip and fall back to Italian', () {
      expect(AppLang.fromCode('en'), AppLang.en);
      expect(AppLang.fromCode('it'), AppLang.it);
      expect(AppLang.fromCode(null), AppLang.it);
      expect(AppLang.fromCode('fr'), AppLang.it);
    });

    test('every exposed label differs between the two languages', () {
      expect(it.navSettings, 'Impostazioni');
      expect(en.navSettings, 'Settings');
      expect(it.quizTitle, 'Quiz');
      expect(en.quizTitle, 'Quiz');
      expect(it.trueLabel, 'VERO');
      expect(en.trueLabel, 'TRUE');
      expect(it.hint, isNot(en.hint));
      expect(it.noMistakes, isNot(en.noMistakes));
    });

    test('parameterised strings interpolate exactly once', () {
      expect(it.questionsCount(42), '42 domande');
      expect(en.questionsCount(42), '42 questions');
      expect(it.correctWrongPct(18, 2, 90), contains('18'));
      expect(en.examResult(27, 3, 30, 30), contains('30/30'));
      expect(it.percentComplete(55), '55% completato');
      expect(en.spacedRepetition(3), contains('3 days'));
    });

    test('content helpers flip the primary language', () {
      const chapter = Chapter(id: 7, nameIt: 'Segnali di pericolo', nameEn: 'Danger signs');
      expect(it.chapterName(chapter), 'Segnali di pericolo');
      expect(en.chapterName(chapter), 'Danger signs');
      expect(it.secondaryChapterName(chapter), 'Danger signs');
      expect(en.secondaryChapterName(chapter), 'Segnali di pericolo');

      const q = QuizQuestion(
        id: 'q1',
        chapterId: 7,
        textIt: 'Il segnale indica un dosso.',
        textEn: 'The sign indicates a bump.',
        correctIsTrue: true,
      );
      expect(it.questionText(q), q.textIt);
      expect(en.questionText(q), q.textEn);
      expect(en.questionTextSecondary(q), q.textIt);
    });
  });

  group('License hub', () {
    test('only B is playable and codes round-trip', () {
      expect(LicenseCategory.b.isPlayable, isTrue);
      expect(LicenseCategory.c.isPlayable, isFalse);
      expect(LicenseCategory.cqc.isPlayable, isFalse);
      expect(LicenseCategory.fromCode('C'), LicenseCategory.c);
      expect(LicenseCategory.fromCode('CQC'), LicenseCategory.cqc);
      expect(LicenseCategory.fromCode(null), LicenseCategory.b);
      expect(LicenseCategory.fromCode('ZZ'), LicenseCategory.b);
    });

    test('daily challenge meta key is calendar-day scoped', () {
      final key = LocalStore.dailyChallengeKeyFor(DateTime(2026, 11, 27));
      expect(key, 'daily_challenge_2026-11-27');
      expect(
        LocalStore.dailyChallengeKeyFor(DateTime(2026, 11, 28)),
        isNot(key),
      );
    });

    test('hub copy exists in both languages', () {
      const it = L10n(AppLang.it);
      const en = L10n(AppLang.en);
      expect(it.guessSign, isNot(en.guessSign));
      expect(it.fourSigns, isNot(en.fourSigns));
      expect(it.comingSoonTitle, isNot(en.comingSoonTitle));
      expect(it.examHistory, isNot(en.examHistory));
      expect(it.readableFont, isNot(en.readableFont));
      expect(it.hubVocab, isNot(en.hubVocab));
      expect(it.hubWeak, isNot(en.hubWeak));
      expect(it.hubMini, isNot(en.hubMini));
      expect(it.practiceSection, isNot(en.practiceSection));
      expect(it.ftPassHeadline, contains('100'));
      expect(en.ftPassHeadline, contains('100'));
      expect(it.ftAdminOnly, isNot(en.ftAdminOnly));
      expect(it.ftStep1Title, isNot(en.ftStep1Title));
      expect(it.ftLearnedNext, isNot(en.ftLearnedNext));
      expect(it.ftRulesTestTitle, isNot(en.ftRulesTestTitle));
    });
  });
}
