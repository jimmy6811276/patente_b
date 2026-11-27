import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_lang.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../widgets/design_system.dart';
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
import 'settings_screen.dart';
import 'sign_games_screen.dart';
import 'vocabulary_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenProfile});

  /// Switches the shell to the Profile/Settings tab (keeps bottom nav).
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = L10n(state.lang);
    final stats = state.stats;
    final weak = state.weakTopics;
    final bottomPad = AppLayout.bottomClearance(context);

    final continueChapterId = weak.isNotEmpty ? weak.first.chapterId : null;
    final continueTitle = weak.isNotEmpty
        ? '${l.reviewTopic} ${l.topicName(weak.first)}'
        : state.mistakes.isNotEmpty
            ? l.mistakesToReview
            : l.startFirstQuiz;

    return PremiumScaffold(
      safeBottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 8, AppLayout.pagePad, 0),
              child: _Header(
                lang: state.lang,
                streak: stats.streak,
                offline: state.offlineReady,
                onOpenProfile: onOpenProfile,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 16, AppLayout.pagePad, 8),
              child: Text(
                l.greeting(state.userName),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                  height: 1.15,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 0, AppLayout.pagePad, 8),
              child: DsSectionLabel(l.chooseLicense),
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
          // Hero readiness + single CTA
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 16, AppLayout.pagePad, 0),
              child: DsCard(
                borderColor: AppColors.emerald.withValues(alpha: 0.22),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ReadinessRing(
                          progress: stats.readiness,
                          caption: stats.totalAnswers == 0 ? l.progressCaptionStart : l.progressCaption,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.nextActionLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                continueTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                  letterSpacing: 0,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  DsStatBadge(
                                    icon: Icons.local_fire_department_rounded,
                                    value: l.streakValue(stats.streak),
                                    label: l.statStreak,
                                  ),
                                  const SizedBox(width: 8),
                                  DsStatBadge(
                                    icon: Icons.insights_rounded,
                                    value: stats.totalAnswers == 0
                                        ? '0%'
                                        : '${(stats.accuracy * 100).round()}%',
                                    label: l.statAccuracy,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  DsStatBadge(
                                    icon: Icons.quiz_outlined,
                                    value: '${state.totalQuestions}',
                                    label: l.statQuestions,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(child: SizedBox()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: AppLayout.touchMin,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (continueChapterId != null) {
                            _push(
                              context,
                              QuizScreen(
                                title: continueTitle,
                                chapterId: continueChapterId,
                              ),
                            );
                            return;
                          }
                          if (state.mistakes.isNotEmpty) {
                            _push(context, const MistakesScreen());
                            return;
                          }
                          _push(context, QuizScreen(title: l.quizTitle));
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.emerald,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          stats.totalAnswers == 0 ? l.startQuizCta : l.continueQuizCta,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Quick pills — no duplicate of main CTA
          SliverToBoxAdapter(
            child: SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 14, AppLayout.pagePad, 0),
                children: [
                  DsQuickPill(
                    label: l.hubDaily,
                    icon: Icons.today_rounded,
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
                  DsQuickPill(
                    label: l.hubQuick,
                    icon: Icons.bolt_rounded,
                    color: AppColors.blue,
                    onTap: () => _push(
                      context,
                      QuizScreen(title: l.quickQuizTitle, quickMode: true, secondsPerQuestion: 20),
                    ),
                  ),
                  DsQuickPill(
                    label: l.simulationTitle,
                    icon: Icons.flag_rounded,
                    color: AppColors.coral,
                    onTap: () => _push(context, const ExamScreen()),
                  ),
                  DsQuickPill(
                    label: l.hubSigns,
                    icon: Icons.signpost_rounded,
                    color: AppColors.amber,
                    onTap: () => _push(context, const SignGamesScreen()),
                  ),
                ],
              ),
            ),
          ),
          // Official exam info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 16, AppLayout.pagePad, 0),
              child: DsCard(
                borderColor: AppColors.blue.withValues(alpha: 0.22),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.officialExamInfo,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: AppColors.inkSoft,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Continue / mistakes / bookmarks
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 20, AppLayout.pagePad, 8),
              child: DsSectionLabel(l.continueSection),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.pagePad),
              child: Column(
                children: [
                  DsListRow(
                    icon: Icons.play_circle_outline_rounded,
                    title: l.continueWhereLeft,
                    subtitle: continueTitle,
                    color: AppColors.emerald,
                    onTap: () {
                      if (continueChapterId != null) {
                        _push(
                          context,
                          QuizScreen(
                            title: continueTitle,
                            chapterId: continueChapterId,
                          ),
                        );
                        return;
                      }
                      if (state.mistakes.isNotEmpty) {
                        _push(context, const MistakesScreen());
                        return;
                      }
                      _push(context, QuizScreen(title: l.quizTitle));
                    },
                  ),
                  const SizedBox(height: 8),
                  DsListRow(
                    icon: Icons.error_outline_rounded,
                    title: l.mistakesToReview,
                    subtitle: l.toReview(state.mistakes.length),
                    color: AppColors.coral,
                    onTap: () => _push(context, const MistakesScreen()),
                  ),
                  const SizedBox(height: 8),
                  DsListRow(
                    icon: Icons.bookmark_rounded,
                    title: l.hubBookmarks,
                    subtitle: l.hubBookmarksSub,
                    color: AppColors.blue,
                    onTap: () => _push(
                      context,
                      QuizScreen(title: l.hubBookmarks, bookmarkMode: true),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (weak.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 20, AppLayout.pagePad, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DsSectionLabel(l.weakChaptersSection),
                    const SizedBox(height: 8),
                    ...weak.take(3).map(
                      (w) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: DsListRow(
                          icon: Icons.trending_down_rounded,
                          title: l.topicName(w),
                          subtitle: '${(w.accuracy * 100).round()}%',
                          color: AppColors.amber,
                          onTap: () => _push(
                            context,
                            QuizScreen(
                              title: l.topicName(w),
                              chapterId: w.chapterId,
                              weakMode: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Practice grid — equal height tiles
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 12, AppLayout.pagePad, 8),
              child: DsSectionLabel(l.practiceSection),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.pagePad),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.88,
              ),
              delegate: SliverChildListDelegate([
                DsGridTile(
                  icon: Icons.quiz_rounded,
                  title: l.quizTitle,
                  subtitle: l.questionsCount(state.totalQuestions),
                  color: AppColors.blue,
                  onTap: () => _push(context, QuizScreen(title: l.quizTitle)),
                ),
                DsGridTile(
                  icon: Icons.menu_book_rounded,
                  title: l.hubChapters,
                  subtitle: l.chaptersShort,
                  color: AppColors.blueSoft,
                  onTap: () => _push(context, const ChaptersScreen()),
                ),
                DsGridTile(
                  icon: Icons.signpost_rounded,
                  title: l.hubSigns,
                  subtitle: l.signsSubtitle,
                  color: AppColors.amber,
                  onTap: () => _push(context, const SignGamesScreen()),
                ),
                DsGridTile(
                  icon: Icons.local_fire_department_rounded,
                  title: l.hubHard,
                  subtitle: l.hardSubtitle,
                  color: AppColors.coral,
                  onTap: () => _push(
                    context,
                    QuizScreen(title: l.hardQuizTitle, hardMode: true),
                  ),
                ),
                DsGridTile(
                  icon: Icons.translate_rounded,
                  title: l.hubVocab,
                  subtitle: l.vocabSub,
                  color: const Color(0xFF0891B2),
                  onTap: () => _push(context, const VocabularyScreen()),
                ),
                DsGridTile(
                  icon: Icons.bolt_rounded,
                  title: l.fastTrackSectionRow,
                  subtitle: l.fastTrackSubtitle,
                  color: AppColors.emerald,
                  onTap: () => _push(
                    context,
                    state.fastTrackUnlocked
                        ? const FastTrackScreen()
                        : const FastTrackLockScreen(),
                  ),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
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
        transitionDuration: const Duration(milliseconds: 260),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.lang,
    required this.streak,
    required this.offline,
    this.onOpenProfile,
  });

  final AppLang lang;
  final int streak;
  final bool offline;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final l = L10n(lang);
    final other = lang == AppLang.it ? AppLang.en : AppLang.it;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.neonGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Text(
            'P',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.appTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                  color: AppColors.ink,
                ),
              ),
              Text(
                l.homeSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        _HeaderIcon(
          tooltip: l.statStreak,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department_rounded, size: 16, color: AppColors.coral),
              const SizedBox(width: 2),
              Text(
                '$streak',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        _HeaderIcon(
          tooltip: offline ? l.offlineBadge : l.onlineBadge,
          child: Icon(
            offline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
            size: 18,
            color: offline ? AppColors.emerald : AppColors.blue,
          ),
        ),
        const SizedBox(width: 6),
        _HeaderIcon(
          tooltip: lang.code.toUpperCase(),
          onTap: () {
            HapticFeedback.selectionClick();
            context.read<AppState>().setLanguage(other);
          },
          child: Text(
            lang.code.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: AppColors.blue,
            ),
          ),
        ),
        const SizedBox(width: 6),
        _HeaderIcon(
          tooltip: l.navProfile,
          onTap: () {
            HapticFeedback.selectionClick();
            if (onOpenProfile != null) {
              onOpenProfile!();
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          child: const Icon(Icons.person_rounded, size: 18, color: AppColors.inkSoft),
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.child, this.onTap, this.tooltip});
  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final box = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: AppLayout.touchMin,
          height: AppLayout.touchMin,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Center(child: child),
        ),
      ),
    );
    if (tooltip == null) return box;
    return Tooltip(message: tooltip!, child: box);
  }
}
