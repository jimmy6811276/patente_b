import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/exam_tokens.dart';
import '../utils/app_haptics.dart';
import '../widgets/official_exam_ui.dart';
import '../widgets/premium_scaffold.dart';
import '../widgets/question_image.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<QuizQuestion>? _questions;
  final Map<int, bool> _answers = {};
  final Set<int> _marked = {};
  int _index = 0;
  int _seconds = 20 * 60;
  Timer? _timer;
  bool _started = false;
  bool _loading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    if (_loading || _started) return;
    setState(() => _loading = true);
    final questions = await context.read<AppState>().loadExam();
    if (!mounted) return;
    setState(() {
      _questions = questions;
      _started = true;
      _loading = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_seconds <= 0) {
        _submit();
        return;
      }
      setState(() => _seconds--);
    });
  }

  String get _clock {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  List<QuizQuestion> get _qs => _questions ?? const [];

  int get _correctCount => _answers.entries
      .where((e) => e.value == _qs[e.key].correctIsTrue)
      .length;

  void _pick(bool value) {
    AppHaptics.selection(context);
    setState(() => _answers[_index] = value);
  }

  int get _answeredCount => _answers.length;

  void _openQuestionMap() {
    final l = L10n.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.examNavTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _qs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (_, i) {
                  final answered = _answers.containsKey(i);
                  final flagged = _marked.contains(i);
                  final current = i == _index;
                  Color bg = AppColors.canvasDeep;
                  Color fg = AppColors.inkSoft;
                  Color border = AppColors.stroke;
                  if (current) {
                    bg = AppColors.blue.withValues(alpha: 0.16);
                    border = AppColors.blue;
                    fg = AppColors.blue;
                  } else if (flagged) {
                    bg = AppColors.amber.withValues(alpha: 0.16);
                    border = AppColors.amber;
                    fg = AppColors.amber;
                  } else if (answered) {
                    bg = AppColors.emerald.withValues(alpha: 0.14);
                    border = AppColors.emerald;
                    fg = AppColors.emerald;
                  }
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() => _index = i);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border, width: current ? 2 : 1),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(fontWeight: FontWeight.w800, color: fg),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_submitted) return;
    _submitted = true;
    _timer?.cancel();
    final l = L10n.read(context);
    final total = _qs.length;
    // Official rule: every question is scored. Unanswered questions count as errors.
    final correct = _correctCount;
    final wrong = total - correct;
    final passed = wrong <= 3;
    final answeredCount = _answers.length;
    await context.read<AppState>().finishExam(
          total: total,
          correct: correct,
          wrong: wrong,
        );
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.navyCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.verified_rounded : Icons.cancel_rounded,
              size: 64,
              color: passed ? AppColors.neon : AppColors.red,
            ),
            const SizedBox(height: 14),
            Text(
              passed ? l.passedTitle : l.failedTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: passed ? AppColors.neonSoft : AppColors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l.examResult(correct, wrong, answeredCount, total),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 10),
            Text(
              l.resultSaved,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 22),
            NeonButton(
              label: l.backHome,
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return _Lobby(onStart: _loading ? null : _start);
    }

    final q = _qs[_index];
    final selected = _answers[_index];
    final l = L10n.of(context);
    final flagged = _marked.contains(_index);

    return ExamShell(
      child: Column(
        children: [
          ExamMitHeader(
            title: l.isEn
                ? 'Theory exam — License B · Simulation'
                : 'Esame di Teoria — Patente B · Simulazione',
            timerLabel: _clock,
            timerHot: _seconds <= 60,
            onClose: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              physics: const BouncingScrollPhysics(),
              children: [
                ExamBezel(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.isEn
                            ? 'QUESTION SHEET · $_answeredCount/${_qs.length} answered'
                            : 'SCHEDA DOMANDE · $_answeredCount/${_qs.length} risposte',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ExamTokens.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ExamQuestionGrid(
                        count: _qs.length,
                        current: _index,
                        isAnswered: (i) => _answers.containsKey(i),
                        isFlagged: (i) => _marked.contains(i),
                        onSelect: (i) => setState(() => _index = i),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ExamBezel(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${l.scoreQuestion} ${_index + 1} ${l.isEn ? 'of' : 'di'} ${_qs.length}'
                                .toUpperCase(),
                            style: ExamTokens.mitEyebrow,
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => setState(() {
                              if (flagged) {
                                _marked.remove(_index);
                              } else {
                                _marked.add(_index);
                              }
                            }),
                            icon: Icon(
                              flagged ? Icons.flag_rounded : Icons.outlined_flag_rounded,
                              color: flagged ? const Color(0xFF8A6400) : ExamTokens.muted,
                              size: 18,
                            ),
                            label: Text(
                              flagged ? l.markedForReview : l.markForReview,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: flagged ? const Color(0xFF8A6400) : ExamTokens.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      QuestionImage(
                        key: ValueKey('exam-qi-${q.id}'),
                        image: q.image,
                        chapterId: q.chapterId,
                        chapterLabel: q.chapterNameIt,
                        height: 160,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        q.chapterNameIt.toUpperCase(),
                        style: ExamTokens.chapter,
                      ),
                      const SizedBox(height: 6),
                      // Official exam: Italian statement only — no translation help.
                      Text(q.textIt, style: ExamTokens.statement),
                      const SizedBox(height: 6),
                      Text(
                        l.isEn
                            ? 'Italian only · no translation (real exam rule)'
                            : 'Solo italiano · nessuna traduzione (come in Motorizzazione)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Color(0xFF8F2222),
                        ),
                      ),
                      const SizedBox(height: 22),
                      ExamCircleButtons(
                        selected: selected,
                        enabled: true,
                        onTrue: () => _pick(true),
                        onFalse: () => _pick(false),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          l.isEn ? 'Touch V (True) or F (False)' : 'Tocca V (Vero) o F (Falso)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ExamTokens.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: ExamNavBar(
              canPrevious: _index > 0,
              onPrevious: () => setState(() => _index--),
              previousLabel: l.previous,
              nextLabel: _index >= _qs.length - 1 ? l.submit : l.advance,
              summaryLabel: l.examNavTitle,
              onSummary: _openQuestionMap,
              onNext: () {
                if (_index >= _qs.length - 1) {
                  _submit();
                } else {
                  setState(() => _index++);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Lobby extends StatelessWidget {
  const _Lobby({required this.onStart});
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = L10n(state.lang);
    return PremiumScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            const SizedBox(height: 8),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.pinkGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(color: AppColors.pinkGlow, blurRadius: 24, offset: Offset(0, 8)),
                ],
              ),
              child: const Icon(Icons.flag_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              l.examLobbyTitle,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.examLobbySubtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            PremiumCard(
              child: Column(
                children: [
                  _Rule(Icons.quiz_outlined, l.rule30),
                  const SizedBox(height: 14),
                  _Rule(Icons.timer_outlined, l.ruleCountdown),
                  const SizedBox(height: 14),
                  _Rule(Icons.error_outline, l.ruleThreshold),
                  const SizedBox(height: 14),
                  _Rule(
                    Icons.history_rounded,
                    state.stats.examAttempts == 0
                        ? l.noSimulationYet
                        : l.attemptsAndPasses(state.stats.examAttempts, state.stats.examPasses),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            NeonButton(
              label: onStart == null ? l.preparing : l.startSimulation,
              icon: Icons.play_arrow_rounded,
              gradient: AppColors.pinkGradient,
              glow: AppColors.pinkGlow,
              onPressed: onStart ?? () {},
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                l.questionsFromLocal,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.electric.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.electricSoft),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

