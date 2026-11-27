import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';
import '../widgets/readiness_ring.dart';
import 'exam_screen.dart';
import 'fast_track_screen.dart';
import 'mistakes_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final stats = state.stats;
    final weak = state.weakTopics;
    final nextAction = weak.isNotEmpty
        ? 'Rivedi ${weak.first.nameIt}'
        : 'Inizia il primo quiz';

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
                              'PATENTE B',
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
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.offline_bolt_rounded, size: 11, color: AppColors.neonSoft),
                                  SizedBox(width: 3),
                                  Text(
                                    'OFFLINE',
                                    style: TextStyle(
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
                          'Ciao ${state.userName}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Il tuo coach intelligente per l\'esame',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _GearButton(onTap: () {}),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 26),
              child: Center(
                child: ReadinessRing(
                  progress: stats.readiness,
                  label: stats.readinessLabel,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      emoji: '🔥',
                      value: '${stats.streak}',
                      label: 'giorni streak',
                      accent: AppColors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      emoji: '⭐',
                      value: stats.totalAnswers == 0
                          ? '—'
                          : '${(stats.accuracy * 100).round()}%',
                      label: 'accuratezza',
                      accent: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
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
                          const Text(
                            'Prossima azione consigliata',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$nextAction · ~${stats.estDaysLeft} gg',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              delegate: SliverChildListDelegate([
                _ActionCard(
                  title: 'Fast Track',
                  subtitle: '1–2 giorni turbo',
                  icon: Icons.bolt_rounded,
                  gradient: AppColors.neonGradient,
                  glow: AppColors.neonGlow,
                  onTap: () => _push(context, const FastTrackScreen()),
                ),
                _ActionCard(
                  title: 'Quiz',
                  subtitle: '${state.totalQuestions} domande',
                  icon: Icons.play_arrow_rounded,
                  gradient: AppColors.electricGradient,
                  glow: AppColors.electricGlow,
                  onTap: () => _push(context, const QuizScreen()),
                ),
                _ActionCard(
                  title: 'Simulazione',
                  subtitle: 'Esame ufficiale',
                  icon: Icons.flag_rounded,
                  gradient: AppColors.pinkGradient,
                  glow: AppColors.pinkGlow,
                  onTap: () => _push(context, const ExamScreen()),
                ),
                _ActionCard(
                  title: 'I miei errori',
                  subtitle: '${state.mistakes.length} da rivedere',
                  icon: Icons.error_outline_rounded,
                  gradient: AppColors.orangeGradient,
                  glow: AppColors.orangeGlow,
                  onTap: () => _push(context, const MistakesScreen()),
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
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
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

class _GearButton extends StatelessWidget {
  const _GearButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: AppColors.stroke),
          ),
          child: const Icon(Icons.settings_rounded, color: AppColors.textSecondary, size: 22),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      borderColor: accent.withValues(alpha: 0.22),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
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

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.glow,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final Color glow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: glow, blurRadius: 22, offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -18,
                  top: -18,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                      const Spacer(),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.88),
                          fontWeight: FontWeight.w600,
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
    );
  }
}
