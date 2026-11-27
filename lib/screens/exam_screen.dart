import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';
import '../widgets/readiness_ring.dart';
import '../widgets/sign_art.dart';

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

  int get _wrongCount => _answers.entries
      .where((e) => e.value != _qs[e.key].correctIsTrue)
      .length;

  void _pick(bool value) {
    HapticFeedback.selectionClick();
    setState(() => _answers[_index] = value);
  }

  Future<void> _submit() async {
    if (_submitted) return;
    _submitted = true;
    _timer?.cancel();
    final total = _qs.length;
    // Official rule: every question is scored. Unanswered questions count as errors.
    final correct = _correctCount;
    final wrong = total - correct;
    final passed = wrong <= 3;
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
              passed ? 'Esame SUPERATO' : 'Esame NON SUPERATO',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: passed ? AppColors.neonSoft : AppColors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$correct corrette · $wrong errori (max 3)\n'
              'Risposte: ${_answers.length}/$total',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 10),
            const Text(
              'Esito salvato nel database locale',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 22),
            NeonButton(
              label: 'Torna alla home',
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

    return PremiumScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              children: [
                TimerRing(
                  progress: _seconds / (20 * 60),
                  label: _clock,
                  size: 120,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ScoreChip(
                        label: 'Corrette',
                        value: '$_correctCount',
                        color: AppColors.neon,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ScoreChip(
                        label: 'Errori · max 3',
                        value: '$_wrongCount',
                        color: AppColors.red,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ScoreChip(
                        label: 'Domanda',
                        value: '${_index + 1}/${_qs.length}',
                        color: AppColors.electric,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_index + 1) / _qs.length,
                    minHeight: 5,
                    backgroundColor: AppColors.navyElevated,
                    color: AppColors.pink,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              physics: const BouncingScrollPhysics(),
              children: [
                SignArt(
                  chapterId: q.chapterId,
                  label: q.chapterNameIt,
                  height: 160,
                ),
                const SizedBox(height: 16),
                Text(
                  q.textIt,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  q.textEn,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _Choice(
                        label: 'Vero',
                        selected: selected == true,
                        color: AppColors.neon,
                        onTap: () => _pick(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Choice(
                        label: 'Falso',
                        selected: selected == false,
                        color: AppColors.red,
                        onTap: () => _pick(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => setState(() {
                    if (_marked.contains(_index)) {
                      _marked.remove(_index);
                    } else {
                      _marked.add(_index);
                    }
                  }),
                  icon: Icon(
                    _marked.contains(_index)
                        ? Icons.flag_rounded
                        : Icons.outlined_flag_rounded,
                    color: AppColors.orange,
                  ),
                  label: Text(
                    _marked.contains(_index)
                        ? 'Segnata per revisione'
                        : 'Segna per revisione',
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _NavBtn(
                    label: 'Precedente',
                    onTap: _index == 0 ? null : () => setState(() => _index--),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NavBtn(
                    label: 'Salta',
                    onTap: () {
                      if (_index < _qs.length - 1) setState(() => _index++);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NeonButton(
                    label: _index >= _qs.length - 1 ? 'Consegna' : 'Avanti',
                    height: 48,
                    gradient: AppColors.pinkGradient,
                    glow: AppColors.pinkGlow,
                    onPressed: () {
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
            const Text(
              'Simulazione\nEsame',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Formato ufficiale Ministero:\n30 domande · 20 minuti · massimo 3 errori',
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            PremiumCard(
              child: Column(
                children: [
                  const _Rule(Icons.quiz_outlined, '30 domande Vero / Falso'),
                  const SizedBox(height: 14),
                  const _Rule(Icons.timer_outlined, 'Countdown circolare 20:00'),
                  const SizedBox(height: 14),
                  const _Rule(Icons.error_outline, 'Soglia: ≤ 3 errori'),
                  const SizedBox(height: 14),
                  _Rule(
                    Icons.history_rounded,
                    state.stats.examAttempts == 0
                        ? 'Nessuna simulazione ancora'
                        : '${state.stats.examAttempts} tentativi · ${state.stats.examPasses} superati',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            NeonButton(
              label: onStart == null ? 'Preparazione…' : 'Inizia simulazione',
              icon: Icons.play_arrow_rounded,
              gradient: AppColors.pinkGradient,
              glow: AppColors.pinkGlow,
              onPressed: onStart ?? () {},
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Domande selezionate dal database locale',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      borderColor: color.withValues(alpha: 0.3),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: color),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 56,
      decoration: BoxDecoration(
        color: selected ? color : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? color : AppColors.strokeStrong,
          width: 1.6,
        ),
        boxShadow: selected
            ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        disabledForegroundColor: AppColors.textMuted,
        side: const BorderSide(color: AppColors.strokeStrong),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
