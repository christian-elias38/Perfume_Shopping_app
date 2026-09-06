import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ShadcnAccordionItem {
  final String title;
  final Widget content;
  final IconData? icon;

  const ShadcnAccordionItem({
    required this.title,
    required this.content,
    this.icon,
  });
}

class ShadcnAccordion extends StatefulWidget {
  final List<ShadcnAccordionItem> items;
  final int? initialExpandedIndex;

  const ShadcnAccordion({
    super.key,
    required this.items,
    this.initialExpandedIndex,
  });

  @override
  State<ShadcnAccordion> createState() => _ShadcnAccordionState();
}

class _ShadcnAccordionState extends State<ShadcnAccordion> {
  late List<bool> _expandedStates;

  @override
  void initState() {
    super.initState();
    _expandedStates = List.generate(
      widget.items.length,
      (index) => index == widget.initialExpandedIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final isExpanded = _expandedStates[index];
          final isLast = index == widget.items.length - 1;

          return Column(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _expandedStates[index] = !_expandedStates[index];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (item.icon != null) ...[
                              Icon(item.icon, size: 18, color: AppColors.primary),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  child: item.content,
                ),
                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.6),
                ),
            ],
          );
        }),
      ),
    );
  }
}
