import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../models/translation_mode.dart';
import '../theme/app_colors.dart';
import '../theme/exam_tokens.dart';
import '../utils/app_haptics.dart';
import '../widgets/bilingual_statement.dart';
import '../widgets/official_exam_ui.dart';
import '../widgets/premium_scaffold.dart';
import '../widgets/question_image.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    this.title,
    this.chapterId,
    this.questions,
    this.mistakeMode = false,
    this.bookmarkMode = false,
    this.hardMode = false,
    this.quickMode = false,
    this.dailyMode = false,
    this.weakMode = false,
    this.secondsPerQuestion = 30,
    this.limit,
  });

  final String? title;
  final int? chapterId;
  final List<QuizQuestion>? questions;
  final bool mistakeMode;
  final bool bookmarkMode;
  final bool hardMode;
  final bool quickMode;
  final bool dailyMode;
  final bool weakMode;
  final int secondsPerQuestion;
  final int? limit;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Future<List<QuizQuestion>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<QuizQuestion>> _load() async {
    if (widget.questions != null) return widget.questions!;
    final state = context.read<AppState>();
    if (widget.mistakeMode) return state.loadMistakeQuiz();
    if (widget.bookmarkMode) return state.loadBookmarks();
    if (widget.hardMode) return state.loadHardQuiz(limit: widget.limit ?? 20);
    if (widget.weakMode) return state.loadHardQuiz(limit: widget.limit ?? 20);
    if (widget.quickMode) return state.loadQuickQuiz(limit: widget.limit ?? 10);
    if (widget.dailyMode) return state.loadDailyChallenge(limit: widget.limit ?? 10);
    return state.loadQuiz(limit: widget.limit ?? 20, chapterId: widget.chapterId);
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return FutureBuilder<List<QuizQuestion>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return PremiumScaffold(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: l.back,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
                const Spacer(),
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.neon,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l.loadingLocalDb,
                  style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.9)),
                ),
                const Spacer(),
              ],
            ),
          );
        }
        final questions = snap.data ?? const <QuizQuestion>[];
        if (questions.isEmpty) {
          return PremiumScaffold(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: l.back,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.inbox_rounded, size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 14),
                  Text(
                    widget.bookmarkMode ? l.noBookmarks : l.noQuestionsAvailable,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.bookmarkMode ? l.bookmarkHint : l.mistakeHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 180,
                    child: NeonButton(
                      label: l.back,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        }
        return _QuizSession(
          title: widget.title ?? l.quizTitle,
          questions: questions,
          mistakeMode: widget.mistakeMode,
          dailyMode: widget.dailyMode,
          secondsPerQuestion: widget.secondsPerQuestion,
        );
      },
    );
  }
}

class _QuizSession extends StatefulWidget {
  const _QuizSession({
    required this.title,
    required this.questions,
    required this.mistakeMode,
    this.dailyMode = false,
    this.secondsPerQuestion = 30,
  });

  final String title;
  final List<QuizQuestion> questions;
  final bool mistakeMode;
  final bool dailyMode;
  final int secondsPerQuestion;

  @override
  State<_QuizSession> createState() => _QuizSessionState();
}

class _QuizSessionState extends State<_QuizSession> {
  int _index = 0;
  int _correct = 0;
  int _wrong = 0;
  bool? _answeredTrue;
  bool _showHint = false;
  late bool _bookmarked;
  int _seconds = 30;
  Timer? _timer;
  late TranslationMode _translationMode;

  List<QuizQuestion> get _questions => widget.questions;
  QuizQuestion get _q => _questions[_index];

  @override
  void initState() {
    super.initState();
    _bookmarked = false;
    _seconds = widget.secondsPerQuestion;
    _translationMode = context.read<AppState>().translationMode;
    _syncBookmark();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_answeredTrue != null) return;
      if (_seconds <= 0) {
        if (_answeredTrue == null) {
          _answer(_q.correctIsTrue, fromTimeout: true);
        }
        return;
      }
      setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _clock {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _syncBookmark() async {
    final saved = await context.read<AppState>().isBookmarked(_q.id);
    if (!mounted) return;
    setState(() => _bookmarked = saved);
  }

  Future<void> _answer(bool value, {bool fromTimeout = false}) async {
    if (_answeredTrue != null) return;
    if (!fromTimeout) AppHaptics.light(context);
    final ok = value == _q.correctIsTrue;
    setState(() {
      _answeredTrue = value;
      if (ok) {
        _correct++;
      } else {
        _wrong++;
      }
    });
    await context.read<AppState>().answer(_q, ok);
  }

  void _next() {
    if (_index >= _questions.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _answeredTrue = null;
      _showHint = false;
      _bookmarked = false;
      _seconds = widget.secondsPerQuestion;
    });
    _syncBookmark();
  }

  Future<void> _finish() async {
    _timer?.cancel();
    if (widget.dailyMode) {
      await context.read<AppState>().completeDailyChallenge();
    }
    if (!mounted) return;
    final l = L10n.read(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final total = _correct + _wrong;
        final pct = total == 0 ? 0 : (_correct / total * 100).round();
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.strokeStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),
              Icon(
                pct >= 80 ? Icons.emoji_events_rounded : Icons.insights_rounded,
                size: 52,
                color: pct >= 80 ? AppColors.gold : AppColors.electricSoft,
              ),
              const SizedBox(height: 12),
              Text(
                l.sessionComplete,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Text(
                l.correctWrongPct(_correct, _wrong, pct),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                l.progressSaved,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              NeonButton(
                label: l.close,
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final answered = _answeredTrue != null;
    final wasCorrect = answered && (_answeredTrue == _q.correctIsTrue);
    final chapter = _q.chapterName(l.isEn);

    return ExamShell(
      child: Column(
        children: [
          ExamMitHeader(
            title: widget.title,
            timerLabel: _clock,
            timerHot: _seconds <= 5 && !answered,
            onClose: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
              physics: const BouncingScrollPhysics(),
              children: [
                ExamBezel(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${l.scoreQuestion} ${_index + 1} / ${_questions.length}'.toUpperCase(),
                            style: ExamTokens.mitEyebrow,
                          ),
                          const Spacer(),
                          TranslationModeChip(
                            mode: _translationMode,
                            onChanged: (m) {
                              setState(() => _translationMode = m);
                              context.read<AppState>().setTranslationMode(m);
                            },
                          ),
                          IconButton(
                            tooltip: l.bookmarks,
                            onPressed: () async {
                              final state = context.read<AppState>();
                              final now = await state.isBookmarked(_q.id);
                              await state.toggleBookmark(_q.id);
                              if (!mounted) return;
                              setState(() => _bookmarked = !now);
                            },
                            icon: Icon(
                              _bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: _bookmarked ? ExamTokens.flag : ExamTokens.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      QuestionImage(
                        key: ValueKey('qi-${_q.id}'),
                        image: _q.image,
                        chapterId: _q.chapterId,
                        chapterLabel: chapter.isEmpty ? l.defaultSignLabel : chapter,
                        height: 168,
                      ),
                      const SizedBox(height: 14),
                      if (chapter.isNotEmpty)
                        Text(chapter.toUpperCase(), style: ExamTokens.chapter),
                      const SizedBox(height: 6),
                      BilingualStatement(
                        question: _q,
                        mode: _translationMode,
                        primaryStyle: ExamTokens.statement,
                      ),
                      const SizedBox(height: 22),
                      ExamCircleButtons(
                        selected: _answeredTrue,
                        result: answered ? _q.correctIsTrue : null,
                        enabled: !answered,
                        onTrue: () => _answer(true),
                        onFalse: () => _answer(false),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          l.isEn ? 'Tap V (True) or F (False)' : 'Tocca V (Vero) o F (Falso)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ExamTokens.muted,
                          ),
                        ),
                      ),
                      if (answered) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: wasCorrect ? ExamTokens.veroSoft : ExamTokens.falsoSoft,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: wasCorrect ? ExamTokens.vero : ExamTokens.falso,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wasCorrect ? l.correct : l.incorrect,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: wasCorrect ? ExamTokens.vero : ExamTokens.falso,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l.correctAnswer(_q.correctIsTrue),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: ExamTokens.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l.isEn ? _q.explanationEn : _q.explanationIt,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: ExamTokens.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _showHint = !_showHint),
                      icon: Icon(
                        Icons.lightbulb_outline_rounded,
                        color: _showHint ? ExamTokens.flag : ExamTokens.muted,
                      ),
                      label: Text(
                        l.hint,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _showHint ? ExamTokens.ink : ExamTokens.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showHint)
                  ExamBezel(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      l.isEn ? _q.hintEn : _q.hintIt,
                      style: const TextStyle(
                        color: ExamTokens.inkSoft,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: answered
                ? ExamNavBar(
                    canPrevious: false,
                    onPrevious: null,
                    previousLabel: l.back,
                    nextLabel: _index >= _questions.length - 1 ? l.seeResult : l.next,
                    onNext: _next,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
