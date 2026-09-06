import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum ShadcnButtonVariant { primary, secondary, outline, ghost, gold, destructive }
enum ShadcnButtonSize { sm, md, lg, icon }

class ShadcnButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final IconData? suffixIcon;
  final VoidCallback? onPressed;
  final ShadcnButtonVariant variant;
  final ShadcnButtonSize size;
  final bool isLoading;
  final bool fullWidth;

  const ShadcnButton({
    super.key,
    this.text,
    this.icon,
    this.suffixIcon,
    required this.onPressed,
    this.variant = ShadcnButtonVariant.primary,
    this.size = ShadcnButtonSize.md,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  State<ShadcnButton> createState() => _ShadcnButtonState();
}

class _ShadcnButtonState extends State<ShadcnButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textCol;
    Border? border;
    List<BoxShadow> shadow = [];

    switch (widget.variant) {
      case ShadcnButtonVariant.secondary:
        bg = _isHovered ? AppColors.inputBackground : AppColors.surfaceVariant;
        textCol = AppColors.textPrimary;
        border = Border.all(color: AppColors.border);
        break;
      case ShadcnButtonVariant.outline:
        bg = _isHovered ? AppColors.accentGoldLight.withValues(alpha: 0.4) : Colors.transparent;
        textCol = AppColors.primary;
        border = Border.all(
          color: _isHovered ? AppColors.accentGold : AppColors.borderGold,
          width: 1.5,
        );
        break;
      case ShadcnButtonVariant.ghost:
        bg = _isHovered ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent;
        textCol = AppColors.primary;
        break;
      case ShadcnButtonVariant.gold:
        bg = _isHovered ? AppColors.accentGold : AppColors.accentGold.withValues(alpha: 0.9);
        textCol = AppColors.primaryDark;
        shadow = [
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: _isHovered ? 0.4 : 0.25),
            blurRadius: _isHovered ? 12 : 6,
            offset: const Offset(0, 4),
          )
        ];
        break;
      case ShadcnButtonVariant.destructive:
        bg = _isHovered ? AppColors.error : AppColors.error.withValues(alpha: 0.9);
        textCol = Colors.white;
        break;
      case ShadcnButtonVariant.primary:
        bg = _isHovered ? AppColors.primaryDark : AppColors.primary;
        textCol = Colors.white;
        shadow = [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: _isHovered ? 0.35 : 0.2),
            blurRadius: _isHovered ? 14 : 8,
            offset: const Offset(0, 4),
          )
        ];
        break;
    }

    EdgeInsets padding;
    double fontSize;
    double iconSize;

    switch (widget.size) {
      case ShadcnButtonSize.sm:
        padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
        fontSize = 12;
        iconSize = 14;
        break;
      case ShadcnButtonSize.lg:
        padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
        fontSize = 16;
        iconSize = 20;
        break;
      case ShadcnButtonSize.icon:
        padding = const EdgeInsets.all(10);
        fontSize = 14;
        iconSize = 18;
        break;
      case ShadcnButtonSize.md:
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
        fontSize = 14;
        iconSize = 16;
        break;
    }

    Widget content = AnimatedScale(
      scale: _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: padding,
        decoration: BoxDecoration(
          color: widget.onPressed == null ? bg.withValues(alpha: 0.5) : bg,
          borderRadius: BorderRadius.circular(30),
          border: border,
          boxShadow: widget.onPressed == null ? [] : shadow,
        ),
        child: Row(
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.isLoading
              ? [
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: textCol,
                    ),
                  ),
                ]
              : [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: iconSize, color: textCol),
                    if (widget.text != null) const SizedBox(width: 8),
                  ],
                  if (widget.text != null)
                    Text(
                      widget.text!,
                      style: TextStyle(
                        color: textCol,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  if (widget.suffixIcon != null) ...[
                    if (widget.text != null) const SizedBox(width: 8),
                    Icon(widget.suffixIcon, size: iconSize, color: textCol),
                  ],
                ],
        ),
      ),
    );

    return MouseRegion(
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: content,
      ),
    );
  }
}
