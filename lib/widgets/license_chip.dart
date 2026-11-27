import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/license_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';

extension LicenseChipLabel on LicenseCategory {
  /// Short chip label — never truncated mid-word.
  String shortName(bool isEnglish) => switch (this) {
        LicenseCategory.am => isEnglish ? 'Moped' : 'Moped',
        LicenseCategory.a => 'Moto',
        LicenseCategory.b => isEnglish ? 'Car' : 'Auto',
        LicenseCategory.c => isEnglish ? 'Truck' : 'Camion',
        LicenseCategory.cqc => 'Pro',
        LicenseCategory.d => 'Bus',
        LicenseCategory.revisione => 'Rev',
      };
}

class LicenseChipStrip extends StatelessWidget {
  const LicenseChipStrip({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.isEnglish,
  });

  final LicenseCategory selected;
  final ValueChanged<LicenseCategory> onSelected;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Stack(
        children: [
          ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.pagePad),
            itemCount: LicenseCategory.values.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = LicenseCategory.values[i];
              return LicenseChip(
                category: cat,
                selected: selected == cat,
                isEnglish: isEnglish,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(cat);
                },
              );
            },
          ),
          // Right fade scroll hint
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 28,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.canvas.withValues(alpha: 0),
                      AppColors.canvas,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LicenseChip extends StatelessWidget {
  const LicenseChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
    required this.isEnglish,
  });

  final LicenseCategory category;
  final bool selected;
  final VoidCallback onTap;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${category.code} ${category.shortName(isEnglish)}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 76,
            height: 72,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.emerald : AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? AppColors.emerald
                    : category.isPlayable
                        ? AppColors.emerald.withValues(alpha: 0.35)
                        : AppColors.stroke,
              ),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: AppColors.emeraldGlow,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x0C0B1220),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.code,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppColors.ink,
                    letterSpacing: 0,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category.shortName(isEnglish),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white.withValues(alpha: 0.92)
                        : AppColors.textMuted,
                    letterSpacing: 0,
                    height: 1.1,
                  ),
                ),
                if (!category.isPlayable) ...[
                  const SizedBox(height: 3),
                  Text(
                    isEnglish ? 'Soon' : 'Presto',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.75)
                          : AppColors.amber,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
