import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_lang.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
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
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.emerald,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PATENTE ${state.selectedLicense.code}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
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
                        const SizedBox(height: 10),
                        Text(
                          l.greeting(state.userName),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            height: 1.05,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.homeSubtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
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
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
              child: Text(
                l.chooseLicense,
                style: const TextStyle(
                  fontSize: 12,
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
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              child: PremiumCard(
                padding: const EdgeInsets.all(16),
                borderColor: AppColors.emerald.withValues(alpha: 0.2),
                child: Row(
                  children: [
                    ReadinessRing(
                      progress: stats.readiness,
                      label: l.readinessLabel(stats),
                      size: 108,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.nextActionLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextAction,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _MiniStat('🔥', '${stats.streak}'),
                              const SizedBox(width: 8),
                              _MiniStat(
                                '⭐',
                                stats.totalAnswers == 0
                                    ? '—'
                                    : '${(stats.accuracy * 100).round()}%',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: NeonButton(
                              label: l.quizTitle,
                              height: 44,
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
          // Learning path
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
              child: Text(
                l.studyModes,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 120),
            sliver: SliverList.list(
              children: [
                _PathNode(
                  step: 1,
                  title: l.quizTitle,
                  subtitle: l.questionsCount(state.totalQuestions),
                  color: AppColors.blue,
                  icon: Icons.quiz_rounded,
                  onTap: () => _push(context, QuizScreen(title: l.quizTitle)),
                ),
                _PathNode(
                  step: 2,
                  title: l.hubChapters,
                  subtitle: l.chaptersShort,
                  color: AppColors.blueSoft,
                  icon: Icons.menu_book_rounded,
                  onTap: () => _push(context, const ChaptersScreen()),
                ),
                _PathNode(
                  step: 3,
                  title: l.hubSigns,
                  subtitle: l.signsSubtitle,
                  color: AppColors.amber,
                  icon: Icons.signpost_rounded,
                  onTap: () => _push(context, const SignGamesScreen()),
                ),
                _PathNode(
                  step: 4,
                  title: l.hubHard,
                  subtitle: l.hardSubtitle,
                  color: AppColors.coral,
                  icon: Icons.local_fire_department_rounded,
                  onTap: () => _push(context, QuizScreen(title: l.hardQuizTitle, hardMode: true)),
                ),
                _PathNode(
                  step: 5,
                  title: l.hubDaily,
                  subtitle: state.dailyChallengeDone ? l.dailyDone : l.dailyAvailable,
                  color: AppColors.emerald,
                  icon: Icons.today_rounded,
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
                _PathNode(
                  step: 6,
                  title: l.simulationTitle,
                  subtitle: l.officialExam,
                  color: AppColors.pink,
                  icon: Icons.flag_rounded,
                  onTap: () => _push(context, const ExamScreen()),
                ),
                _PathNode(
                  step: 7,
                  title: l.myMistakes,
                  subtitle: l.toReview(state.mistakes.length),
                  color: AppColors.amber,
                  icon: Icons.error_outline_rounded,
                  onTap: () => _push(context, const MistakesScreen()),
                ),
                _PathNode(
                  step: 8,
                  title: l.fastTrackSectionRow,
                  subtitle: l.isEn ? 'Tricks & rules · website parity' : 'Tricks e regole · come sul sito',
                  color: AppColors.emerald,
                  icon: Icons.bolt_rounded,
                  locked: !state.fastTrackUnlocked,
                  lockedLabel: l.privateBadge,
                  onTap: () => _push(
                    context,
                    state.fastTrackUnlocked
                        ? const FastTrackScreen()
                        : const FastTrackLockScreen(),
                  ),
                ),
                _PathNode(
                  step: 9,
                  title: l.hubBookmarks,
                  subtitle: l.hubBookmarksSub,
                  color: AppColors.blue,
                  icon: Icons.bookmark_rounded,
                  last: true,
                  onTap: () => _push(
                    context,
                    QuizScreen(title: l.hubBookmarks, bookmarkMode: true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        transitionDuration: const Duration(milliseconds: 280),
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.blueDim,
            border: Border.all(color: AppColors.blue.withValues(alpha: 0.25)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.translate_rounded, color: AppColors.blue, size: 17),
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
  const _MiniStat(this.emoji, this.value);
  final String emoji;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.canvasDeep,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        ],
      ),
    );
  }
}

class _PathNode extends StatelessWidget {
  const _PathNode({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
    this.locked = false,
    this.lockedLabel = 'Privato',
    this.dimmed = false,
    this.last = false,
  });

  final int step;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool locked;
  final String lockedLabel;
  final bool dimmed;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.7 : 1,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$step',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (!last)
                    Expanded(
                      child: Container(
                        width: 3,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Ink(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.stroke),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x100B1220),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(icon, color: color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (locked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.ink.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lock_rounded, size: 12, color: AppColors.textMuted),
                                  const SizedBox(width: 3),
                                  Text(
                                    lockedLabel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Icon(Icons.chevron_right_rounded, color: color),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
