import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int reviewsCount;
  final double iconSize;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewsCount = 0,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.starYellow, size: iconSize),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (reviewsCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewsCount)',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ]
      ],
    );
  }
}
