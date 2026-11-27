import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return PremiumScaffold(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              _skeleton(width: 120, height: 14),
              const Spacer(),
              _skeleton(width: 48, height: 48, radius: 16),
            ],
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: _skeleton(width: 190, height: 30),
          ),
          const SizedBox(height: 30),
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
                border: Border.all(color: AppColors.stroke),
              ),
              child: const Center(
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.neon,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _skeleton(height: 72, radius: 20)),
              const SizedBox(width: 12),
              Expanded(child: _skeleton(height: 72, radius: 20)),
            ],
          ),
          const SizedBox(height: 14),
          _skeleton(height: 74, radius: 22),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _skeleton(height: 140, radius: 24)),
              const SizedBox(width: 14),
              Expanded(child: _skeleton(height: 140, radius: 24)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l.preparingDb,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _skeleton({
    double? width,
    required double height,
    double radius = 12,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.stroke),
      ),
    );
  }
}

class DbErrorScreen extends StatelessWidget {
  const DbErrorScreen({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return PremiumScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.red.withValues(alpha: 0.35)),
              ),
              child: const Icon(Icons.storage_rounded, color: AppColors.red, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              l.dbUnavailable,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.electric,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(l.retryBtn, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
