import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'premium_scaffold.dart';

/// Back-compat aliases → premium system.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 22,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: padding,
      radius: borderRadius,
      onTap: onTap,
      borderColor: color?.withValues(alpha: 0.35),
      child: color == null
          ? child
          : Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(borderRadius - 4),
              ),
              padding: EdgeInsets.zero,
              child: child,
            ),
    );
  }
}

class GlowButton extends StatelessWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradient = AppColors.electricGradient,
    this.glowColor = AppColors.electricGlow,
    this.icon,
    this.height = 56,
  });

  final String label;
  final VoidCallback onPressed;
  final Gradient gradient;
  final Color glowColor;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return NeonButton(
      label: label,
      onPressed: onPressed,
      gradient: gradient,
      glow: glowColor,
      icon: icon,
      height: height,
    );
  }
}
