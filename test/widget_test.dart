import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patente_b/data/fast_track_access.dart';
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
}
