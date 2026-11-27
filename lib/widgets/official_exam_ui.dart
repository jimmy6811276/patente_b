import 'package:flutter/material.dart';

import '../theme/exam_tokens.dart';
import '../utils/app_haptics.dart';

/// Italian flag strip — top of every Motorizzazione screen.
class ExamTricolorBar extends StatelessWidget {
  const ExamTricolorBar({super.key, this.height = 3});
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: const Row(
        children: [
          Expanded(child: ColoredBox(color: ExamTokens.italiaGreen)),
          Expanded(child: ColoredBox(color: ExamTokens.italiaWhite)),
          Expanded(child: ColoredBox(color: ExamTokens.italiaRed)),
        ],
      ),
    );
  }
}

/// Full-screen Motorizzazione shell (grey-blue station background).
class ExamShell extends StatelessWidget {
  const ExamShell({
    super.key,
    required this.child,
    this.safeTop = true,
    this.safeBottom = true,
  });

  final Widget child;
  final bool safeTop;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExamTokens.bgMid,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: ExamTokens.shellGradient),
        child: SafeArea(
          top: safeTop,
          bottom: safeBottom,
          child: Column(
            children: [
              const ExamTricolorBar(),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class ExamBezel extends StatelessWidget {
  const ExamBezel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: ExamTokens.bezelGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ExamTokens.panelBorder, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E142846),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ExamMitHeader extends StatelessWidget {
  const ExamMitHeader({
    super.key,
    required this.title,
    required this.timerLabel,
    this.timerHot = false,
    this.onClose,
    this.trailing,
  });

  final String title;
  final String timerLabel;
  final bool timerHot;
  final VoidCallback? onClose;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xE6E7EEF6),
        border: Border(bottom: BorderSide(color: ExamTokens.panelBorder.withValues(alpha: 0.7))),
      ),
      child: Row(
        children: [
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, color: ExamTokens.inkSoft),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MINISTERO DELLE INFRASTRUTTURE E DEI TRASPORTI',
                  style: ExamTokens.mitEyebrow,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ExamTokens.title,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: timerHot ? const Color(0xFFFFE4E4) : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: timerHot ? ExamTokens.falso : ExamTokens.panelBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: timerHot ? ExamTokens.falso : ExamTokens.ink,
                ),
                const SizedBox(width: 6),
                Text(
                  timerLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: timerHot ? const Color(0xFFB42323) : ExamTokens.ink,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// Official touchscreen circles — V (vero) / F (falso).
class ExamCircleButtons extends StatelessWidget {
  const ExamCircleButtons({
    super.key,
    required this.onTrue,
    required this.onFalse,
    this.selected,
    this.result,
    this.enabled = true,
    this.size = 88,
  });

  final VoidCallback onTrue;
  final VoidCallback onFalse;
  final bool? selected;
  final bool? result;
  final bool enabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Circle(
          letter: 'V',
          isVero: true,
          selected: selected == true,
          result: result,
          enabled: enabled,
          size: size,
          onTap: onTrue,
        ),
        SizedBox(width: size > 80 ? 36 : 24),
        _Circle(
          letter: 'F',
          isVero: false,
          selected: selected == false,
          result: result,
          enabled: enabled,
          size: size,
          onTap: onFalse,
        ),
      ],
    );
  }
}

class _Circle extends StatefulWidget {
  const _Circle({
    required this.letter,
    required this.isVero,
    required this.selected,
    required this.result,
    required this.enabled,
    required this.size,
    required this.onTap,
  });

  final String letter;
  final bool isVero;
  final bool selected;
  final bool? result;
  final bool enabled;
  final double size;
  final VoidCallback onTap;

  @override
  State<_Circle> createState() => _CircleState();
}

class _CircleState extends State<_Circle> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final brand = widget.isVero ? ExamTokens.vero : ExamTokens.falso;
    final soft = widget.isVero ? ExamTokens.veroSoft : ExamTokens.falsoSoft;

    Color bg = soft;
    Color fg = brand;
    Color border = const Color(0xFF2A3C55);

    if (widget.result != null) {
      final isCorrectChoice = widget.result == widget.isVero;
      if (isCorrectChoice) {
        bg = ExamTokens.vero;
        fg = Colors.white;
        border = const Color(0xFF0F6B3C);
      } else if (widget.selected) {
        bg = ExamTokens.falso;
        fg = Colors.white;
        border = const Color(0xFF8F2222);
      } else {
        bg = const Color(0xFFE8EEF4);
        fg = ExamTokens.muted;
        border = ExamTokens.gridBorder;
      }
    } else if (widget.selected) {
      bg = brand;
      fg = Colors.white;
      border = widget.isVero ? const Color(0xFF0F6B3C) : const Color(0xFF8F2222);
    }

    return Semantics(
      button: true,
      label: widget.isVero ? 'Vero' : 'Falso',
      selected: widget.selected,
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: widget.enabled
            ? (_) {
                setState(() => _pressed = false);
                AppHaptics.selection(context);
                widget.onTap();
              }
            : null,
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.size,
          height: widget.size,
          transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 4),
            boxShadow: [
              BoxShadow(
                color: const Color(0x33202337),
                blurRadius: 0,
                offset: Offset(0, _pressed ? 3 : 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.letter,
            style: TextStyle(
              fontSize: widget.size * 0.42,
              fontWeight: FontWeight.w900,
              color: fg,
              height: 1,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class ExamQuestionGrid extends StatelessWidget {
  const ExamQuestionGrid({
    super.key,
    required this.count,
    required this.current,
    required this.isAnswered,
    required this.onSelect,
    this.isFlagged,
  });

  final int count;
  final int current;
  final bool Function(int index) isAnswered;
  final bool Function(int index)? isFlagged;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < count; i++)
          _GridCell(
            number: i + 1,
            current: i == current,
            answered: isAnswered(i),
            flagged: isFlagged?.call(i) ?? false,
            onTap: () => onSelect(i),
          ),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.number,
    required this.current,
    required this.answered,
    required this.flagged,
    required this.onTap,
  });

  final int number;
  final bool current;
  final bool answered;
  final bool flagged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: answered ? ExamTokens.gridAnswered : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: current
                  ? ExamTokens.flag
                  : answered
                      ? const Color(0xFF163A6A)
                      : flagged
                          ? ExamTokens.flag
                          : ExamTokens.gridBorder,
              width: current || flagged ? 2.5 : 1.5,
            ),
          ),
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: answered ? Colors.white : ExamTokens.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}

class ExamNavBar extends StatelessWidget {
  const ExamNavBar({
    super.key,
    required this.onPrevious,
    required this.onNext,
    this.onSummary,
    this.canPrevious = true,
    this.nextLabel = 'Successiva',
    this.previousLabel = 'Precedente',
    this.summaryLabel = 'Riepilogo',
  });

  final VoidCallback? onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onSummary;
  final bool canPrevious;
  final String nextLabel;
  final String previousLabel;
  final String summaryLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: canPrevious ? onPrevious : null,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(previousLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: ExamTokens.inkSoft,
              side: const BorderSide(color: ExamTokens.panelBorder),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        if (onSummary != null) ...[
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onSummary,
            style: OutlinedButton.styleFrom(
              foregroundColor: ExamTokens.label,
              side: const BorderSide(color: ExamTokens.label),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(summaryLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(nextLabel),
            style: FilledButton.styleFrom(
              backgroundColor: ExamTokens.label,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class ExamSignFrame extends StatelessWidget {
  const ExamSignFrame({super.key, required this.child, this.height = 160});
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ExamTokens.panelBorder),
      ),
      child: child,
    );
  }
}
