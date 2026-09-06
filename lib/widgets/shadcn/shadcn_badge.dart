import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum ShadcnBadgeVariant { defaultBadge, secondary, outline, gold, destructive, success, glass }

class ShadcnBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final ShadcnBadgeVariant variant;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  const ShadcnBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = ShadcnBadgeVariant.defaultBadge,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textCol;
    Border? border;

    switch (variant) {
      case ShadcnBadgeVariant.secondary:
        bg = AppColors.surfaceVariant;
        textCol = AppColors.textPrimary;
        border = Border.all(color: AppColors.border);
        break;
      case ShadcnBadgeVariant.outline:
        bg = Colors.transparent;
        textCol = AppColors.textPrimary;
        border = Border.all(color: AppColors.borderGold);
        break;
      case ShadcnBadgeVariant.gold:
        bg = AppColors.accentGold.withValues(alpha: 0.18);
        textCol = AppColors.primary;
        border = Border.all(color: AppColors.accentGold.withValues(alpha: 0.5));
        break;
      case ShadcnBadgeVariant.destructive:
        bg = AppColors.error.withValues(alpha: 0.15);
        textCol = AppColors.error;
        border = Border.all(color: AppColors.error.withValues(alpha: 0.3));
        break;
      case ShadcnBadgeVariant.success:
        bg = AppColors.success.withValues(alpha: 0.15);
        textCol = AppColors.success;
        border = Border.all(color: AppColors.success.withValues(alpha: 0.3));
        break;
      case ShadcnBadgeVariant.glass:
        bg = Colors.white.withValues(alpha: 0.85);
        textCol = AppColors.primary;
        border = Border.all(color: AppColors.accentGold);
        break;
      case ShadcnBadgeVariant.defaultBadge:
        bg = AppColors.primary;
        textCol = Colors.white;
        border = null;
        break;
    }

    Widget child = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: border,
        boxShadow: variant == ShadcnBadgeVariant.gold || variant == ShadcnBadgeVariant.defaultBadge
            ? [
                BoxShadow(
                  color: bg.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textCol),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textCol,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: child,
        ),
      );
    }

    return child;
  }
}
