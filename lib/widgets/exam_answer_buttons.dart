import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../utils/app_haptics.dart';

/// Official-style VERO / FALSO controls used in Italian theory exams:
/// green circular **V** and red circular **F**, with the full label beside.
class ExamAnswerButtons extends StatelessWidget {
  const ExamAnswerButtons({
    super.key,
    required this.onTrue,
    required this.onFalse,
    this.selected,
    this.enabled = true,
    this.height = 72,
  });

  final VoidCallback onTrue;
  final VoidCallback onFalse;
  final bool? selected;
  final bool enabled;
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
            dimmed: selected != null && selected != true,
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
            dimmed: selected != null && selected != false,
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
    required this.dimmed,
    required this.enabled,
    required this.height,
    required this.onTap,
  });

  final bool isTrue;
  final String label;
  final bool selected;
  final bool dimmed;
  final bool enabled;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = isTrue ? const Color(0xFF0F7A4D) : const Color(0xFFC43C3C);
    final softBg = isTrue ? const Color(0xFFE8F6EF) : const Color(0xFFFCECEE);
    final letter = isTrue ? 'V' : 'F';

    final bg = selected
        ? accent
        : dimmed
            ? AppColors.canvasDeep
            : softBg;
    final fg = selected ? Colors.white : accent;
    final border = selected
        ? accent
        : dimmed
            ? AppColors.stroke
            : accent.withValues(alpha: 0.35);

    return Semantics(
      button: true,
      label: label,
      enabled: enabled || selected,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: dimmed ? 0.45 : 1,
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
            child: Ink(
              height: height,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border, width: selected ? 2 : 1.5),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.28),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
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
                    accent: selected ? Colors.white : accent,
                    fill: selected ? accent.withValues(alpha: 0.2) : Colors.white,
                    ring: selected ? Colors.white : accent,
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
      ),
    );
  }
}

/// Circular V / F badge matching ministerial quiz software.
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
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
