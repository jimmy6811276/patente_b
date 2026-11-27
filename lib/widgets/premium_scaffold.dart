import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Light study canvas with soft ambient washes.
class PremiumScaffold extends StatelessWidget {
  const PremiumScaffold({
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
      backgroundColor: AppColors.canvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.bgGradient)),
          Positioned(
            top: -90,
            right: -50,
            child: _Orb(size: 240, color: AppColors.emerald.withValues(alpha: 0.12)),
          ),
          Positioned(
            top: 180,
            left: -80,
            child: _Orb(size: 220, color: AppColors.blue.withValues(alpha: 0.10)),
          ),
          SafeArea(
            top: safeTop,
            bottom: safeBottom,
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: AppColors.ink),
              child: IconTheme.merge(
                data: const IconThemeData(color: AppColors.inkSoft),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.onTap,
    this.gradient,
    this.borderColor,
    this.glow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? borderColor;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.surface : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppColors.stroke),
        boxShadow: [
          BoxShadow(
            color: glow ?? const Color(0x140B1220),
            blurRadius: glow == null ? 18 : 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: body,
      ),
    );
  }
}

class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 54,
    this.gradient = AppColors.neonGradient,
    this.glow = AppColors.neonGlow,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final double height;
  final Gradient gradient;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: glow, blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
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
