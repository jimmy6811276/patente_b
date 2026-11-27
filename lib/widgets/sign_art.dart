import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Fully offline vector road-sign illustration.
/// Chapter-aware so every question shows a relevant Italian sign shape.
class SignArt extends StatelessWidget {
  const SignArt({
    super.key,
    required this.chapterId,
    this.label = 'Segnale',
    this.height = 178,
  });

  final int chapterId;
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C2C4E), Color(0xFF0D1528)],
        ),
        border: Border.all(color: AppColors.strokeStrong),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Text(
                'CAP. ${chapterId.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Glow halo
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _accent.withValues(alpha: 0.20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          CustomPaint(
            size: const Size(132, 122),
            painter: _SignPainter(chapterId: chapterId),
          ),
        ],
      ),
    );
  }

  Color get _accent {
    switch (chapterId) {
      case 2:
        return const Color(0xFFFFC107);
      case 3:
        return AppColors.red;
      case 4:
        return AppColors.electric;
      case 5:
        return AppColors.orange;
      case 6:
        return AppColors.neon;
      case 7:
        return AppColors.gold;
      case 14:
        return AppColors.pink;
      default:
        return AppColors.electricSoft;
    }
  }
}

class _SignPainter extends CustomPainter {
  _SignPainter({required this.chapterId});
  final int chapterId;

  @override
  void paint(Canvas canvas, Size size) {
    switch (chapterId) {
      case 2:
        _warningTriangle(canvas, size);
      case 3:
        _prohibitionCircle(canvas, size);
      case 4:
        _mandatoryCircle(canvas, size);
      case 5:
        _prioritySign(canvas, size);
      case 6:
        _roadMarkings(canvas, size);
      case 7:
        _trafficLight(canvas, size);
      case 14:
        _intersection(canvas, size);
      default:
        _infoSquare(canvas, size);
    }
  }

  void _warningTriangle(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 2)
      ..lineTo(size.width - 2, size.height - 2)
      ..lineTo(2, size.height - 2)
      ..close();
    canvas.drawPath(
      path.shift(const Offset(0, 6)),
      Paint()
        ..color = Colors.black54
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE066), Color(0xFFFFC107)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    final inset = Path()
      ..moveTo(size.width / 2, 16)
      ..lineTo(size.width - 14, size.height - 12)
      ..lineTo(14, size.height - 12)
      ..close();
    canvas.drawPath(
      inset,
      Paint()
        ..color = const Color(0xFFFFF8DC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final bump = Path()
      ..moveTo(size.width * 0.26, size.height * 0.74)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.30,
        size.width * 0.74,
        size.height * 0.74,
      );
    canvas.drawPath(
      bump,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  void _prohibitionCircle(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.height / 2 - 6;
    canvas.drawCircle(
      c,
      r + 4,
      Paint()
        ..color = Colors.black54
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFF7F7F7));
    canvas.drawCircle(
      c,
      r - 2,
      Paint()
        ..color = const Color(0xFFD32F2F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: '50',
        style: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 52,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  void _mandatoryCircle(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.height / 2 - 6;
    canvas.drawCircle(
      c,
      r + 4,
      Paint()
        ..color = Colors.black54
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D8BFF), Color(0xFF0B4FC4)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = const Color(0xFFE9E9E9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    final arrow = Path()
      ..moveTo(c.dx, c.dy - r * 0.45)
      ..lineTo(c.dx + r * 0.42, c.dy + r * 0.25)
      ..lineTo(c.dx + r * 0.12, c.dy + r * 0.25)
      ..lineTo(c.dx + r * 0.12, c.dy + r * 0.55)
      ..lineTo(c.dx - r * 0.12, c.dy + r * 0.55)
      ..lineTo(c.dx - r * 0.12, c.dy + r * 0.25)
      ..lineTo(c.dx - r * 0.42, c.dy + r * 0.25)
      ..close();
    canvas.drawPath(arrow, Paint()..color = Colors.white);
  }

  void _prioritySign(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    // STOP octagon
    final r = size.height / 2 - 8;
    final oct = Path();
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 8 + i * math.pi / 4;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      if (i == 0) {
        oct.moveTo(p.dx, p.dy);
      } else {
        oct.lineTo(p.dx, p.dy);
      }
    }
    oct.close();
    canvas.drawPath(
      oct.shift(const Offset(0, 5)),
      Paint()
        ..color = Colors.black54
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawPath(
      oct,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawPath(
      oct,
      Paint()
        ..color = const Color(0xFFFFF3F3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'STOP',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  void _roadMarkings(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(8, 10, size.width - 16, size.height - 20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      Paint()..color = const Color(0xFF2A2A2E),
    );
    // Zebra
    for (var i = 0; i < 6; i++) {
      final w = (rect.width - 24) / 6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left + 12 + i * w + 3, rect.top + 20, w - 6, rect.height - 40),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFFEDEDED),
      );
    }
  }

  void _trafficLight(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 58, height: 112),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      body.shift(const Offset(0, 5)),
      Paint()
        ..color = Colors.black54
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFF1D1F24));
    canvas.drawRRect(
      body,
      Paint()
        ..color = const Color(0xFF3A3D44)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final lights = [
      (c.dy - 34, const Color(0xFFFF3B30)),
      (c.dy, const Color(0xFFFFD60A)),
      (c.dy + 34, const Color(0xFF2EE66D)),
    ];
    for (final l in lights) {
      canvas.drawCircle(
        Offset(c.dx, l.$1),
        15,
        Paint()
          ..color = l.$2.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawCircle(Offset(c.dx, l.$1), 14, Paint()..color = l.$2);
      canvas.drawCircle(
        Offset(c.dx - 4, l.$1 - 4),
        4,
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
    }
  }

  void _intersection(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final bg = Rect.fromCenter(center: c, width: 120, height: 120);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bg, const Radius.circular(16)),
      Paint()..color = const Color(0xFF22304D),
    );
    final road = Paint()..color = const Color(0xFF3A3A3E);
    canvas.drawRect(Rect.fromLTWH(0, c.dy - 16, size.width, 32), road);
    canvas.drawRect(Rect.fromLTWH(c.dx - 16, 0, 32, size.height), road);
    final dash = Paint()
      ..color = const Color(0xFFFFD60A)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      final x = 8.0 + i * 28;
      canvas.drawLine(Offset(x, c.dy), Offset(x + 12, c.dy), dash);
      canvas.drawLine(Offset(c.dx, 8.0 + i * 26), Offset(c.dx, 20.0 + i * 26), dash);
    }
    // Priority car
    final car = Rect.fromCenter(center: Offset(c.dx - 34, c.dy + 30), width: 26, height: 14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(car, const Radius.circular(4)),
      Paint()..color = AppColors.electricSoft,
    );
  }

  void _infoSquare(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 108,
      height: 108,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(0, 5)), const Radius.circular(14)),
      Paint()
        ..color = Colors.black54
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F7BFF), Color(0xFF0B3F9E)],
        ).createShader(rect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      Paint()
        ..color = const Color(0xFFE9E9E9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    final c = rect.center;
    canvas.drawLine(
      Offset(c.dx, c.dy - 26),
      Offset(c.dx, c.dy + 18),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(c.dx, c.dy + 34), 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _SignPainter oldDelegate) =>
      oldDelegate.chapterId != chapterId;
}
