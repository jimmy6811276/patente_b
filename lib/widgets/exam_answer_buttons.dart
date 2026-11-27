import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../utils/app_haptics.dart';

/// Official-style VERO / FALSO controls.
///
/// [examMode] = true → selection only (neutral highlight). Never looks like a
/// correct/incorrect result — matches the real Italian theory exam software.
/// [examMode] = false → study quiz styling; after [result] is set, shows
/// green/red outcome feedback.
class ExamAnswerButtons extends StatelessWidget {
  const ExamAnswerButtons({
    super.key,
    required this.onTrue,
    required this.onFalse,
    this.selected,
    this.result,
    this.enabled = true,
    this.examMode = false,
    this.height = 72,
  });

  final VoidCallback onTrue;
  final VoidCallback onFalse;
  final bool? selected;

  /// When non-null in study mode, paints correct/incorrect feedback.
  final bool? result;
  final bool enabled;

  /// Exam simulation: no result colours, no dimming the other option as wrong.
  final bool examMode;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Row(
      children: [
        Expanded(
          child: _ExamAnswerButton(
            isTrue: true,
            label: l.trueLabel,
            selected: selected == true,
            examMode: examMode,
            result: result,
            enabled: enabled,
            height: height,
            onTap: onTrue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ExamAnswerButton(
            isTrue: false,
            label: l.falseLabel,
            selected: selected == false,
            examMode: examMode,
            result: result,
            enabled: enabled,
            height: height,
            onTap: onFalse,
          ),
        ),
      ],
    );
  }
}

class _ExamAnswerButton extends StatelessWidget {
  const _ExamAnswerButton({
    required this.isTrue,
    required this.label,
    required this.selected,
    required this.examMode,
    required this.result,
    required this.enabled,
    required this.height,
    required this.onTap,
  });

  final bool isTrue;
  final String label;
  final bool selected;
  final bool examMode;
  final bool? result;
  final bool enabled;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = isTrue ? const Color(0xFF0F7A4D) : const Color(0xFFC43C3C);
    final letter = isTrue ? 'V' : 'F';

    // Exam: always keep V green / F red as identity, but selection is a
    // neutral ink ring — never a “you are correct/wrong” fill.
    late final Color bg;
    late final Color fg;
    late final Color border;
    late final double borderWidth;

    if (examMode) {
      if (selected) {
        bg = const Color(0xFF1B2430);
        fg = Colors.white;
        border = const Color(0xFF1B2430);
        borderWidth = 2.5;
      } else {
        bg = Colors.white;
        fg = brand;
        border = brand.withValues(alpha: 0.45);
        borderWidth = 1.6;
      }
    } else if (result != null) {
      final isCorrectChoice = result == isTrue;
      final wasPicked = selected;
      if (isCorrectChoice) {
        bg = const Color(0xFF0F7A4D);
        fg = Colors.white;
        border = const Color(0xFF0F7A4D);
        borderWidth = 2;
      } else if (wasPicked) {
        bg = const Color(0xFFC43C3C);
        fg = Colors.white;
        border = const Color(0xFFC43C3C);
        borderWidth = 2;
      } else {
        bg = AppColors.canvasDeep;
        fg = AppColors.textMuted;
        border = AppColors.stroke;
        borderWidth = 1;
      }
    } else if (selected) {
      bg = brand;
      fg = Colors.white;
      border = brand;
      borderWidth = 2;
    } else {
      bg = isTrue ? const Color(0xFFE8F6EF) : const Color(0xFFFCECEE);
      fg = brand;
      border = brand.withValues(alpha: 0.35);
      borderWidth = 1.5;
    }

    return Semantics(
      button: true,
      label: label,
      selected: selected,
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled
              ? () {
                  AppHaptics.selection(context);
                  onTap();
                }
              : null,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: height,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border, width: borderWidth),
              boxShadow: selected && examMode
                  ? const [
                      BoxShadow(
                        color: Color(0x330B1220),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x0F0B1220),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _VfBadge(
                  letter: letter,
                  accent: examMode && selected ? Colors.white : (selected && !examMode ? Colors.white : brand),
                  fill: examMode && selected
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white,
                  ring: examMode && selected ? Colors.white : brand,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: fg,
                    ),
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

class _VfBadge extends StatelessWidget {
  const _VfBadge({
    required this.letter,
    required this.accent,
    required this.fill,
    required this.ring,
  });

  final String letter;
  final Color accent;
  final Color fill;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(color: ring, width: 2.5),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: accent,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
