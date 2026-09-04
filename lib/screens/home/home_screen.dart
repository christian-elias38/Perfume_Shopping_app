import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/backend_status_banner.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/luxury_background.dart';
import '../../widgets/luxury_banner.dart';
import '../../widgets/product_card.dart';
import '../../widgets/scent_quiz_modal.dart';
import '../../widgets/shadcn/shadcn_badge.dart';
import '../../widgets/shadcn/shadcn_button.dart';
import '../../widgets/shadcn/shadcn_card.dart';
import '../search/search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _searchBarHovered = false;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final featuredProductsAsync = ref.watch(featuredProductsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final cartCount = ref.watch(cartProvider).itemCount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 6,
                  )
                ],
              ),
              child: const Icon(Icons.local_florist, color: AppColors.accentGold, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'PARFUMERIE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Haute Parfumerie House',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              icon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 24),
                  onPressed: () {
                    if (widget.onNavigateTab != null) {
                      widget.onNavigateTab!(3);
                    }
                  },
                ),
                if (cartCount > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: AnimatedScale(
                      scale: cartCount > 0 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$cartCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LuxuryBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(categoriesProvider);
            ref.invalidate(featuredProductsProvider);
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Backend Status Banner
                const BackendStatusBanner(showOnlyIfOffline: true),

                // Command-Style Search Trigger Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _searchBarHovered = true),
                    onExit: (_) => setState(() => _searchBarHovered = false),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _searchBarHovered
                              ? Colors.white
                              : AppColors.inputBackground.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _searchBarHovered ? AppColors.accentGold : AppColors.border,
                            width: _searchBarHovered ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            if (_searchBarHovered)
                              BoxShadow(
                                color: AppColors.accentGold.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: _searchBarHovered ? AppColors.primary : AppColors.textLight,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Find Your Signature Scent...',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            ShadcnBadge(
                              label: '⌘K Search',
                              variant: ShadcnBadgeVariant.outline,
                              fontSize: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Interactive Scent Finder Quiz Card Trigger
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ShadcnCard(
                    variant: ShadcnCardVariant.glass,
                    onTap: () {
                      ScentQuizModal.show(context);
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accentGold, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '✨ Scent Finder Quiz',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Match your mood & occasion in 2 simple steps',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const ShadcnButton(
                          text: 'Quiz',
                          variant: ShadcnButtonVariant.gold,
                          size: ShadcnButtonSize.sm,
                          onPressed: null, // Card handles tap
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Hero Luxury Banner
                LuxuryBanner(
                  title: 'Affordable Luxury Fragrances Within Your Reach',
                  subtitle: 'SPECIAL DECANTS & EXCLUSIVE EXTRACTS',
                  buttonText: 'Shop Decants',
                  imageUrl: 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=800&q=80',
                  onTap: () {
                    if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                  },
                ),

                const SizedBox(height: 16),

                // Shop By Category Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shop By Category',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: TextButton(
                          onPressed: () {
                            if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Pills Horizontal List
                SizedBox(
                  height: 105,
                  child: categoriesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    error: (_, __) => const SizedBox(),
                    data: (categories) {
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            final isSel = selectedCategory == 'All';
                            return _AllCategoryCircle(
                              isSelected: isSel,
                              onTap: () {
                                ref.read(selectedCategoryProvider.notifier).state = 'All';
                                if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                              },
                            );
                          }

                          final category = categories[index - 1];
                          final isSel = selectedCategory == category.id;

                          return CategoryPill(
                            category: category,
                            isSelected: isSel,
                            onTap: () {
                              ref.read(selectedCategoryProvider.notifier).state = category.id;
                              if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Best Sellers Section Tag
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.5)),
                    ),
                    child: const Text(
                      '★  BEST SELLERS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'Most-Loved Fragrances,\nCurated for You',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Featured Product Grid with Staggered Fade Entrance
                featuredProductsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                  error: (err, _) => Center(child: Text('Error loading products: $err')),
                  data: (products) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.60,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 250 + (index * 60)),
                          curve: Curves.easeOutQuad,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: ProductCard(
                            product: products[index],
                            width: double.infinity,
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AllCategoryCircle extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _AllCategoryCircle({required this.isSelected, required this.onTap});

  @override
  State<_AllCategoryCircle> createState() => _AllCategoryCircleState();
}

class _AllCategoryCircleState extends State<_AllCategoryCircle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
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
                  color: widget.isSelected ? AppColors.primary : AppColors.surfaceVariant,
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.accentGold
                        : (_isHovered ? AppColors.borderGold : AppColors.border),
                    width: widget.isSelected ? 2.5 : (_isHovered ? 2.0 : 1.0),
                  ),
                  boxShadow: [
                    if (widget.isSelected || _isHovered)
                      BoxShadow(
                        color: widget.isSelected
                            ? AppColors.primary.withOpacity(0.35)
                            : AppColors.accentGold.withOpacity(0.25),
                        blurRadius: _isHovered ? 12 : 8,
                        offset: const Offset(0, 4),
                      )
                  ],
                ),
                child: Icon(
                  Icons.grid_view_rounded,
                  color: widget.isSelected ? Colors.white : AppColors.primary,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'All',
              style: TextStyle(
                fontSize: 12,
                fontWeight: widget.isSelected || _isHovered ? FontWeight.bold : FontWeight.w500,
                color: widget.isSelected
                    ? AppColors.primary
                    : (_isHovered ? AppColors.primaryLight : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
