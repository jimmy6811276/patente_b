import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import 'chapters_screen.dart';
import 'home_screen.dart';
import 'language_picker_screen.dart';
import 'loading_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    StatsScreen(),
    ChaptersScreen(),
    SettingsScreen(),
  ];

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

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: IndexedStack(index: _index, children: _pages),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.strokeStrong),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A0B1220),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: l.navHome,
                  selected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  icon: Icons.insights_rounded,
                  label: l.navStats,
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _NavItem(
                  icon: Icons.menu_book_rounded,
                  label: l.navChapters,
                  selected: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: l.navSettings,
                  selected: _index == 3,
                  onTap: () => setState(() => _index = 3),
                ),
              ],
            ),
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
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: selected ? AppColors.neonGradient : null,
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: AppColors.neonGlow,
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
