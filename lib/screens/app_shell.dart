import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../utils/app_haptics.dart';
import 'chapters_screen.dart';
import 'exam_screen.dart';
import 'home_screen.dart';
import 'language_picker_screen.dart';
import 'loading_screen.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.loading) {
      return const LoadingScreen();
    }
    if (state.error != null) {
      return DbErrorScreen(
        message: state.error!,
        onRetry: () => context.read<AppState>().init(),
      );
    }
    if (!state.langChosen) {
      return const LanguagePickerScreen();
    }

    final l = L10n.of(context);
    final reviewBadge = state.mistakes.length;

    final pages = <Widget>[
      HomeScreen(
        onOpenProfile: () => setState(() => _index = 4),
        onOpenStats: () => setState(() => _index = 3),
      ),
      const ChaptersScreen(),
      const StatsScreen(),
      SettingsScreen(onBackToHome: () => setState(() => _index = 0)),
    ];

    int stackIndexFor(int navIndex) => switch (navIndex) {
          0 => 0,
          1 => 1,
          3 => 2,
          4 => 3,
          _ => 0,
        };

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: IndexedStack(
        index: stackIndexFor(_index),
        children: pages,
      ),
      extendBody: true,
      bottomNavigationBar: _BottomNav(
        index: _index,
        reviewBadge: reviewBadge,
        labels: [
          l.navHome,
          l.navChapters,
          l.navQuiz,
          l.navStats,
          l.navProfile,
        ],
        onTap: (i) {
          AppHaptics.selection(context);
          if (i == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QuizScreen(title: l.quizTitle),
              ),
            );
            return;
          }
          setState(() => _index = i);
        },
        onCenterLongPress: () {
          AppHaptics.medium(context);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ExamScreen()),
          );
        },
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.index,
    required this.labels,
    required this.onTap,
    required this.onCenterLongPress,
    required this.reviewBadge,
  });

  final int index;
  final List<String> labels;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterLongPress;
  final int reviewBadge;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 10 + (bottom > 0 ? 0 : 6)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: AppLayout.navHeight + bottom,
            padding: EdgeInsets.only(bottom: bottom, left: 4, right: 4),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.strokeStrong),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A0B1220),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: labels[0],
                  selected: index == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.menu_book_rounded,
                  label: labels[1],
                  selected: index == 1,
                  onTap: () => onTap(1),
                ),
                _CenterQuizButton(
                  label: labels[2],
                  onTap: () => onTap(2),
                  onLongPress: onCenterLongPress,
                ),
                _NavItem(
                  icon: Icons.insights_rounded,
                  label: labels[3],
                  selected: index == 3,
                  onTap: () => onTap(3),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: labels[4],
                  selected: index == 4,
                  badge: reviewBadge > 0 ? reviewBadge : null,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterQuizButton extends StatelessWidget {
  const _CenterQuizButton({
    required this.label,
    required this.onTap,
    required this.onLongPress,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.neonGradient,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.emeraldGlow,
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: AppLayout.navHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: selected ? AppColors.emerald : AppColors.textMuted,
                    ),
                    if (badge != null)
                      Positioned(
                        right: -8,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.coral,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge! > 99 ? '99+' : '$badge',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? AppColors.emerald : AppColors.textMuted,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: selected ? 16 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.emerald,
                    borderRadius: BorderRadius.circular(99),
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
