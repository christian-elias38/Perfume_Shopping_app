import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ShadcnTabItem {
  final String label;
  final IconData? icon;

  const ShadcnTabItem({required this.label, this.icon});
}

class ShadcnTabs extends StatelessWidget {
  final List<ShadcnTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ShadcnTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          final item = tabs[index];

          return Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          size: 16,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
