import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Full-bleed midnight canvas with soft neon ambient orbs.
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
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.bgGradient)),
          // Ambient neon glow — top right
          Positioned(
            top: -80,
            right: -60,
            child: _Orb(
              size: 260,
              color: AppColors.electric.withValues(alpha: 0.22),
            ),
          ),
          // Ambient neon glow — mid left
          Positioned(
            top: 220,
            left: -100,
            child: _Orb(
              size: 280,
              color: AppColors.neon.withValues(alpha: 0.10),
            ),
          ),
          // Soft pink accent bottom
          Positioned(
            bottom: 40,
            right: -40,
            child: _Orb(
              size: 180,
              color: AppColors.pink.withValues(alpha: 0.08),
            ),
          ),
          SafeArea(
            top: safeTop,
            bottom: safeBottom,
            child: child,
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
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
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
    final body = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                ),
            color: gradient == null ? AppColors.navyGlass : null,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor ?? AppColors.stroke),
            boxShadow: [
              if (glow != null)
                BoxShadow(color: glow!, blurRadius: 28, offset: const Offset(0, 10)),
              const BoxShadow(
                color: Color(0x66000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
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
    this.gradient = AppColors.electricGradient,
    this.glow = AppColors.electricGlow,
    this.icon,
    this.height = 56,
  });

  final String label;
  final VoidCallback onPressed;
  final Gradient gradient;
  final Color glow;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: glow, blurRadius: 24, offset: const Offset(0, 8)),
        ],
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
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.2,
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
