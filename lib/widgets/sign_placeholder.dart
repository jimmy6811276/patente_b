import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// High-fidelity triangular danger-sign mock (replace with real assets later).
class SignPlaceholder extends StatelessWidget {
  const SignPlaceholder({
    super.key,
    this.label = 'Dosso',
    this.height = 180,
  });

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
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Soft glow behind sign
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          CustomPaint(
            size: const Size(128, 118),
            painter: _TriangleSignPainter(),
          ),
        ],
      ),
    );
  }
}

class _TriangleSignPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 2)
      ..lineTo(size.width - 2, size.height - 2)
      ..lineTo(2, size.height - 2)
      ..close();

    // Drop shadow
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

    // Inner white margin
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

    // Bump silhouette
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoadScenePlaceholder extends StatelessWidget {
  const RoadScenePlaceholder({super.key, this.height = 190});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3A5A7A),
            Color(0xFF1E3348),
            Color(0xFF0E1824),
          ],
        ),
        border: Border.all(color: AppColors.stroke),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Sky haze
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: height * 0.4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF7EB6D9).withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomPaint(
                size: Size(MediaQuery.sizeOf(context).width, height * 0.62),
                painter: _RoadPainter(),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Scenario autostrada',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Path()
      ..moveTo(size.width * 0.22, 0)
      ..lineTo(size.width * 0.78, 0)
      ..lineTo(size.width * 1.05, size.height)
      ..lineTo(size.width * -0.05, size.height)
      ..close();
    canvas.drawPath(road, Paint()..color = const Color(0xFF2A2A2E));

    // Shoulder
    canvas.drawPath(
      road,
      Paint()
        ..color = const Color(0xFF3D3D42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    final dash = Paint()
      ..color = const Color(0xFFFFD60A)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final y = 8.0 + i * (size.height / 5.5);
      final w = 4.0 + i * 1.2;
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + w * 2),
        dash,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Chapter thumb — real ministerial sign when available, else numbered badge.
class ChapterBadge extends StatelessWidget {
  const ChapterBadge({
    super.key,
    required this.id,
    required this.color,
    this.imageAsset,
    this.size = 56,
  });

  final int id;
  final Color color;
  final String? imageAsset;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.3);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: imageAsset != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: Colors.white),
                  Padding(
                    padding: EdgeInsets.all(size * 0.1),
                    child: Image.asset(
                      imageAsset!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          _ChapterNumber(id: id, color: color),
                    ),
                  ),
                  Positioned(
                    right: 3,
                    bottom: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$id'.padLeft(2, '0'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _ChapterNumber(id: id, color: color),
      ),
    );
  }
}

class _ChapterNumber extends StatelessWidget {
  const _ChapterNumber({required this.id, required this.color});
  final int id;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$id'.padLeft(2, '0'),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: color,
          fontSize: 15,
        ),
      ),
    );
  }
}
