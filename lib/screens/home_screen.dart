import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_lang.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/grid_icons.dart';
import '../widgets/license_chip.dart';
import '../widgets/premium_scaffold.dart';
import '../widgets/readiness_ring.dart';
import 'chapters_screen.dart';
import 'exam_screen.dart';
import 'fast_track_lock_screen.dart';
import 'fast_track_screen.dart';
import 'license_coming_soon_screen.dart';
import 'mistakes_screen.dart';
import 'quiz_screen.dart';
import 'sign_games_screen.dart';
import 'stats_screen.dart';
import 'vocabulary_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = L10n(state.lang);
    final stats = state.stats;
    final weak = state.weakTopics;
    final nextAction = weak.isNotEmpty
        ? '${l.reviewTopic} ${l.topicName(weak.first)}'
        : l.startFirstQuiz;

    return PremiumScaffold(
      safeBottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.emerald,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PATENTE ${state.selectedLicense.code}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.emeraldDim,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l.offlineBadge,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.emerald,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.greeting(state.userName),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.7,
                            height: 1.05,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l.homeSubtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _LangButton(lang: state.lang),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Text(
                l.chooseLicense,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: LicenseChipStrip(
              selected: state.selectedLicense,
              isEnglish: state.lang.isEnglish,
              onSelected: (cat) async {
                await context.read<AppState>().setSelectedLicense(cat);
                if (!cat.isPlayable && context.mounted) {
                  _push(context, LicenseComingSoonScreen(category: cat));
                }
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: PremiumCard(
                padding: const EdgeInsets.all(14),
                borderColor: AppColors.emerald.withValues(alpha: 0.2),
                child: Row(
                  children: [
                    ReadinessRing(
                      progress: stats.readiness,
                      label: l.readinessLabel(stats),
                      size: 96,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.nextActionLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            nextAction,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _MiniStat(Icons.local_fire_department_rounded, '${stats.streak}'),
                              const SizedBox(width: 6),
                              _MiniStat(
                                Icons.insights_rounded,
                                stats.totalAnswers == 0
                                    ? '—'
                                    : '${(stats.accuracy * 100).round()}%',
                              ),
                              const SizedBox(width: 6),
                              _MiniStat(Icons.quiz_outlined, '${state.totalQuestions}'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: NeonButton(
                              label: l.quizTitle,
                              height: 42,
                              icon: Icons.play_arrow_rounded,
                              onPressed: () => _push(context, QuizScreen(title: l.quizTitle)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Quick launch strip
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                children: [
                  _QuickChip(
                    label: l.hubDaily,
                    color: AppColors.emerald,
                    done: state.dailyChallengeDone,
                    onTap: () {
                      if (state.dailyChallengeDone) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.dailyAlreadyDone)),
                        );
                        return;
                      }
                      _push(
                        context,
                        QuizScreen(
                          title: l.dailyChallengeTitle,
                          dailyMode: true,
                          secondsPerQuestion: 25,
                        ),
                      );
                    },
                  ),
                  _QuickChip(
                    label: l.hubQuick,
                    color: AppColors.blue,
                    onTap: () => _push(
                      context,
                      QuizScreen(title: l.quickQuizTitle, quickMode: true, secondsPerQuestion: 20),
                    ),
                  ),
                  _QuickChip(
                    label: l.simulationTitle,
                    color: AppColors.coral,
                    onTap: () => _push(context, const ExamScreen()),
                  ),
                  _QuickChip(
                    label: l.hubSigns,
                    color: AppColors.amber,
                    onTap: () => _push(context, const SignGamesScreen()),
                  ),
                  _QuickChip(
                    label: l.hubVocab,
                    color: AppColors.blueSoft,
                    onTap: () => _push(context, const VocabularyScreen()),
                  ),
                ],
              ),
            ),
          ),
          ..._section(
            context,
            title: l.practiceSection,
            tiles: [
              _TileSpec(
                title: l.quizTitle,
                subtitle: l.questionsCount(state.totalQuestions),
                color: AppColors.blue,
                kind: HubIconKind.quiz,
                onTap: () => _push(context, QuizScreen(title: l.quizTitle)),
              ),
              _TileSpec(
                title: l.hubQuick,
                subtitle: l.quickSub,
                color: const Color(0xFF0EA5E9),
                kind: HubIconKind.quick,
                onTap: () => _push(
                  context,
                  QuizScreen(title: l.quickQuizTitle, quickMode: true, secondsPerQuestion: 20),
                ),
              ),
              _TileSpec(
                title: l.hubTimed,
                subtitle: l.timedSub,
                color: AppColors.amber,
                kind: HubIconKind.timed,
                onTap: () => _push(
                  context,
                  QuizScreen(
                    title: l.hubTimed,
                    quickMode: true,
                    limit: 12,
                    secondsPerQuestion: 15,
                  ),
                ),
              ),
              _TileSpec(
                title: l.hubHard,
                subtitle: l.hardSubtitle,
                color: AppColors.coral,
                kind: HubIconKind.hard,
                onTap: () => _push(
                  context,
                  QuizScreen(title: l.hardQuizTitle, hardMode: true),
                ),
              ),
              _TileSpec(
                title: l.hubWeak,
                subtitle: l.weakSub,
                color: const Color(0xFFEA580C),
                kind: HubIconKind.weak,
                onTap: () => _push(
                  context,
                  QuizScreen(title: l.hubWeak, weakMode: true, limit: 20),
                ),
              ),
              _TileSpec(
                title: l.hubDaily,
                subtitle: state.dailyChallengeDone ? l.dailyDone : l.dailyAvailable,
                color: AppColors.emerald,
                kind: HubIconKind.daily,
                dimmed: state.dailyChallengeDone,
                onTap: () {
                  if (state.dailyChallengeDone) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.dailyAlreadyDone)),
                    );
                    return;
                  }
                  _push(
                    context,
                    QuizScreen(
                      title: l.dailyChallengeTitle,
                      dailyMode: true,
                      secondsPerQuestion: 25,
                    ),
                  );
                },
              ),
            ],
          ),
          ..._section(
            context,
            title: l.examSection,
            tiles: [
              _TileSpec(
                title: l.simulationTitle,
                subtitle: l.officialExam,
                color: AppColors.pink,
                kind: HubIconKind.exam,
                onTap: () => _push(context, const ExamScreen()),
              ),
              _TileSpec(
                title: l.hubMini,
                subtitle: l.miniSub,
                color: const Color(0xFFDB2777),
                kind: HubIconKind.mini,
                onTap: () => _push(
                  context,
                  QuizScreen(
                    title: l.hubMini,
                    limit: 15,
                    secondsPerQuestion: 40,
                  ),
                ),
              ),
              _TileSpec(
                title: l.myMistakes,
                subtitle: l.toReview(state.mistakes.length),
                color: AppColors.coral,
                kind: HubIconKind.mistakes,
                onTap: () => _push(context, const MistakesScreen()),
              ),
              _TileSpec(
                title: l.hubBookmarks,
                subtitle: l.hubBookmarksSub,
                color: AppColors.blue,
                kind: HubIconKind.bookmarks,
                onTap: () => _push(
                  context,
                  QuizScreen(title: l.hubBookmarks, bookmarkMode: true),
                ),
              ),
              _TileSpec(
                title: l.hubStats,
                subtitle: l.statsSub,
                color: const Color(0xFF6366F1),
                kind: HubIconKind.stats,
                onTap: () => _push(context, const StatsScreen()),
              ),
            ],
          ),
          ..._section(
            context,
            title: l.studySection,
            tiles: [
              _TileSpec(
                title: l.hubChapters,
                subtitle: l.chaptersShort,
                color: AppColors.blueSoft,
                kind: HubIconKind.chapters,
                onTap: () => _push(context, const ChaptersScreen()),
              ),
              _TileSpec(
                title: l.hubVocab,
                subtitle: l.vocabSub,
                color: const Color(0xFF0891B2),
                kind: HubIconKind.vocab,
                onTap: () => _push(context, const VocabularyScreen()),
              ),
              _TileSpec(
                title: l.hubSigns,
                subtitle: l.signsSubtitle,
                color: AppColors.amber,
                kind: HubIconKind.signs,
                onTap: () => _push(context, const SignGamesScreen()),
              ),
              _TileSpec(
                title: l.fastTrackSectionRow,
                subtitle: l.fastTrackSubtitle,
                color: AppColors.emerald,
                kind: HubIconKind.fastTrack,
                locked: !state.fastTrackUnlocked,
                lockedLabel: l.privateBadge,
                onTap: () => _push(
                  context,
                  state.fastTrackUnlocked
                      ? const FastTrackScreen()
                      : const FastTrackLockScreen(),
                ),
              ),
            ],
            bottomPad: 120,
          ),
        ],
      ),
    );
  }

  List<Widget> _section(
    BuildContext context, {
    required String title,
    required List<_TileSpec> tiles,
    double bottomPad = 8,
  }) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.92,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final t = tiles[i];
              return _HubTile(tile: t);
            },
            childCount: tiles.length,
          ),
        ),
      ),
    ];
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 260),
      ),
    );
  }
}

class _TileSpec {
  const _TileSpec({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.kind,
    required this.onTap,
    this.locked = false,
    this.lockedLabel = 'Privato',
    this.dimmed = false,
  });

  final String title;
  final String subtitle;
  final Color color;
  final HubIconKind kind;
  final VoidCallback onTap;
  final bool locked;
  final String lockedLabel;
  final bool dimmed;
}

class _HubTile extends StatelessWidget {
  const _HubTile({required this.tile});
  final _TileSpec tile;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: tile.dimmed ? 0.62 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            tile.onTap();
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.stroke),
              boxShadow: const [
                BoxShadow(color: Color(0x100B1220), blurRadius: 12, offset: Offset(0, 5)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          tile.color,
                          Color.lerp(tile.color, Colors.black, 0.18)!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: tile.color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: HubGridIcon(kind: tile.kind, size: 22, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    tile.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tile.locked ? tile.lockedLabel : tile.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: tile.locked ? AppColors.coral : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.color,
    required this.onTap,
    this.done = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: done ? AppColors.canvasDeep : color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: done ? 0.15 : 0.28)),
            ),
            child: Row(
              children: [
                Icon(
                  done ? Icons.check_circle_rounded : Icons.bolt_rounded,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({required this.lang});
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final other = lang == AppLang.it ? AppLang.en : AppLang.it;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.read<AppState>().setLanguage(other);
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.blueDim,
            border: Border.all(color: AppColors.blue.withValues(alpha: 0.25)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.translate_rounded, color: AppColors.blue, size: 16),
              Text(
                lang.code.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.icon, this.value);
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.canvasDeep,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }
}
