import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/supabase_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/custom_button.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.primary,
                    backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                        ? const Icon(Icons.person, size: 42, color: AppColors.accentGold)
                        : null,
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

            // Quick Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Saved Scents', '$wishlistCount', Icons.favorite_border),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard('Orders Placed', '$orderCount', Icons.local_shipping_outlined),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Settings & History List
            _buildProfileTile(
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
            _buildProfileTile(
              icon: Icons.location_on_outlined,
              title: 'Saved Shipping Addresses',
              subtitle: 'Manage default luxury delivery locations',
              onTap: () {},
            ),
            _buildProfileTile(
              icon: Icons.card_giftcard_outlined,
              title: 'Parfumerie Rewards Club',
              subtitle: 'Gold Tier Member • 450 Points',
              onTap: () {},
            ),
            _buildProfileTile(
              icon: Icons.cloud_done_outlined,
              title: 'Supabase Backend Status',
              subtitle: SupabaseConfig.isConfigured
                  ? 'Connected to Live Supabase Postgres DB'
                  : 'Running in Rich Offline Demo Mode',
              onTap: () {},
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
        onTap: onTap,
      ),
    );
  }
}
