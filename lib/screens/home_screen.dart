import 'dart:ui' show ImageFilter;

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
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _FlagRibbon(),
                            const SizedBox(width: 10),
                            Text(
                              'PATENTE ${state.selectedLicense.code}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.6,
                                color: AppColors.textSecondary.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.neon.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.neon.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.offline_bolt_rounded,
                                      size: 11, color: AppColors.neonSoft),
                                  const SizedBox(width: 3),
                                  Text(
                                    l.offlineBadge,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.neonSoft,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l.greeting(state.userName),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.3,
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
              child: Row(
                children: [
                  ReadinessRing(
                    progress: stats.readiness,
                    label: l.readinessLabel(stats),
                    size: 118,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      children: [
                        _MiniMetric(
                          emoji: '🔥',
                          value: '${stats.streak}',
                          label: l.streakLabel,
                          accent: AppColors.orange,
                        ),
                        const SizedBox(height: 10),
                        _MiniMetric(
                          emoji: '⭐',
                          value: stats.totalAnswers == 0
                              ? '—'
                              : '${(stats.accuracy * 100).round()}%',
                          label: l.accuracyLabel,
                          accent: AppColors.gold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: PremiumCard(
                padding: const EdgeInsets.all(14),
                borderColor: AppColors.electric.withValues(alpha: 0.25),
                onTap: () => _push(context, const QuizScreen()),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.electricGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.electricGlow,
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.nextActionLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$nextAction · ~${l.daysShort(stats.estDaysLeft)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
              child: Text(
                l.studyModes,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.88,
              ),
              delegate: SliverChildListDelegate([
                _HubTile(
                  title: l.quizTitle,
                  subtitle: l.questionsCount(state.totalQuestions),
                  kind: HubIconKind.quiz,
                  gradient: AppColors.electricGradient,
                  glow: AppColors.electricGlow,
                  delay: 0,
                  onTap: () => _push(context, QuizScreen(title: l.quizTitle)),
                ),
                _HubTile(
                  title: l.simulationTitle,
                  subtitle: l.officialExam,
                  kind: HubIconKind.exam,
                  gradient: AppColors.pinkGradient,
                  glow: AppColors.pinkGlow,
                  delay: 40,
                  onTap: () => _push(context, const ExamScreen()),
                ),
                _HubTile(
                  title: l.hubChapters,
                  subtitle: l.chaptersShort,
                  kind: HubIconKind.chapters,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5B8CFF), Color(0xFF2A4FC8)],
                  ),
                  glow: AppColors.electricGlow,
                  delay: 80,
                  onTap: () => _push(context, const ChaptersScreen()),
                ),
                _HubTile(
                  title: l.myMistakes,
                  subtitle: l.toReview(state.mistakes.length),
                  kind: HubIconKind.mistakes,
                  gradient: AppColors.orangeGradient,
                  glow: AppColors.orangeGlow,
                  delay: 120,
                  onTap: () => _push(context, const MistakesScreen()),
                ),
                _HubTile(
                  title: l.hubSigns,
                  subtitle: l.signsSubtitle,
                  kind: HubIconKind.signs,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFC14D), Color(0xFFE07A00)],
                  ),
                  glow: AppColors.orangeGlow,
                  delay: 160,
                  onTap: () => _push(context, const SignGamesScreen()),
                ),
                _HubTile(
                  title: l.hubHard,
                  subtitle: l.hardSubtitle,
                  kind: HubIconKind.hard,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B73), Color(0xFFC9182B)],
                  ),
                  glow: AppColors.redGlow,
                  delay: 200,
                  onTap: () => _push(
                    context,
                    QuizScreen(title: l.hardQuizTitle, hardMode: true),
                  ),
                ),
                _HubTile(
                  title: l.hubDaily,
                  subtitle: state.dailyChallengeDone ? l.dailyDone : l.dailyAvailable,
                  kind: HubIconKind.daily,
                  gradient: AppColors.neonGradient,
                  glow: AppColors.neonGlow,
                  delay: 240,
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
                _HubTile(
                  title: l.fastTrackSectionRow,
                  subtitle: l.fastTrackSubtitle,
                  kind: HubIconKind.fastTrack,
                  gradient: AppColors.neonGradient,
                  glow: AppColors.neonGlow,
                  delay: 280,
                  locked: !state.fastTrackUnlocked,
                  lockedLabel: l.privateBadge,
                  onTap: () => _push(
                    context,
                    state.fastTrackUnlocked
                        ? const FastTrackScreen()
                        : const FastTrackLockScreen(),
                  ),
                ),
                _HubTile(
                  title: l.hubBookmarks,
                  subtitle: l.hubBookmarksSub,
                  kind: HubIconKind.bookmarks,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFD60A), Color(0xFFE0A800)],
                  ),
                  glow: const Color(0x66FFD60A),
                  delay: 320,
                  onTap: () => _push(
                    context,
                    QuizScreen(
                      title: l.hubBookmarks,
                      bookmarkMode: true,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 104)),
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
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }
}

class _FlagRibbon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        boxShadow: const [
          BoxShadow(color: Color(0x44000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
        gradient: const LinearGradient(
          colors: [AppColors.flagGreen, AppColors.flagWhite, AppColors.flagRed],
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.electric.withValues(alpha: 0.14),
            border: Border.all(color: AppColors.electric.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.translate_rounded, color: AppColors.electricSoft, size: 17),
              const SizedBox(height: 1),
              Text(
                lang.code.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.electricSoft,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.emoji,
    required this.value,
    required this.label,
    required this.accent,
  });

  final String emoji;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      borderColor: accent.withValues(alpha: 0.22),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
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

class _HubTile extends StatefulWidget {
  const _HubTile({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.gradient,
    required this.glow,
    required this.onTap,
    this.delay = 0,
    this.locked = false,
    this.lockedLabel = 'Privato',
    this.dimmed = false,
  });

  final String title;
  final String subtitle;
  final HubIconKind kind;
  final Gradient gradient;
  final Color glow;
  final VoidCallback onTap;
  final int delay;
  final bool locked;
  final String lockedLabel;
  final bool dimmed;

  @override
  State<_HubTile> createState() => _HubTileState();
}

class _HubTileState extends State<_HubTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Opacity(
          opacity: widget.dimmed ? 0.72 : 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: widget.glow, blurRadius: 18, offset: const Offset(0, 8)),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(22),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: widget.gradient,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -14,
                        top: -14,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: widget.locked ? 2.0 : 0,
                                sigmaY: widget.locked ? 2.0 : 0,
                              ),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: HubGridIcon(kind: widget.kind, size: 22),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.88),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.locked)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.42),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.32),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_rounded, size: 9, color: Colors.white),
                                const SizedBox(width: 2),
                                Text(
                                  widget.lockedLabel,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
