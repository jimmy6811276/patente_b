import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/strings.dart';
import '../models/license_category.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';

class LicenseComingSoonScreen extends StatelessWidget {
  const LicenseComingSoonScreen({super.key, required this.category});

  final LicenseCategory category;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final name = l.isEn ? category.nameEn : category.nameIt;

    return PremiumScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            const Spacer(),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: AppColors.electricGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.electricGlow,
                      blurRadius: 28,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    category.code,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Patente ${category.code}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                name,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.orange.withValues(alpha: 0.35)),
                ),
                child: Text(
                  l.comingSoonTitle,
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l.comingSoonBody(category.code),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            NeonButton(
              label: l.backToB,
              icon: Icons.directions_car_rounded,
              onPressed: () async {
                await context.read<AppState>().setSelectedLicense(LicenseCategory.b);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                l.playableNow,
                style: const TextStyle(fontSize: 12, color: AppColors.neonSoft),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
