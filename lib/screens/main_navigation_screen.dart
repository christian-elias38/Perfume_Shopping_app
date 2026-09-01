import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/cart_provider.dart';
import 'cart/cart_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'shop/shop_screen.dart';
import 'wishlist/wishlist_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartProvider).itemCount;

    final List<Widget> screens = [
      HomeScreen(onNavigateTab: (index) {
        setState(() => _currentIndex = index);
      }),
      const ShopScreen(),
      const WishlistScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 18,
              offset: Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  index: 0,
                  currentIndex: _currentIndex,
                  activeIcon: Icons.home_rounded,
                  inactiveIcon: Icons.home_outlined,
                  label: 'Home',
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  index: 1,
                  currentIndex: _currentIndex,
                  activeIcon: Icons.storefront_rounded,
                  inactiveIcon: Icons.storefront_outlined,
                  label: 'Shop',
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  index: 2,
                  currentIndex: _currentIndex,
                  activeIcon: Icons.favorite_rounded,
                  inactiveIcon: Icons.favorite_outline_rounded,
                  label: 'Wishlist',
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  index: 3,
                  currentIndex: _currentIndex,
                  activeIcon: Icons.shopping_bag_rounded,
                  inactiveIcon: Icons.shopping_bag_outlined,
                  label: 'Cart',
                  badgeCount: cartCount,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                _NavItem(
                  index: 4,
                  currentIndex: _currentIndex,
                  activeIcon: Icons.person_rounded,
                  inactiveIcon: Icons.person_outline,
                  label: 'Profile',
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final int index;
  final int currentIndex;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.currentIndex == widget.index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isHovered ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentGoldLight.withOpacity(0.7)
                  : (_isHovered
                      ? AppColors.accentGoldLight.withOpacity(0.3)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentGold
                    : (_isHovered ? AppColors.borderGold : Colors.transparent),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? widget.activeIcon : widget.inactiveIcon,
                      color: isSelected
                          ? AppColors.primary
                          : (_isHovered ? AppColors.primaryLight : AppColors.textSecondary),
                      size: 22,
                    ),
                    if (widget.badgeCount > 0)
                      Positioned(
                        top: -5,
                        right: -9,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 15,
                            minHeight: 15,
                          ),
                          child: Text(
                            '${widget.badgeCount}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected || _isHovered
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : (_isHovered ? AppColors.primaryLight : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
