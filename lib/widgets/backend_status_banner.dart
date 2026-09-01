import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../services/supabase_service.dart';

class BackendStatusBanner extends StatefulWidget {
  final bool showOnlyIfOffline;

  const BackendStatusBanner({
    super.key,
    this.showOnlyIfOffline = true,
  });

  @override
  State<BackendStatusBanner> createState() => _BackendStatusBannerState();
}

class _BackendStatusBannerState extends State<BackendStatusBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final isOffline = SupabaseService.isOfflineDemoMode;

    if (widget.showOnlyIfOffline && !isOffline) {
      return const SizedBox.shrink();
    }

    if (_dismissed) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOffline
              ? [
                  AppColors.accentGold.withOpacity(0.18),
                  AppColors.primaryLight.withOpacity(0.12),
                ]
              : [
                  AppColors.success.withOpacity(0.15),
                  AppColors.accentGold.withOpacity(0.1),
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOffline ? AppColors.accentGold.withOpacity(0.4) : AppColors.success.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: (isOffline ? AppColors.accentGold : AppColors.success).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isOffline ? AppColors.accentGold.withOpacity(0.2) : AppColors.success.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOffline ? Icons.offline_bolt_outlined : Icons.cloud_done_rounded,
              color: isOffline ? AppColors.primary : AppColors.success,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOffline ? 'Offline Demo Mode Active' : 'Live Supabase Connected',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOffline
                      ? 'Supabase backend not reachable — enjoying full luxury catalog & cart features locally.'
                      : 'Real-time database and authentication active.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _dismissed = true);
            },
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
