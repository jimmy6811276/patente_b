import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../models/translation_mode.dart';
import '../theme/app_colors.dart';

/// Renders a quiz/exam statement with off / sentence / word-by-word translation.
class BilingualStatement extends StatelessWidget {
  const BilingualStatement({
    super.key,
    required this.question,
    required this.mode,
    this.primaryStyle,
    this.secondaryStyle,
  });

  final QuizQuestion question;
  final TranslationMode mode;
  final TextStyle? primaryStyle;
  final TextStyle? secondaryStyle;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final primary = l.questionText(question);
    final secondary = l.questionTextSecondary(question);

    final basePrimary = primaryStyle ??
        const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          height: 1.35,
          letterSpacing: 0,
          color: AppColors.ink,
        );
    final baseSecondary = secondaryStyle ??
        const TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textSecondary,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mode == TranslationMode.word)
          _WordByWord(primary: primary, secondary: secondary, primaryStyle: basePrimary)
        else
          Text(primary, style: basePrimary),
        if (mode == TranslationMode.sentence) ...[
          const SizedBox(height: 10),
          Text(secondary, style: baseSecondary),
        ],
        if (mode == TranslationMode.word) ...[
          const SizedBox(height: 10),
          Text(
            l.wordModeHint,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class _WordByWord extends StatelessWidget {
  const _WordByWord({
    required this.primary,
    required this.secondary,
    required this.primaryStyle,
  });

  final String primary;
  final String secondary;
  final TextStyle primaryStyle;

  @override
  Widget build(BuildContext context) {
    final pWords = primary.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final sWords = secondary.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    return Wrap(
      spacing: 6,
      runSpacing: 10,
      children: [
        for (var i = 0; i < pWords.length; i++)
          _WordPair(
            top: pWords[i],
            bottom: i < sWords.length ? sWords[i] : '·',
            primaryStyle: primaryStyle,
          ),
      ],
    );
  }
}

class _WordPair extends StatelessWidget {
  const _WordPair({
    required this.top,
    required this.bottom,
    required this.primaryStyle,
  });

  final String top;
  final String bottom;
  final TextStyle primaryStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.canvasDeep,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            top,
            style: primaryStyle.copyWith(fontSize: 16, height: 1.2),
          ),
          const SizedBox(height: 3),
          Text(
            bottom,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.blue,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact control to cycle translation mode in quiz/exam toolbars.
class TranslationModeChip extends StatelessWidget {
  const TranslationModeChip({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final TranslationMode mode;
  final ValueChanged<TranslationMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final label = switch (mode) {
      TranslationMode.off => l.translationOffShort,
      TranslationMode.sentence => l.translationSentenceShort,
      TranslationMode.word => l.translationWordShort,
    };
    final icon = switch (mode) {
      TranslationMode.off => Icons.translate_rounded,
      TranslationMode.sentence => Icons.short_text_rounded,
      TranslationMode.word => Icons.space_bar_rounded,
    };

    return Material(
      color: AppColors.electric.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final next = switch (mode) {
            TranslationMode.off => TranslationMode.sentence,
            TranslationMode.sentence => TranslationMode.word,
            TranslationMode.word => TranslationMode.off,
          };
          onChanged(next);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.electric),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.electric,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
