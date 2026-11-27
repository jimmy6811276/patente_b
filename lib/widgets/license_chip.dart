import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/license_category.dart';
import '../theme/app_colors.dart';

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
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: LicenseCategory.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
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
    final subtitle = isEnglish ? category.nameEn : category.nameIt;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.neonGradient : null,
          color: selected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : category.isPlayable
                    ? AppColors.emerald.withValues(alpha: 0.35)
                    : AppColors.stroke,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: AppColors.neonGlow,
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x100B1220),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.code,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : AppColors.ink,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppColors.textMuted,
              ),
            ),
            if (!category.isPlayable) ...[
              const SizedBox(height: 3),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.55)
                      : AppColors.amber.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
