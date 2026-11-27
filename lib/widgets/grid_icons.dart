import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom vector icons for the advanced home action grid.
/// Placeholder-quality glyphs inspired by top patente apps — swap assets later.
enum HubIconKind {
  quiz,
  exam,
  chapters,
  mistakes,
  signs,
  hard,
  daily,
  fastTrack,
  bookmarks,
  quick,
  vocab,
  weak,
  stats,
  timed,
  mini,
}

class HubGridIcon extends StatelessWidget {
  const HubGridIcon({
    super.key,
    required this.kind,
    this.size = 28,
    this.color = Colors.white,
  });

  final HubIconKind kind;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HubIconPainter(kind: kind, color: color),
      ),
    );
  }
}

class _HubIconPainter extends CustomPainter {
  _HubIconPainter({required this.kind, required this.color});

  final HubIconKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (kind) {
      case HubIconKind.quiz:
        _quiz(canvas, size, p, fill);
      case HubIconKind.exam:
        _exam(canvas, size, p, fill);
      case HubIconKind.chapters:
        _chapters(canvas, size, p, fill);
      case HubIconKind.mistakes:
        _mistakes(canvas, size, p, fill);
      case HubIconKind.signs:
        _signs(canvas, size, p, fill);
      case HubIconKind.hard:
        _hard(canvas, size, p, fill);
      case HubIconKind.daily:
        _daily(canvas, size, p, fill);
      case HubIconKind.fastTrack:
        _fastTrack(canvas, size, p, fill);
      case HubIconKind.bookmarks:
        _bookmarks(canvas, size, p, fill);
      case HubIconKind.quick:
        _quick(canvas, size, p, fill);
      case HubIconKind.vocab:
        _vocab(canvas, size, p, fill);
      case HubIconKind.weak:
        _weak(canvas, size, p, fill);
      case HubIconKind.stats:
        _stats(canvas, size, p, fill);
      case HubIconKind.timed:
        _timed(canvas, size, p, fill);
      case HubIconKind.mini:
        _mini(canvas, size, p, fill);
    }
  }

  void _quiz(Canvas c, Size s, Paint p, Paint fill) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.18, s.height * 0.12, s.width * 0.64, s.height * 0.76),
      Radius.circular(s.width * 0.12),
    );
    c.drawRRect(r, p);
    c.drawCircle(Offset(s.width * 0.35, s.height * 0.38), s.width * 0.06, fill);
    c.drawLine(Offset(s.width * 0.48, s.height * 0.38), Offset(s.width * 0.72, s.height * 0.38), p);
    c.drawCircle(Offset(s.width * 0.35, s.height * 0.58), s.width * 0.06, fill);
    c.drawLine(Offset(s.width * 0.48, s.height * 0.58), Offset(s.width * 0.72, s.height * 0.58), p);
  }

  void _exam(Canvas c, Size s, Paint p, Paint fill) {
    final path = Path()
      ..moveTo(s.width * 0.5, s.height * 0.12)
      ..lineTo(s.width * 0.82, s.height * 0.28)
      ..lineTo(s.width * 0.82, s.height * 0.55)
      ..quadraticBezierTo(s.width * 0.82, s.height * 0.78, s.width * 0.5, s.height * 0.9)
      ..quadraticBezierTo(s.width * 0.18, s.height * 0.78, s.width * 0.18, s.height * 0.55)
      ..lineTo(s.width * 0.18, s.height * 0.28)
      ..close();
    c.drawPath(path, p);
    c.drawLine(Offset(s.width * 0.36, s.height * 0.52), Offset(s.width * 0.46, s.height * 0.64), p..strokeWidth = s.width * 0.1);
    c.drawLine(Offset(s.width * 0.46, s.height * 0.64), Offset(s.width * 0.68, s.height * 0.4), p);
  }

  void _chapters(Canvas c, Size s, Paint p, Paint fill) {
    final left = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.16, s.height * 0.2, s.width * 0.42, s.height * 0.62),
      Radius.circular(s.width * 0.06),
    );
    final right = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.42, s.height * 0.14, s.width * 0.42, s.height * 0.62),
      Radius.circular(s.width * 0.06),
    );
    c.drawRRect(left, p);
    c.drawRRect(right, p);
    c.drawLine(Offset(s.width * 0.52, s.height * 0.32), Offset(s.width * 0.74, s.height * 0.32), p);
    c.drawLine(Offset(s.width * 0.52, s.height * 0.46), Offset(s.width * 0.74, s.height * 0.46), p);
  }

  void _mistakes(Canvas c, Size s, Paint p, Paint fill) {
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.5), s.width * 0.34, p);
    c.drawLine(Offset(s.width * 0.35, s.height * 0.35), Offset(s.width * 0.65, s.height * 0.65), p..strokeWidth = s.width * 0.11);
    c.drawLine(Offset(s.width * 0.65, s.height * 0.35), Offset(s.width * 0.35, s.height * 0.65), p);
  }

  void _signs(Canvas c, Size s, Paint p, Paint fill) {
    final path = Path()
      ..moveTo(s.width * 0.5, s.height * 0.12)
      ..lineTo(s.width * 0.86, s.height * 0.78)
      ..lineTo(s.width * 0.14, s.height * 0.78)
      ..close();
    c.drawPath(path, p);
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.52), s.width * 0.055, fill);
    c.drawLine(Offset(s.width * 0.5, s.height * 0.6), Offset(s.width * 0.5, s.height * 0.7), p..strokeWidth = s.width * 0.1);
  }

  void _hard(Canvas c, Size s, Paint p, Paint fill) {
    final cx = s.width * 0.5;
    final cy = s.height * 0.48;
    final r = s.width * 0.28;
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 5;
      final a2 = a + math.pi / 5;
      final ox = cx + math.cos(a) * r;
      final oy = cy + math.sin(a) * r;
      final ix = cx + math.cos(a2) * r * 0.45;
      final iy = cy + math.sin(a2) * r * 0.45;
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    c.drawPath(path, p);
    c.drawLine(Offset(s.width * 0.28, s.height * 0.86), Offset(s.width * 0.72, s.height * 0.86), p);
  }

  void _daily(Canvas c, Size s, Paint p, Paint fill) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.18, s.height * 0.22, s.width * 0.64, s.height * 0.62),
      Radius.circular(s.width * 0.1),
    );
    c.drawRRect(r, p);
    c.drawLine(Offset(s.width * 0.18, s.height * 0.4), Offset(s.width * 0.82, s.height * 0.4), p);
    c.drawLine(Offset(s.width * 0.34, s.height * 0.14), Offset(s.width * 0.34, s.height * 0.28), p);
    c.drawLine(Offset(s.width * 0.66, s.height * 0.14), Offset(s.width * 0.66, s.height * 0.28), p);
    c.drawCircle(Offset(s.width * 0.4, s.height * 0.58), s.width * 0.05, fill);
    c.drawCircle(Offset(s.width * 0.56, s.height * 0.58), s.width * 0.05, fill);
  }

  void _fastTrack(Canvas c, Size s, Paint p, Paint fill) {
    final bolt = Path()
      ..moveTo(s.width * 0.55, s.height * 0.1)
      ..lineTo(s.width * 0.28, s.height * 0.52)
      ..lineTo(s.width * 0.48, s.height * 0.52)
      ..lineTo(s.width * 0.42, s.height * 0.9)
      ..lineTo(s.width * 0.74, s.height * 0.42)
      ..lineTo(s.width * 0.54, s.height * 0.42)
      ..close();
    c.drawPath(bolt, fill);
  }

  void _bookmarks(Canvas c, Size s, Paint p, Paint fill) {
    final path = Path()
      ..moveTo(s.width * 0.28, s.height * 0.12)
      ..lineTo(s.width * 0.72, s.height * 0.12)
      ..lineTo(s.width * 0.72, s.height * 0.88)
      ..lineTo(s.width * 0.5, s.height * 0.7)
      ..lineTo(s.width * 0.28, s.height * 0.88)
      ..close();
    c.drawPath(path, p);
  }

  void _quick(Canvas c, Size s, Paint p, Paint fill) {
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.5), s.width * 0.34, p);
    c.drawLine(Offset(s.width * 0.5, s.height * 0.5), Offset(s.width * 0.5, s.height * 0.28), p);
    c.drawLine(Offset(s.width * 0.5, s.height * 0.5), Offset(s.width * 0.7, s.height * 0.58), p);
  }

  void _vocab(Canvas c, Size s, Paint p, Paint fill) {
    final card = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.2, s.height * 0.18, s.width * 0.6, s.height * 0.64),
      Radius.circular(s.width * 0.1),
    );
    c.drawRRect(card, p);
    c.drawLine(Offset(s.width * 0.32, s.height * 0.42), Offset(s.width * 0.68, s.height * 0.42), p);
    c.drawLine(Offset(s.width * 0.36, s.height * 0.56), Offset(s.width * 0.64, s.height * 0.56), p);
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.3), s.width * 0.05, fill);
  }

  void _weak(Canvas c, Size s, Paint p, Paint fill) {
    c.drawLine(Offset(s.width * 0.2, s.height * 0.72), Offset(s.width * 0.38, s.height * 0.42), p);
    c.drawLine(Offset(s.width * 0.38, s.height * 0.42), Offset(s.width * 0.55, s.height * 0.58), p);
    c.drawLine(Offset(s.width * 0.55, s.height * 0.58), Offset(s.width * 0.8, s.height * 0.22), p);
    c.drawCircle(Offset(s.width * 0.8, s.height * 0.22), s.width * 0.06, fill);
  }

  void _stats(Canvas c, Size s, Paint p, Paint fill) {
    c.drawLine(Offset(s.width * 0.18, s.height * 0.82), Offset(s.width * 0.82, s.height * 0.82), p);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.22, s.height * 0.48, s.width * 0.14, s.height * 0.34),
        Radius.circular(s.width * 0.04),
      ),
      fill,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.43, s.height * 0.32, s.width * 0.14, s.height * 0.5),
        Radius.circular(s.width * 0.04),
      ),
      fill,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.64, s.height * 0.22, s.width * 0.14, s.height * 0.6),
        Radius.circular(s.width * 0.04),
      ),
      fill,
    );
  }

  void _timed(Canvas c, Size s, Paint p, Paint fill) {
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.52), s.width * 0.3, p);
    c.drawLine(Offset(s.width * 0.38, s.height * 0.18), Offset(s.width * 0.62, s.height * 0.18), p);
    c.drawLine(Offset(s.width * 0.5, s.height * 0.18), Offset(s.width * 0.5, s.height * 0.28), p);
    c.drawLine(Offset(s.width * 0.5, s.height * 0.52), Offset(s.width * 0.5, s.height * 0.38), p);
    c.drawLine(Offset(s.width * 0.5, s.height * 0.52), Offset(s.width * 0.66, s.height * 0.52), p);
  }

  void _mini(Canvas c, Size s, Paint p, Paint fill) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.22, s.height * 0.2, s.width * 0.56, s.height * 0.6),
      Radius.circular(s.width * 0.1),
    );
    c.drawRRect(r, p);
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.48), s.width * 0.12, p);
    c.drawLine(Offset(s.width * 0.5, s.height * 0.48), Offset(s.width * 0.5, s.height * 0.4), p);
  }

  @override
  bool shouldRepaint(covariant _HubIconPainter old) =>
      old.kind != kind || old.color != color;
}
