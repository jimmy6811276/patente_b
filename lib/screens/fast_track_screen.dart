import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_data.dart';
import '../data/app_state.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';
import 'quiz_screen.dart';

class FastTrackScreen extends StatefulWidget {
  const FastTrackScreen({super.key});

  @override
  State<FastTrackScreen> createState() => _FastTrackScreenState();
}

class _FastTrackScreenState extends State<FastTrackScreen> {
  late List<FastTrackTask> _tasks;
  bool _showAllVocab = false;

  @override
  void initState() {
    super.initState();
    _tasks = AppData.fastTrackTasks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final saved = context.read<AppState>().fastTrackDone;
    if (saved.isEmpty) return;
    _tasks = _tasks
        .map((t) => saved.containsKey(t.id) ? t.copyWith(done: saved[t.id]) : t)
        .toList();
  }

  int get _done => _tasks.where((t) => t.done).length;
  double get _progress => _done / _tasks.length;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final vocab = context.watch<AppState>().vocabulary;
    final day1 = _tasks.where((t) => t.day == 1).toList();
    final day2 = _tasks.where((t) => t.day == 2).toList();
    final visibleVocab = _showAllVocab ? vocab : vocab.take(6).toList();

    return PremiumScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 20, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                Expanded(
                  child: Text(
                    l.fastTrackScreenTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neon.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.neon.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    '$_done/${_tasks.length}',
                    style: const TextStyle(
                      color: AppColors.neonSoft,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              physics: const BouncingScrollPhysics(),
              children: [
                PremiumCard(
                  padding: EdgeInsets.zero,
                  glow: AppColors.neonGlow,
                  borderColor: AppColors.neon.withValues(alpha: 0.3),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.neon.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.neonGradient,
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.neonGlow,
                                blurRadius: 28,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.turboPlan,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.turboPlanSubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 10,
                            backgroundColor: AppColors.navyElevated,
                            color: AppColors.neon,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.percentComplete((_progress * 100).round()),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _FeatureRow(l: l),
                const SizedBox(height: 24),
                _DayBlock(
                  title: l.day1,
                  subtitle: l.day1Sub,
                  accent: AppColors.neon,
                  tasks: day1,
                  onToggle: _toggle,
                  l: l,
                ),
                const SizedBox(height: 20),
                _DayBlock(
                  title: l.day2,
                  subtitle: l.day2Sub,
                  accent: AppColors.electric,
                  tasks: day2,
                  onToggle: _toggle,
                  l: l,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.translate_rounded, size: 18, color: AppColors.electricSoft),
                    const SizedBox(width: 8),
                    Text(
                      l.vocabularyEssentials,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => _showAllVocab = !_showAllVocab),
                      child: Text(
                        _showAllVocab ? l.showLess : l.showAll,
                        style: const TextStyle(color: AppColors.electricSoft, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ...visibleVocab.map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.neon.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.volume_up_rounded, size: 17, color: AppColors.neonSoft),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.vocabularyTerm(v),
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  l.vocabularyTermSecondary(v),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            l.chapterShortFT(v.chapterId),
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                NeonButton(
                  label: _done == 0 ? l.startPlan : l.continuePlan,
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(title: l.fastTrackQuiz),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggle(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    final next = !task.done;
    setState(() {
      _tasks = _tasks
          .map((t) => t.id == id ? t.copyWith(done: next) : t)
          .toList();
    });
    context.read<AppState>().setFastTrackTask(id, next);
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.l});
  final L10n l;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.translate_rounded, l.p('IT + EN', 'EN + IT')),
      (Icons.lightbulb_rounded, l.featureTricks),
      (Icons.signpost_rounded, l.featureSigns),
      (Icons.cloud_off_rounded, l.p('Offline', 'Offline')),
    ];
    return Row(
      children: items
          .map(
            (e) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Column(
                    children: [
                      Icon(e.$1, size: 18, color: AppColors.electricSoft),
                      const SizedBox(height: 4),
                      Text(
                        e.$2,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DayBlock extends StatelessWidget {
  const _DayBlock({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.tasks,
    required this.onToggle,
    required this.l,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final List<FastTrackTask> tasks;
  final void Function(String id) onToggle;
  final L10n l;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 2, bottom: 12),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
        ...tasks.asMap().entries.map((entry) {
          final i = entry.key;
          final t = entry.value;
          final isLast = i == tasks.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: t.done ? AppColors.neonGradient : null,
                          border: Border.all(
                            color: t.done ? AppColors.neon : AppColors.textMuted,
                            width: 2.2,
                          ),
                          boxShadow: t.done
                              ? const [BoxShadow(color: AppColors.neonGlow, blurRadius: 10)]
                              : null,
                        ),
                        child: t.done
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: t.done
                                ? AppColors.neon.withValues(alpha: 0.45)
                                : AppColors.strokeStrong,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                    child: PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      onTap: () => onToggle(t.id),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.fastTrackTitle(t),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    decoration: t.done ? TextDecoration.lineThrough : null,
                                    color: t.done ? AppColors.textMuted : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  l.fastTrackTitleSecondary(t),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${t.minutes}′',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
