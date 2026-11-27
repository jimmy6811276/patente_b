import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_lang.dart';
import '../theme/app_colors.dart';

/// Shown once, before anything else, so the very first screen is already in a
/// language the user understands.
///
/// Deliberately bilingual at the same time: both options are labelled in their
/// own language, which is the only way to be readable to someone who speaks
/// neither.
class LanguagePickerScreen extends StatelessWidget {
  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.bgGradient)),
          Positioned(
            top: -90,
            right: -70,
            child: _Orb(size: 280, color: AppColors.blue.withValues(alpha: 0.14)),
          ),
          Positioned(
            bottom: -60,
            left: -90,
            child: _Orb(size: 300, color: AppColors.emerald.withValues(alpha: 0.12)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.neonGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(color: AppColors.neonGlow, blurRadius: 26, offset: Offset(0, 10)),
                      ],
                    ),
                    child: const Icon(Icons.translate_rounded, color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Patente B',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scegli la lingua · Choose your language',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: AppColors.textSecondary.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _LangOption(
                    lang: AppLang.it,
                    flag: '🇮🇹',
                    title: 'Italiano',
                    subtitle: 'Interfaccia e contenuti in italiano',
                    selected: state.lang == AppLang.it,
                    onTap: () => _choose(context, AppLang.it),
                  ),
                  const SizedBox(height: 12),
                  _LangOption(
                    lang: AppLang.en,
                    flag: '🇬🇧',
                    title: 'English',
                    subtitle: 'Interface and content in English',
                    selected: state.lang == AppLang.en,
                    onTap: () => _choose(context, AppLang.en),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '100% offline · nessun dato lascia il dispositivo',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _choose(BuildContext context, AppLang lang) {
    HapticFeedback.selectionClick();
    context.read<AppState>().setLanguage(lang);
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.lang,
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final AppLang lang;
  final String flag;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.emeraldDim : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.emerald : AppColors.stroke,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? null
              : const [
                  BoxShadow(color: Color(0x100B1220), blurRadius: 14, offset: Offset(0, 6)),
                ],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.emerald : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.emerald : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
