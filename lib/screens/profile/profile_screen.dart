import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/supabase_service.dart';
import '../../widgets/backend_status_banner.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/luxury_background.dart';
import '../auth/login_screen.dart';
import '../orders/order_history_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final wishlistCount = ref.watch(wishlistProvider).items.length;
    final orderCount = ref.watch(orderProvider).orders.length;
    final isOffline = SupabaseService.isOfflineDemoMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('My Profile'),
        actions: [
          if (user != null)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                },
              ),
            ),
        ],
      ),
      body: LuxuryBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Backend Status Indicator
              const BackendStatusBanner(showOnlyIfOffline: false),

              const SizedBox(height: 12),

              // Profile Header Box with subtle gold glow border
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.accentGold,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.primary,
                            backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                                ? const Icon(Icons.person, size: 42, color: AppColors.accentGold)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.name ?? 'Guest Collector',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'Sign in to sync your fragrance collection',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (user == null)
                      CustomButton(
                        text: 'SIGN IN / REGISTER',
                        height: 44,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Stats Row with Hover effects
              Row(
                children: [
                  Expanded(
                    child: _HoverStatCard(
                      label: 'Saved Scents',
                      value: '$wishlistCount',
                      icon: Icons.favorite_border_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _HoverStatCard(
                      label: 'Orders Placed',
                      value: '$orderCount',
                      icon: Icons.local_shipping_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Settings & History List
              _HoverProfileTile(
                icon: Icons.history_rounded,
                title: 'Order History',
                subtitle: 'Track past purchases & shipping status',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                  );
                },
              ),
              _HoverProfileTile(
                icon: Icons.location_on_outlined,
                title: 'Saved Shipping Addresses',
                subtitle: 'Manage default luxury delivery locations',
                onTap: () {},
              ),
              _HoverProfileTile(
                icon: Icons.card_giftcard_outlined,
                title: 'Parfumerie Rewards Club',
                subtitle: 'Gold Tier Member • 450 Points',
                onTap: () {},
              ),
              _HoverProfileTile(
                icon: isOffline ? Icons.offline_bolt_outlined : Icons.cloud_done_outlined,
                title: 'Supabase Backend Connectivity',
                subtitle: SupabaseService.statusMessage,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(SupabaseService.statusMessage),
                      backgroundColor: AppColors.primaryDark,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverStatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HoverStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  State<_HoverStatCard> createState() => _HoverStatCardState();
}

class _HoverStatCardState extends State<_HoverStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered ? AppColors.accentGold : AppColors.border,
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.accentGold.withOpacity(0.2)
                    : AppColors.shadowColor,
                blurRadius: _isHovered ? 12 : 6,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 8),
              Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverProfileTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HoverProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_HoverProfileTile> createState() => _HoverProfileTileState();
}

class _HoverProfileTileState extends State<_HoverProfileTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered ? AppColors.accentGold : AppColors.border,
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? AppColors.accentGold.withOpacity(0.18)
                      : AppColors.shadowColor,
                  blurRadius: _isHovered ? 10 : 4,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? AppColors.accentGoldLight.withOpacity(0.5)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: AppColors.primary, size: 20),
              ),
              title: Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                widget.subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
            ),
          ),
        ),
      ),
    );
  }
}
