import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ShadcnSheet extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget child;
  final Widget? footer;
  final double maxHeightFactor;

  const ShadcnSheet({
    super.key,
    this.title,
    this.description,
    required this.child,
    this.footer,
    this.maxHeightFactor = 0.85,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? description,
    required Widget child,
    Widget? footer,
    double maxHeightFactor = 0.85,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => ShadcnSheet(
        title: title,
        description: description,
        footer: footer,
        maxHeightFactor: maxHeightFactor,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.6), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            spreadRadius: 2,
            offset: Offset(0, -10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Indicator
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header Bar
              if (title != null || description != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Text(
                                title!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            if (description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                description!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (title != null || description != null)
                Divider(color: AppColors.borderGold.withOpacity(0.3), height: 16),

              // Body Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: child,
                ),
              ),

              // Optional Footer
              if (footer != null) ...[
                Divider(color: AppColors.borderGold.withOpacity(0.3), height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: footer!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
