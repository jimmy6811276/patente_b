import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/chapter_media.dart';
import '../l10n/app_lang.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../widgets/design_system.dart';
import '../widgets/license_chip.dart';
import '../widgets/premium_scaffold.dart';
import 'exam_screen.dart';
import 'fast_track_lock_screen.dart';
import 'fast_track_screen.dart';
import 'license_coming_soon_screen.dart';
import 'mistakes_screen.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';
import 'sign_games_screen.dart';
import 'signs_atlas_screen.dart';
import 'stats_screen.dart';
import 'vocabulary_screen.dart';

/// Home — one visual composition, no duplicate destinations.
/// Quiz = center nav · Chapters = chapters tab · everything else appears once.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenProfile, this.onOpenStats});

  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenStats;

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

    void openContinue() {
      if (continueChapterId != null) {
        _push(
          context,
          QuizScreen(title: continueTitle, chapterId: continueChapterId),
        );
        return;
      }
      if (state.mistakes.isNotEmpty) {
        _push(context, const MistakesScreen());
        return;
      }
      _push(context, QuizScreen(title: l.quizTitle));
    }

    return PremiumScaffold(
      safeBottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 4, AppLayout.pagePad, 0),
              child: _Header(
                lang: state.lang,
                onOpenProfile: onOpenProfile,
              ),
            ),
          ),

          // Full-bleed visual hero — brand + one CTA
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 12, AppLayout.pagePad, 0),
              child: _HomeHero(
                brand: l.appTitle,
                headline: l.greeting(state.userName),
                support: continueTitle,
                cta: stats.totalAnswers == 0 ? l.startQuizCta : l.continueQuizCta,
                readiness: stats.readiness,
                accuracyLabel: stats.totalAnswers == 0
                    ? '—'
                    : '${(stats.accuracy * 100).round()}%',
                streakLabel: '${stats.streak}',
                readyLabel: l.heroReady,
                accLabel: l.heroAccuracy,
                streakMetricLabel: l.heroStreak,
                onCta: openContinue,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 16, AppLayout.pagePad, 6),
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

          // Featured — unique modes NOT duplicated in bottom nav
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 20, AppLayout.pagePad, 8),
              child: DsSectionLabel(l.featuredModesSection),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 210,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppLayout.pagePad),
                children: [
                  DsFeatureRail(
                    title: l.simulationTitle,
                    subtitle: l.ftQLabel,
                    color: AppColors.coral,
                    imageAsset: PracticeMedia.exam,
                    badge: '30 · 20′',
                    onTap: () => _push(context, const ExamScreen()),
                  ),
                  const SizedBox(width: 12),
                  DsFeatureRail(
                    title: l.hubDaily,
                    subtitle: state.dailyChallengeDone ? l.dailyAlreadyDone : l.hubDaily,
                    color: AppColors.emerald,
                    imageAsset: PracticeMedia.daily,
                    badge: state.dailyChallengeDone ? 'DONE' : 'TODAY',
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
                  const SizedBox(width: 12),
                  DsFeatureRail(
                    title: l.hubMini,
                    subtitle: l.hubMiniSub,
                    color: AppColors.blue,
                    imageAsset: PracticeMedia.quick,
                    badge: '10Q',
                    onTap: () => _push(
                      context,
                      QuizScreen(
                        title: l.hubMini,
                        quickMode: true,
                        limit: 10,
                        secondsPerQuestion: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DsFeatureRail(
                    title: l.hubQuick,
                    subtitle: l.quickQuizTitle,
                    color: AppColors.blueSoft,
                    imageAsset: PracticeMedia.quiz,
                    badge: '20s',
                    onTap: () => _push(
                      context,
                      QuizScreen(
                        title: l.quickQuizTitle,
                        quickMode: true,
                        secondsPerQuestion: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DsFeatureRail(
                    title: l.fastTrackSectionRow,
                    subtitle: l.fastTrackSubtitle,
                    color: AppColors.emerald,
                    imageAsset: PracticeMedia.fastTrack,
                    badge: 'ADMIN',
                    onTap: () => _push(
                      context,
                      state.fastTrackUnlocked
                          ? const FastTrackScreen()
                          : const FastTrackLockScreen(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DsFeatureRail(
                    title: l.examHistory,
                    subtitle: l.statsSub,
                    color: AppColors.violet,
                    imageAsset: PracticeMedia.bookmarks,
                    badge: '${state.examHistory.length}',
                    onTap: () {
                      if (onOpenStats != null) {
                        onOpenStats!();
                        return;
                      }
                      _push(context, const StatsScreen());
                    },
                  ),
                ],
              ),
            ),
          ),

          // Study paths — unique only (no Quiz / Chapters — those live in nav)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 18, AppLayout.pagePad, 8),
              child: DsSectionLabel(l.studyPathsSection),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.pagePad),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.84,
              ),
              delegate: SliverChildListDelegate([
                DsGridTile(
                  icon: Icons.map_rounded,
                  title: l.signsAtlasTitle,
                  subtitle: l.signsAtlasTileSub,
                  color: AppColors.amber,
                  imageAsset: PracticeMedia.signs,
                  onTap: () => _push(context, const SignsAtlasScreen()),
                ),
                DsGridTile(
                  icon: Icons.sports_esports_rounded,
                  title: l.hubSigns,
                  subtitle: l.signsSubtitle,
                  color: AppColors.amber,
                  imageAsset: PracticeMedia.chapters,
                  onTap: () => _push(context, const SignGamesScreen()),
                ),
                DsGridTile(
                  icon: Icons.local_fire_department_rounded,
                  title: l.hubHard,
                  subtitle: l.hardSubtitle,
                  color: AppColors.coral,
                  imageAsset: PracticeMedia.hard,
                  onTap: () => _push(
                    context,
                    QuizScreen(title: l.hardQuizTitle, hardMode: true),
                  ),
                ),
                DsGridTile(
                  icon: Icons.all_inclusive_rounded,
                  title: l.practiceAllTitle,
                  subtitle: l.practiceAllSub,
                  color: AppColors.blue,
                  imageAsset: PracticeMedia.quiz,
                  onTap: () => _push(context, QuizScreen(title: l.practiceAllTitle)),
                ),
                DsGridTile(
                  icon: Icons.translate_rounded,
                  title: l.hubVocab,
                  subtitle: l.vocabSub,
                  color: const Color(0xFF0891B2),
                  imageAsset: PracticeMedia.vocab,
                  onTap: () => _push(context, const VocabularyScreen()),
                ),
                DsGridTile(
                  icon: Icons.error_outline_rounded,
                  title: l.mistakesToReview,
                  subtitle: l.toReview(state.mistakes.length),
                  color: AppColors.coral,
                  imageAsset: PracticeMedia.mistakes,
                  onTap: () => _push(context, const MistakesScreen()),
                ),
                DsGridTile(
                  icon: Icons.bookmark_rounded,
                  title: l.hubBookmarks,
                  subtitle: l.hubBookmarksSub,
                  color: AppColors.blue,
                  imageAsset: PracticeMedia.bookmarks,
                  onTap: () => _push(
                    context,
                    QuizScreen(title: l.hubBookmarks, bookmarkMode: true),
                  ),
                ),
              ]),
            ),
          ),

          if (weak.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppLayout.pagePad, 18, AppLayout.pagePad, 8),
                child: DsSectionLabel(l.weakVisualSection),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 118,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppLayout.pagePad),
                  itemCount: weak.take(6).length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final w = weak[i];
                    final thumb = ChapterMedia.assetPathFor(w.chapterId);
                    return _WeakChapterChip(
                      title: l.topicName(w),
                      accuracy: '${(w.accuracy * 100).round()}%',
                      imageAsset: thumb,
                      onTap: () => _push(
                        context,
                        QuizScreen(
                          title: l.topicName(w),
                          chapterId: w.chapterId,
                          weakMode: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

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

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.brand,
    required this.headline,
    required this.support,
    required this.cta,
    required this.readiness,
    required this.accuracyLabel,
    required this.streakLabel,
    required this.readyLabel,
    required this.accLabel,
    required this.streakMetricLabel,
    required this.onCta,
  });

  final String brand;
  final String headline;
  final String support;
  final String cta;
  final double readiness;
  final String accuracyLabel;
  final String streakLabel;
  final String readyLabel;
  final String accLabel;
  final String streakMetricLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 292,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              PracticeMedia.hero,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Color(0xFF16324F),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0B1220).withValues(alpha: 0.22),
                    const Color(0xFF0B1220).withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brand,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    headline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    support,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _HeroMetric(label: readyLabel, value: '${(readiness * 100).round()}%'),
                      const SizedBox(width: 8),
                      _HeroMetric(label: accLabel, value: accuracyLabel),
                      const SizedBox(width: 8),
                      _HeroMetric(label: streakMetricLabel, value: streakLabel),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: onCta,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        cta,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeakChapterChip extends StatelessWidget {
  const _WeakChapterChip({
    required this.title,
    required this.accuracy,
    required this.onTap,
    this.imageAsset,
  });

  final String title;
  final String accuracy;
  final VoidCallback onTap;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 168,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.stroke),
            boxShadow: const [
              BoxShadow(color: Color(0x100B1220), blurRadius: 12, offset: Offset(0, 5)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.amberDim,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(6),
                child: imageAsset != null
                    ? Image.asset(
                        imageAsset!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.trending_down_rounded, color: AppColors.amber),
                      )
                    : const Icon(Icons.trending_down_rounded, color: AppColors.amber),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accuracy,
                      style: const TextStyle(
                        color: AppColors.amber,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.lang,
    this.onOpenProfile,
  });

  final AppLang lang;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final l = L10n(lang);
    final other = lang == AppLang.it ? AppLang.en : AppLang.it;

    // Real actions only: logo + title + language + profile. No dummy badges.
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/branding/app_logo.jpg',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l.appTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              color: AppColors.ink,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            context.read<AppState>().setLanguage(other);
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: const Size(44, 44),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            lang.code.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ),
        IconButton(
          tooltip: l.navProfile,
          onPressed: () {
            HapticFeedback.selectionClick();
            if (onOpenProfile != null) {
              onOpenProfile!();
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          icon: const Icon(Icons.person_outline_rounded, color: AppColors.inkSoft),
        ),
      ],
    );
  }
}
