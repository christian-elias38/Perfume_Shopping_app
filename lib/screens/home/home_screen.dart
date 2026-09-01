import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/luxury_banner.dart';
import '../../widgets/product_card.dart';
import '../search/search_screen.dart';

class HomeScreen extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final featuredProductsAsync = ref.watch(featuredProductsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final cartCount = ref.watch(cartProvider).itemCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
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
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 24),
                onPressed: () {
                  if (onNavigateTab != null) {
                    onNavigateTab!(3); // Switch to Cart tab
                  }
                },
              ),
              if (cartCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
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
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
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
              // Search Trigger Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: AppColors.textLight, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Find Your Signature Scent...',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Hero Luxury Banner
              LuxuryBanner(
                title: 'Affordable Luxury Fragrances Within Your Reach',
                subtitle: 'SPECIAL DECANTS & EXCLUSIVE EXTRACTS',
                buttonText: 'Shop Decants',
                imageUrl: 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=800&q=80',
                onTap: () {
                  if (onNavigateTab != null) onNavigateTab!(1); // Go to Shop
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
                    TextButton(
                      onPressed: () {
                        if (onNavigateTab != null) onNavigateTab!(1);
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
                          return GestureDetector(
                            onTap: () {
                              ref.read(selectedCategoryProvider.notifier).state = 'All';
                              if (onNavigateTab != null) onNavigateTab!(1);
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 62,
                                  height: 62,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSel ? AppColors.primary : AppColors.surfaceVariant,
                                    border: Border.all(
                                      color: isSel ? AppColors.accentGold : AppColors.border,
                                      width: isSel ? 2 : 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.grid_view_rounded,
                                    color: isSel ? Colors.white : AppColors.primary,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'All',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    color: isSel ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final category = categories[index - 1];
                        final isSel = selectedCategory == category.id;

                        return CategoryPill(
                          category: category,
                          isSelected: isSel,
                          onTap: () {
                            ref.read(selectedCategoryProvider.notifier).state = category.id;
                            if (onNavigateTab != null) onNavigateTab!(1);
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
                    color: AppColors.accentGold.withOpacity(0.15),
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

              // Featured Product Grid
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
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: products[index],
                        width: double.infinity,
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
    );
  }
}
