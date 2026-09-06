import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/category_model.dart';

class CategoryPill extends StatefulWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryPill({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CategoryPill> createState() => _CategoryPillState();
}

class _CategoryPillState extends State<CategoryPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSel = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: _isHovered ? 1.10 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSel ? AppColors.primary : AppColors.surfaceVariant,
                  border: Border.all(
                    color: isSel
                        ? AppColors.accentGold
                        : (_isHovered ? AppColors.borderGold : AppColors.border),
                    width: isSel ? 2.5 : (_isHovered ? 2.0 : 1.0),
                  ),
                  boxShadow: [
                    if (isSel || _isHovered)
                      BoxShadow(
                        color: isSel
                            ? AppColors.primary.withValues(alpha: 0.35)
                            : AppColors.accentGold.withValues(alpha: 0.25),
                        blurRadius: _isHovered ? 12 : 8,
                        spreadRadius: _isHovered ? 1 : 0,
                        offset: const Offset(0, 4),
                      )
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.category.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.spa_outlined,
                      color: isSel ? Colors.white : AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSel || _isHovered ? FontWeight.bold : FontWeight.w500,
                color: isSel
                    ? AppColors.primary
                    : (_isHovered ? AppColors.primaryLight : AppColors.textSecondary),
              ),
              child: Text(widget.category.name),
            ),
          ],
        ),
      ),
    );
  }
}
