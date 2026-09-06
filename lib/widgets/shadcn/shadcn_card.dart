import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum ShadcnCardVariant { defaultCard, glass, outline, elevated }

class ShadcnCard extends StatefulWidget {
  final Widget? header;
  final Widget? title;
  final Widget? description;
  final Widget child;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final ShadcnCardVariant variant;
  final bool isHoverable;
  final double borderRadius;

  const ShadcnCard({
    super.key,
    this.header,
    this.title,
    this.description,
    required this.child,
    this.footer,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.variant = ShadcnCardVariant.defaultCard,
    this.isHoverable = true,
    this.borderRadius = 20,
  });

  @override
  State<ShadcnCard> createState() => _ShadcnCardState();
}

class _ShadcnCardState extends State<ShadcnCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Border border;
    List<BoxShadow> boxShadow;

    switch (widget.variant) {
      case ShadcnCardVariant.glass:
        backgroundColor = Colors.white.withValues(alpha: _isHovered ? 0.85 : 0.70);
        border = Border.all(
          color: _isHovered ? AppColors.accentGold : AppColors.borderGold.withValues(alpha: 0.5),
          width: _isHovered ? 1.5 : 1.0,
        );
        boxShadow = [
          BoxShadow(
            color: _isHovered ? AppColors.accentGold.withValues(alpha: 0.22) : AppColors.shadowColor,
            blurRadius: _isHovered ? 18 : 10,
            offset: const Offset(0, 6),
          )
        ];
        break;
      case ShadcnCardVariant.outline:
        backgroundColor = Colors.transparent;
        border = Border.all(
          color: _isHovered ? AppColors.primary : AppColors.border,
          width: 1.5,
        );
        boxShadow = [];
        break;
      case ShadcnCardVariant.elevated:
        backgroundColor = AppColors.surface;
        border = Border.all(
          color: _isHovered ? AppColors.accentGold : Colors.transparent,
          width: 1.2,
        );
        boxShadow = [
          BoxShadow(
            color: _isHovered ? AppColors.shadowGoldColor : AppColors.shadowColor,
            blurRadius: _isHovered ? 20 : 12,
            offset: const Offset(0, 8),
          )
        ];
        break;
      case ShadcnCardVariant.defaultCard:
        backgroundColor = AppColors.surface;
        border = Border.all(
          color: _isHovered ? AppColors.accentGold : AppColors.border,
          width: _isHovered ? 1.5 : 1.0,
        );
        boxShadow = [
          BoxShadow(
            color: _isHovered ? AppColors.accentGold.withValues(alpha: 0.2) : AppColors.shadowColor,
            blurRadius: _isHovered ? 16 : 8,
            offset: _isHovered ? const Offset(0, 6) : const Offset(0, 3),
          )
        ];
        break;
    }

    Widget content = AnimatedScale(
      scale: widget.isHoverable ? (_isPressed ? 0.98 : (_isHovered ? 1.02 : 1.0)) : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: border,
          boxShadow: boxShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: widget.variant == ShadcnCardVariant.glass
              ? BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: _buildInnerLayout(),
                )
              : _buildInnerLayout(),
        ),
      ),
    );

    if (widget.onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildInnerLayout() {
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.header != null || widget.title != null || widget.description != null) ...[
            if (widget.header != null) widget.header!,
            if (widget.title != null) ...[
              const SizedBox(height: 4),
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                child: widget.title!,
              ),
            ],
            if (widget.description != null) ...[
              const SizedBox(height: 4),
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                child: widget.description!,
              ),
            ],
            const SizedBox(height: 12),
          ],
          widget.child,
          if (widget.footer != null) ...[
            const SizedBox(height: 12),
            widget.footer!,
          ],
        ],
      ),
    );
  }
}
