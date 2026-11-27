import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ReadinessRing extends StatefulWidget {
  const ReadinessRing({
    super.key,
    required this.progress,
    this.size = 220,
    this.label = 'Pronto per l\'esame',
  });

  final double progress;
  final double size;
  final String label;

  @override
  State<ReadinessRing> createState() => _ReadinessRingState();
}

class _ReadinessRingState extends State<ReadinessRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final p = widget.progress * _anim.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.neon.withValues(alpha: 0.28 * p.clamp(0.2, 1)),
                blurRadius: 48,
                spreadRadius: 4,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _RingPainter(progress: p),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(p * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -2,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: widget.size * 0.52,
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const stroke = 16.0;

    // Inner disc
    canvas.drawCircle(
      center,
      radius - 10,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF1A2A48),
            AppColors.navyMid.withValues(alpha: 0.4),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    final track = Paint()
      ..color = const Color(0x22FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);

    final glow = Paint()
      ..shader = AppColors.ringGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final arc = Paint()
      ..shader = AppColors.ringGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweep, false, glow);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);

    // End-cap highlight
    if (progress > 0.02) {
      final angle = -math.pi / 2 + sweep;
      final tip = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(
        tip,
        7,
        Paint()
          ..color = Colors.white
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      canvas.drawCircle(tip, 4.5, Paint()..color = AppColors.neonSoft);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Circular countdown used on exam screen.
class TimerRing extends StatelessWidget {
  const TimerRing({
    super.key,
    required this.progress,
    required this.label,
    this.size = 120,
  });

  final double progress;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TimerPainter(progress: progress),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Text(
                'rimanente',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  _TimerPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = const Color(0x22FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress.clamp(0, 1),
      false,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.gold, AppColors.orange],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerPainter old) => old.progress != progress;
}
