import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class FragranceNotesView extends StatelessWidget {
  final List<String> topNotes;
  final List<String> middleNotes;
  final List<String> baseNotes;
  final String longevity;

  const FragranceNotesView({
    super.key,
    required this.topNotes,
    required this.middleNotes,
    required this.baseNotes,
    required this.longevity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Longevity badge
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.accentGold, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Longevity Sillage: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                longevity,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),

          // Fragrance Pyramid
          _buildNoteRow('TOP NOTES', topNotes, Icons.wb_sunny_outlined, AppColors.accentGold),
          const SizedBox(height: 14),
          _buildNoteRow('HEART / MIDDLE', middleNotes, Icons.local_florist_outlined, AppColors.primary),
          const SizedBox(height: 14),
          _buildNoteRow('BASE NOTES', baseNotes, Icons.eco_outlined, Colors.brown),
        ],
      ),
    );
  }

  Widget _buildNoteRow(String title, List<String> notes, IconData icon, Color color) {
    if (notes.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: notes.map((note) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                note,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
