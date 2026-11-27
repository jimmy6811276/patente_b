import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

/// 100% on-device SQLite store. Seeded from a bundled asset — no network.
class LocalStore {
  LocalStore({Database? database}) : _injected = database;

  final Database? _injected;
  Database? _db;

  static const _dbName = 'patente_b.db';
  static const _seedAsset = 'assets/data/seed.json';
  static const _schemaVersion = 1;

  Database get db {
    final database = _db ?? _injected;
    if (database == null) {
      throw StateError('LocalStore non inizializzato. Chiama open() prima.');
    }
    return database;
  }

  Future<void> open() async {
    if (_db != null) return;
    if (_injected != null) {
      _db = _injected;
      await _createTables(_injected);
      await _seedIfEmpty(_injected);
      return;
    }
    final path = p.join(await getDatabasesPath(), _dbName);
    _db = await openDatabase(
      path,
      version: _schemaVersion,
      onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: (d, version) async {
        await _createTables(d);
      },
    );
    await _seedIfEmpty(_db!);
  }

  Future<void> _createTables(Database d) async {
    await d.execute('''
      CREATE TABLE IF NOT EXISTS meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await d.execute('''
      CREATE TABLE IF NOT EXISTS chapters (
        id INTEGER PRIMARY KEY,
        name_it TEXT NOT NULL,
        name_en TEXT NOT NULL
      )
    ''');
    await d.execute('''
      CREATE TABLE IF NOT EXISTS questions (
        id TEXT PRIMARY KEY,
        chapter_id INTEGER NOT NULL REFERENCES chapters(id),
        text_it TEXT NOT NULL,
        text_en TEXT NOT NULL,
        answer INTEGER NOT NULL,
        image TEXT,
        tags TEXT
      )
    ''');
    await d.execute('''
      CREATE TABLE IF NOT EXISTS vocabulary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        term_it TEXT NOT NULL,
        term_en TEXT NOT NULL,
        chapter_id INTEGER NOT NULL
      )
    ''');
    await d.execute('''
      CREATE TABLE IF NOT EXISTS attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id TEXT NOT NULL,
        chapter_id INTEGER NOT NULL,
        correct INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await d.execute('''
      CREATE TABLE IF NOT EXISTS chapter_progress (
        chapter_id INTEGER PRIMARY KEY,
        seen INTEGER NOT NULL DEFAULT 0,
        correct INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await d.execute('''
      CREATE TABLE IF NOT EXISTS exams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total INTEGER NOT NULL,
        correct INTEGER NOT NULL,
        wrong INTEGER NOT NULL,
        passed INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await d.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks (
        question_id TEXT PRIMARY KEY,
        created_at INTEGER NOT NULL
      )
    ''');
    await d.execute('CREATE INDEX IF NOT EXISTS idx_q_chapter ON questions(chapter_id)');
    await d.execute('CREATE INDEX IF NOT EXISTS idx_a_chapter ON attempts(chapter_id)');
    await d.execute('CREATE INDEX IF NOT EXISTS idx_a_created ON attempts(created_at)');
  }

  Future<void> _seedIfEmpty(Database d) async {
    final seeded = await d.query(
      'meta',
      where: 'key = ?',
      whereArgs: ['seed_version'],
      limit: 1,
    );
    if (seeded.isNotEmpty) return;

    final raw = await rootBundle.loadString(_seedAsset);
    final seed = jsonDecode(raw) as Map<String, dynamic>;
    final chapters = (seed['chapters'] as List).cast<Map<String, dynamic>>();
    final questions = (seed['questions'] as List).cast<Map<String, dynamic>>();
    final vocab = (seed['vocabulary'] as List).cast<Map<String, dynamic>>();

    await d.transaction((txn) async {
      final batch = txn.batch();
      for (final c in chapters) {
        batch.insert('chapters', {
          'id': c['id'],
          'name_it': c['it'],
          'name_en': c['en'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final q in questions) {
        batch.insert('questions', {
          'id': q['id'],
          'chapter_id': q['c'],
          'text_it': q['it'],
          'text_en': q['en'],
          'answer': q['a'],
          'image': q['img'],
          'tags': (q['tags'] as List?)?.join(',') ?? '',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final v in vocab) {
        batch.insert('vocabulary', {
          'term_it': v['it'],
          'term_en': v['en'],
          'chapter_id': v['chapter'],
        });
      }
      await batch.commit(noResult: true);
      await txn.insert('meta', {
        'key': 'seed_version',
        'value': '${seed['version'] ?? 1}',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('meta', {
        'key': 'seeded_at',
        'value': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<List<Chapter>> getChapters() async {
    final rows = await db.rawQuery('''
      SELECT c.id, c.name_it, c.name_en,
             COUNT(q.id) AS total,
             COALESCE(cp.seen, 0) AS seen,
             COALESCE(cp.correct, 0) AS correct
      FROM chapters c
      LEFT JOIN questions q ON q.chapter_id = c.id
      LEFT JOIN chapter_progress cp ON cp.chapter_id = c.id
      GROUP BY c.id
      ORDER BY c.id
    ''');
    return rows
        .map(
          (r) => Chapter(
            id: r['id'] as int,
            nameIt: r['name_it'] as String,
            nameEn: r['name_en'] as String,
            totalQuestions: (r['total'] as int?) ?? 0,
            seen: (r['seen'] as int?) ?? 0,
            correct: (r['correct'] as int?) ?? 0,
          ),
        )
        .toList();
  }

  Future<List<QuizQuestion>> randomQuestions({
    int limit = 30,
    int? chapterId,
  }) async {
    final rows = await db.rawQuery(
      '''
      SELECT q.*, c.name_it, c.name_en FROM questions q
      JOIN chapters c ON c.id = q.chapter_id
      ${chapterId != null ? 'WHERE q.chapter_id = ?' : ''}
      ORDER BY RANDOM() LIMIT ?
      ''',
      [...?chapterId != null ? [chapterId] : null, limit],
    );
    return rows.map(_mapQuestion).toList();
  }

  Future<List<QuizQuestion>> questionsForChapter(int chapterId, {int limit = 40}) =>
      randomQuestions(limit: limit, chapterId: chapterId);

  Future<QuizQuestion?> questionById(String id) async {
    final rows = await db.rawQuery(
      'SELECT q.*, c.name_it, c.name_en FROM questions q JOIN chapters c ON c.id = q.chapter_id WHERE q.id = ? LIMIT 1',
      [id],
    );
    return rows.isEmpty ? null : _mapQuestion(rows.first);
  }

  Future<List<QuizQuestion>> bookmarkQuestions() async {
    final rows = await db.rawQuery('''
      SELECT q.*, c.name_it, c.name_en FROM questions q
      JOIN chapters c ON c.id = q.chapter_id
      JOIN bookmarks b ON b.question_id = q.id
      ORDER BY b.created_at DESC
      LIMIT 100
    ''');
    return rows.map(_mapQuestion).toList();
  }

  QuizQuestion _mapQuestion(Map<String, Object?> r) => QuizQuestion(
        id: r['id'] as String,
        chapterId: r['chapter_id'] as int,
        textIt: r['text_it'] as String,
        textEn: r['text_en'] as String,
        correctIsTrue: (r['answer'] as int) == 1,
        image: r['image'] as String?,
        tags: ((r['tags'] as String?) ?? '')
            .split(',')
            .where((t) => t.isNotEmpty)
            .toList(),
        chapterNameIt: (r['name_it'] as String?) ?? '',
        chapterNameEn: (r['name_en'] as String?) ?? '',
      );

  Future<void> recordAnswer({
    required QuizQuestion question,
    required bool correct,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      await txn.insert('attempts', {
        'question_id': question.id,
        'chapter_id': question.chapterId,
        'correct': correct ? 1 : 0,
        'created_at': now,
      });
      await txn.rawInsert('''
        INSERT INTO chapter_progress(chapter_id, seen, correct)
        VALUES(?, 1, ?)
        ON CONFLICT(chapter_id) DO UPDATE SET
          seen = seen + 1,
          correct = correct + excluded.correct
      ''', [question.chapterId, correct ? 1 : 0]);
    });
  }

  Future<void> recordExam({
    required int total,
    required int correct,
    required int wrong,
  }) async {
    await db.insert('exams', {
      'total': total,
      'correct': correct,
      'wrong': wrong,
      'passed': wrong <= 3 ? 1 : 0,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> toggleBookmark(String questionId) async {
    final existing = await db.query(
      'bookmarks',
      where: 'question_id = ?',
      whereArgs: [questionId],
      limit: 1,
    );
    if (existing.isEmpty) {
      await db.insert('bookmarks', {
        'question_id': questionId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await db.delete('bookmarks', where: 'question_id = ?', whereArgs: [questionId]);
    }
  }

  Future<bool> isBookmarked(String questionId) async {
    final rows = await db.query(
      'bookmarks',
      where: 'question_id = ?',
      whereArgs: [questionId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<List<VocabularyItem>> getVocabulary() async {
    final rows = await db.query('vocabulary', orderBy: 'id');
    return rows
        .map(
          (r) => VocabularyItem(
            termIt: r['term_it'] as String,
            termEn: r['term_en'] as String,
            chapterId: r['chapter_id'] as int,
          ),
        )
        .toList();
  }

  Future<List<MistakeItem>> getMistakes({int limit = 60}) async {
    final rows = await db.rawQuery('''
      SELECT q.*, c.name_it, c.name_en,
             SUM(CASE WHEN a.correct = 0 THEN 1 ELSE 0 END) AS wrong_count,
             MAX(CASE WHEN a.correct = 0 THEN a.created_at ELSE 0 END) AS last_wrong
      FROM attempts a
      JOIN questions q ON q.id = a.question_id
      JOIN chapters c ON c.id = q.chapter_id
      GROUP BY q.id
      HAVING wrong_count > 0
      ORDER BY wrong_count DESC, last_wrong DESC
      LIMIT ?
    ''', [limit]);
    return rows
        .map(
          (r) => MistakeItem(
            question: _mapQuestion(r),
            wrongCount: (r['wrong_count'] as int?) ?? 0,
            lastWrongAt: DateTime.fromMillisecondsSinceEpoch(
              (r['last_wrong'] as int?) ?? 0,
            ),
          ),
        )
        .toList();
  }

  Future<AppStats> getStats() async {
    final totals = await db.rawQuery('''
      SELECT COUNT(*) AS total,
             COALESCE(SUM(correct), 0) AS correct
      FROM attempts
    ''');
    final total = (totals.first['total'] as int?) ?? 0;
    final correct = (totals.first['correct'] as int?) ?? 0;

    final examRows = await db.rawQuery('''
      SELECT COUNT(*) AS attempts, COALESCE(SUM(passed),0) AS passes
      FROM exams
    ''');
    final examAttempts = (examRows.first['attempts'] as int?) ?? 0;
    final examPasses = (examRows.first['passes'] as int?) ?? 0;

    final coverageRows = await db.rawQuery(
      'SELECT COUNT(*) AS covered FROM chapter_progress WHERE seen > 0',
    );
    final covered = (coverageRows.first['covered'] as int?) ?? 0;

    final dayRows = await db.rawQuery('''
      SELECT DISTINCT date(created_at / 1000, 'unixepoch', 'localtime') AS day
      FROM attempts ORDER BY day DESC LIMIT 60
    ''');
    final days = dayRows.map((r) => r['day'] as String).toList();
    final streak = _computeStreak(days);

    final week = <double>[];
    final now = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final start = day.millisecondsSinceEpoch;
      final end = start + const Duration(days: 1).inMilliseconds;
      final rows = await db.rawQuery(
        'SELECT COUNT(*) AS total, COALESCE(SUM(correct),0) AS correct FROM attempts WHERE created_at >= ? AND created_at < ?',
        [start, end],
      );
      final t = (rows.first['total'] as int?) ?? 0;
      final c = (rows.first['correct'] as int?) ?? 0;
      week.add(t == 0 ? 0 : c / t);
    }

    const chapterCount = 25;
    var readiness = 0.0;
    if (total > 0) {
      final accuracy = correct / total;
      final coverage = (covered / chapterCount).clamp(0.0, 1.0);
      final examScore = examAttempts == 0
          ? (accuracy * 0.8)
          : (examPasses / examAttempts);
      readiness =
          (accuracy * 0.45 + coverage * 0.25 + examScore * 0.30).clamp(0.0, 1.0);
      // Small-sample damping so 2 answers don't show 95% ready.
      readiness *= min(1.0, 0.35 + total / 300);
    }

    return AppStats(
      readiness: readiness,
      accuracy: total == 0 ? 0 : correct / total,
      streak: streak,
      totalAnswers: total,
      correctAnswers: correct,
      examAttempts: examAttempts,
      examPasses: examPasses,
      weekAccuracy: week,
    );
  }

  int _computeStreak(List<String> daysDesc) {
    if (daysDesc.isEmpty) return 0;
    var streak = 0;
    var cursor = DateTime.now();
    final today = '${cursor.year.toString().padLeft(4, '0')}-'
        '${cursor.month.toString().padLeft(2, '0')}-'
        '${cursor.day.toString().padLeft(2, '0')}';
    var expect = today;
    for (final day in daysDesc) {
      if (day == expect) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
        expect = '${cursor.year.toString().padLeft(4, '0')}-'
            '${cursor.month.toString().padLeft(2, '0')}-'
            '${cursor.day.toString().padLeft(2, '0')}';
      } else if (streak == 0 && day == _yesterday(today)) {
        streak = 1;
        cursor = cursor.subtract(const Duration(days: 2));
        expect = '${cursor.year.toString().padLeft(4, '0')}-'
            '${cursor.month.toString().padLeft(2, '0')}-'
            '${cursor.day.toString().padLeft(2, '0')}';
      } else if (day.compareTo(expect) < 0) {
        break;
      }
    }
    return streak;
  }

  String _yesterday(String today) {
    final parts = today.split('-').map(int.parse).toList();
    final d = DateTime(parts[0], parts[1], parts[2]).subtract(const Duration(days: 1));
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, bool>> getFastTrackState() async {
    final rows = await db.query('meta', where: "key LIKE 'fasttrack_%'");
    return {
      for (final r in rows)
        (r['key'] as String).substring('fasttrack_'.length): r['value'] == '1',
    };
  }

  Future<void> setFastTrackTask(String id, bool done) async {
    await db.insert(
      'meta',
      {'key': 'fasttrack_$id', 'value': done ? '1' : '0'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Key deliberately does NOT start with `fasttrack_`, so it is never picked
  /// up by [getFastTrackState] and is not cleared by [resetProgress].
  static const _unlockKey = 'access_fasttrack_unlocked';

  Future<bool> isFastTrackUnlocked() async {
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: [_unlockKey],
      limit: 1,
    );
    return rows.isNotEmpty && rows.first['value'] == '1';
  }

  Future<void> setFastTrackUnlocked(bool unlocked) async {
    if (!unlocked) {
      await db.delete('meta', where: 'key = ?', whereArgs: [_unlockKey]);
      return;
    }
    await db.insert(
      'meta',
      {'key': _unlockKey, 'value': '1'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Guided Fast Track curriculum progress (not cleared with unlock).
  static const _ftSlideKey = 'ft_guided_max_slide';
  static const _ftMasteryKey = 'ft_rules_mastery_passed';
  static const _ftMasteryScoreKey = 'ft_rules_mastery_score';

  Future<int> getFtMaxSlide() async {
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: [_ftSlideKey],
      limit: 1,
    );
    if (rows.isEmpty) return 0;
    return int.tryParse(rows.first['value'] as String? ?? '0') ?? 0;
  }

  Future<void> setFtMaxSlide(int index) async {
    final current = await getFtMaxSlide();
    if (index <= current) return;
    await db.insert(
      'meta',
      {'key': _ftSlideKey, 'value': '$index'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isFtMasteryPassed() async {
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: [_ftMasteryKey],
      limit: 1,
    );
    return rows.isNotEmpty && rows.first['value'] == '1';
  }

  Future<int> getFtMasteryScore() async {
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: [_ftMasteryScoreKey],
      limit: 1,
    );
    if (rows.isEmpty) return 0;
    return int.tryParse(rows.first['value'] as String? ?? '0') ?? 0;
  }

  Future<void> setFtMasteryPassed({required bool passed, required int scorePct}) async {
    await db.insert(
      'meta',
      {'key': _ftMasteryKey, 'value': passed ? '1' : '0'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'meta',
      {'key': _ftMasteryScoreKey, 'value': '$scorePct'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static const _langKey = 'app_language';
  static const _langChosenKey = 'app_language_chosen';

  Future<String?> getLanguageCode() async {
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: [_langKey],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<bool> hasChosenLanguage() async {
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: [_langChosenKey],
      limit: 1,
    );
    return rows.isNotEmpty && rows.first['value'] == '1';
  }

  Future<void> setLanguageCode(String code) async {
    await db.insert(
      'meta',
      {'key': _langKey, 'value': code},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'meta',
      {'key': _langChosenKey, 'value': '1'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static const _licenseKey = 'selected_license';
  static const _readableFontKey = 'readable_font';
  static const _hapticsKey = 'haptics_enabled';
  static const _translationModeKey = 'translation_mode';

  Future<String?> getSelectedLicenseCode() async {
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: [_licenseKey],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<void> setSelectedLicenseCode(String code) async {
    await db.insert(
      'meta',
      {'key': _licenseKey, 'value': code},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isReadableFont() async {
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: [_readableFontKey],
      limit: 1,
    );
    return rows.isNotEmpty && rows.first['value'] == '1';
  }

  Future<void> setReadableFont(bool enabled) async {
    await db.insert(
      'meta',
      {'key': _readableFontKey, 'value': enabled ? '1' : '0'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isHapticsEnabled() async {
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: [_hapticsKey],
      limit: 1,
    );
    if (rows.isEmpty) return true;
    return rows.first['value'] == '1';
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    await db.insert(
      'meta',
      {'key': _hapticsKey, 'value': enabled ? '1' : '0'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> getTranslationMode() async {
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: [_translationModeKey],
      limit: 1,
    );
    if (rows.isEmpty) return 'sentence';
    return (rows.first['value'] as String?) ?? 'sentence';
  }

  Future<void> setTranslationMode(String mode) async {
    await db.insert(
      'meta',
      {'key': _translationModeKey, 'value': mode},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static String dailyChallengeKeyFor(DateTime day) {
    final y = day.year.toString().padLeft(4, '0');
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return 'daily_challenge_$y-$m-$d';
  }

  Future<bool> isDailyChallengeDone({DateTime? day}) async {
    final key = dailyChallengeKeyFor(day ?? DateTime.now());
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isNotEmpty && rows.first['value'] == '1';
  }

  Future<void> markDailyChallengeDone({DateTime? day}) async {
    final key = dailyChallengeKeyFor(day ?? DateTime.now());
    await db.insert(
      'meta',
      {'key': key, 'value': '1'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Prefer numeric / hard-tagged questions; fall back to random if the pool is thin.
  Future<List<QuizQuestion>> hardQuestions({int limit = 20}) async {
    final hard = await db.rawQuery(
      '''
      SELECT q.*, c.name_it, c.name_en FROM questions q
      JOIN chapters c ON c.id = q.chapter_id
      WHERE q.tags LIKE '%num%' OR q.tags LIKE '%hard%'
      ORDER BY RANDOM() LIMIT ?
      ''',
      [limit],
    );
    if (hard.length >= limit) return hard.map(_mapQuestion).toList();

    final weakChapterIds = await db.rawQuery('''
      SELECT chapter_id FROM chapter_progress
      WHERE seen >= 3
      ORDER BY CAST(correct AS REAL) / seen ASC
      LIMIT 5
    ''');
    if (weakChapterIds.isNotEmpty) {
      final ids = weakChapterIds.map((r) => r['chapter_id'] as int).toList();
      final placeholders = List.filled(ids.length, '?').join(',');
      final fromWeak = await db.rawQuery(
        '''
        SELECT q.*, c.name_it, c.name_en FROM questions q
        JOIN chapters c ON c.id = q.chapter_id
        WHERE q.chapter_id IN ($placeholders)
        ORDER BY RANDOM() LIMIT ?
        ''',
        [...ids, limit],
      );
      if (fromWeak.isNotEmpty) return fromWeak.map(_mapQuestion).toList();
    }

    return randomQuestions(limit: limit);
  }

  Future<List<ExamRecord>> getExamHistory({int limit = 20}) async {
    final rows = await db.query(
      'exams',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows
        .map(
          (r) => ExamRecord(
            id: r['id'] as int,
            total: r['total'] as int,
            correct: r['correct'] as int,
            wrong: r['wrong'] as int,
            passed: (r['passed'] as int) == 1,
            createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
          ),
        )
        .toList();
  }

  Future<void> resetProgress() async {
    await db.transaction((txn) async {
      await txn.delete('attempts');
      await txn.delete('chapter_progress');
      await txn.delete('exams');
      await txn.delete('bookmarks');
      await txn.delete('meta', where: "key LIKE 'fasttrack_%'");
    });
  }

  Future<int> totalQuestionCount() async {
    final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM questions');
    return (rows.first['c'] as int?) ?? 0;
  }

  Future<void> close() async {
    if (_injected == null) {
      await _db?.close();
    }
    _db = null;
  }

}
