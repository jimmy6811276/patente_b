import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../models/translation_mode.dart';
import '../theme/app_colors.dart';
import '../utils/app_haptics.dart';
import '../widgets/bilingual_statement.dart';
import '../widgets/exam_answer_buttons.dart';
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

    return PremiumScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gold.withValues(alpha: 0.2),
                        AppColors.orange.withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 15, color: AppColors.gold),
                      const SizedBox(width: 5),
                      Text(
                        _clock,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w900,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_index + 1}/${_questions.length}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (_index + 1) / _questions.length,
                minHeight: 5,
                backgroundColor: AppColors.navyElevated,
                color: AppColors.electric,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              physics: const BouncingScrollPhysics(),
              children: [
                QuestionImage(
                  key: ValueKey('qi-${_q.id}'),
                  image: _q.image,
                  chapterId: _q.chapterId,
                  chapterLabel: _q.chapterName(l.isEn).isEmpty
                      ? l.defaultSignLabel
                      : _q.chapterName(l.isEn),
                ),
                const SizedBox(height: 20),
                BilingualStatement(
                  question: _q,
                  mode: _translationMode,
                  primaryStyle: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                    letterSpacing: 0,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_q.tags.contains('sign')) l.tagSigns,
                    if (_q.tags.contains('num')) l.tagNumbers,
                    _q.chapterName(l.isEn).isEmpty
                        ? l.chapterShort(_q.chapterId)
                        : _q.chapterName(l.isEn),
                  ]
                      .map(
                        (k) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.electric.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.electric.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            k,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.electricSoft,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Tool(
                      icon: Icons.lightbulb_outline_rounded,
                      label: l.hint,
                      active: _showHint,
                      onTap: () => setState(() => _showHint = !_showHint),
                    ),
                    const SizedBox(width: 8),
                    TranslationModeChip(
                      mode: _translationMode,
                      onChanged: (m) {
                        setState(() => _translationMode = m);
                        context.read<AppState>().setTranslationMode(m);
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        final state = context.read<AppState>();
                        final now = await state.isBookmarked(_q.id);
                        await state.toggleBookmark(_q.id);
                        if (!mounted) return;
                        setState(() => _bookmarked = !now);
                      },
                      icon: Icon(
                        _bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: _bookmarked ? AppColors.gold : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                if (_showHint) ...[
                  const SizedBox(height: 8),
                  PremiumCard(
                    padding: const EdgeInsets.all(14),
                    borderColor: AppColors.gold.withValues(alpha: 0.35),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.tips_and_updates_rounded, color: AppColors.gold, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l.isEn ? _q.hintEn : _q.hintIt,
                            style: const TextStyle(color: AppColors.gold, fontSize: 13, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (answered) ...[
                  const SizedBox(height: 14),
                  PremiumCard(
                    borderColor: wasCorrect
                        ? AppColors.neon.withValues(alpha: 0.4)
                        : AppColors.red.withValues(alpha: 0.4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: wasCorrect ? AppColors.neonDim : AppColors.redDim,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wasCorrect ? l.correct : l.incorrect,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: wasCorrect ? AppColors.neonSoft : AppColors.redSoft,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.correctAnswer(_q.correctIsTrue),
                            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.isEn ? _q.explanationEn : _q.explanationIt,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          if (_translationMode != TranslationMode.off) ...[
                            const SizedBox(height: 6),
                            Text(
                              l.questionTextSecondary(_q),
                              style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: Column(
              children: [
                ExamAnswerButtons(
                  examMode: false,
                  selected: _answeredTrue,
                  result: answered ? _q.correctIsTrue : null,
                  enabled: !answered,
                  onTrue: () => _answer(true),
                  onFalse: () => _answer(false),
                ),
                if (answered) ...[
                  const SizedBox(height: 12),
                  NeonButton(
                    label: _index >= _questions.length - 1 ? l.seeResult : l.next,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _next,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? AppColors.electric.withValues(alpha: 0.16)
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? AppColors.electricSoft : AppColors.textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? AppColors.electricSoft : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
