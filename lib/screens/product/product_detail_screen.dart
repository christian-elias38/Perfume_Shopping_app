import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/fragrance_notes_view.dart';
import '../../widgets/luxury_background.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/shadcn/shadcn_accordion.dart';
import '../../widgets/shadcn/shadcn_badge.dart';
import '../../widgets/shadcn/shadcn_button.dart';
import '../../widgets/shadcn/shadcn_progress.dart';
import '../../widgets/shadcn/shadcn_tabs.dart';
import '../../widgets/shadcn/shadcn_toast.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int quantity = 1;
  int selectedImageIndex = 0;
  int selectedSize = 100;
  int selectedTabIndex = 0;

  double get sizeMultiplier {
    switch (selectedSize) {
      case 30:
        return 0.55;
      case 50:
        return 0.75;
      case 200:
        return 1.70;
      case 100:
      default:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final wishlistNotifier = ref.watch(wishlistProvider.notifier);
    final isWishlisted = ref.watch(wishlistProvider).items.any((i) => i.productId == widget.productId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Error loading product: $err')),
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          final basePrice = product.discountPrice ?? product.price;
          final unitPrice = basePrice * sizeMultiplier;
          final totalPrice = unitPrice * quantity;

          final reviews = ref.watch(productReviewsProvider(widget.productId)).value ?? [];

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Hero Image Sliver AppBar
                    SliverAppBar(
                      expandedHeight: 420.0,
                      pinned: true,
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      actions: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            decoration: const BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                isWishlisted ? Icons.favorite : Icons.favorite_border,
                                color: isWishlisted ? AppColors.accentGold : Colors.white,
                              ),
                              onPressed: () {
                                wishlistNotifier.toggleWishlist(product);
                                ShadcnToast.show(
                                  context: context,
                                  title: isWishlisted ? 'Removed from Wishlist' : 'Saved to Wishlist!',
                                  icon: isWishlisted ? Icons.favorite_border : Icons.favorite,
                                  iconColor: AppColors.primary,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          children: [
                            PageView.builder(
                              itemCount: product.imageUrls.isNotEmpty ? product.imageUrls.length : 1,
                              onPageChanged: (idx) => setState(() => selectedImageIndex = idx),
                              itemBuilder: (context, idx) {
                                final imgUrl = product.imageUrls.isNotEmpty ? product.imageUrls[idx] : product.mainImage;
                                return Hero(
                                  tag: idx == 0 ? 'product-image-${product.id}' : 'product-image-${product.id}-$idx',
                                  child: Image.network(
                                    imgUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.primaryDark,
                                      child: const Icon(Icons.local_florist, size: 80, color: AppColors.accentGold),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Image indicator dots
                            if (product.imageUrls.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(product.imageUrls.length, (idx) {
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: selectedImageIndex == idx ? 24 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: selectedImageIndex == idx ? AppColors.accentGold : Colors.white60,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Details Section
                    SliverToBoxAdapter(
                      child: LuxuryBackground(
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Brand & Tags Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    product.brand.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentGold,
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      ShadcnBadge(
                                        label: product.fragranceFamily,
                                        variant: ShadcnBadgeVariant.gold,
                                      ),
                                      const SizedBox(width: 6),
                                      ShadcnBadge(
                                        label: product.gender,
                                        variant: ShadcnBadgeVariant.secondary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Name & Rating
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              RatingStars(rating: product.rating, reviewsCount: product.reviewsCount),

                              const SizedBox(height: 12),

                              // Price & Savings Badge
                              Row(
                                children: [
                                  Text(
                                    '\$${unitPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (product.hasDiscount) ...[
                                    const SizedBox(width: 10),
                                    Text(
                                      '\$${(product.price * sizeMultiplier).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textLight,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ShadcnBadge(
                                      label: '${product.discountPercentage}% OFF',
                                      variant: ShadcnBadgeVariant.defaultBadge,
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Size Selector Pills
                              const Text(
                                'Bottle Size Options',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [30, 50, 100, 200].map((size) {
                                  final isSel = selectedSize == size;
                                  return Expanded(
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () => setState(() => selectedSize = size),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          margin: const EdgeInsets.only(right: 8),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: isSel ? AppColors.primary : AppColors.surfaceVariant,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isSel ? AppColors.accentGold : AppColors.border,
                                              width: isSel ? 2.0 : 1.0,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${size}ML',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isSel ? Colors.white : AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 24),

                              // Shadcn Animated Tabs for Detailed Content
                              ShadcnTabs(
                                tabs: const [
                                  ShadcnTabItem(label: 'Overview', icon: Icons.description_outlined),
                                  ShadcnTabItem(label: 'Performance', icon: Icons.speed_rounded),
                                  ShadcnTabItem(label: 'Reviews', icon: Icons.star_outline_rounded),
                                ],
                                selectedIndex: selectedTabIndex,
                                onChanged: (idx) => setState(() => selectedTabIndex = idx),
                              ),

                              const SizedBox(height: 20),

                              // Tab Content 0: Overview & Fragrance Pyramid
                              if (selectedTabIndex == 0) ...[
                                Text(
                                  product.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                FragranceNotesView(
                                  topNotes: product.topNotes,
                                  middleNotes: product.middleNotes,
                                  baseNotes: product.baseNotes,
                                  longevity: product.longevity,
                                ),
                                const SizedBox(height: 20),
                                ShadcnAccordion(
                                  items: [
                                    ShadcnAccordionItem(
                                      title: 'How to Apply Haute Fragrance',
                                      icon: Icons.tips_and_updates_outlined,
                                      content: const Text(
                                        'Spray onto pulse points: wrists, behind ears, neck, and inner elbows. Avoid rubbing wrists together after application as it breaks down scent molecules.',
                                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                      ),
                                    ),
                                    ShadcnAccordionItem(
                                      title: 'Authenticity & Guarantee',
                                      icon: Icons.verified_user_outlined,
                                      content: const Text(
                                        '100% Guaranteed authentic decanted and bottled directly from official Parisian & Niche perfume houses. Includes 30-day money-back guarantee.',
                                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              // Tab Content 1: Performance & Sillage
                              if (selectedTabIndex == 1) ...[
                                ShadcnProgress(
                                  label: 'Fragrance Intensity',
                                  trailingText: '${product.intensityRating} / 5',
                                  value: product.intensityRating / 5.0,
                                  color: AppColors.accentGold,
                                ),
                                const SizedBox(height: 16),
                                ShadcnProgress(
                                  label: 'Sillage & Radius Projection',
                                  trailingText: product.sillage,
                                  value: product.sillage == 'Enormous' ? 1.0 : (product.sillage == 'Strong' ? 0.8 : 0.5),
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 16),
                                ShadcnProgress(
                                  label: 'Skin Longevity',
                                  trailingText: product.longevity,
                                  value: 0.9,
                                  color: AppColors.accentGold,
                                ),
                                const SizedBox(height: 20),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    ShadcnBadge(label: 'Recommended Season: ${product.season}', variant: ShadcnBadgeVariant.gold),
                                    ShadcnBadge(label: 'Best Occasion: ${product.occasion}', variant: ShadcnBadgeVariant.secondary),
                                  ],
                                ),
                              ],

                              // Tab Content 2: Customer Reviews
                              if (selectedTabIndex == 2) ...[
                                if (reviews.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(
                                      child: Text('No reviews yet. Be the first to review this fragrance!'),
                                    ),
                                  )
                                else
                                  ...reviews.map((r) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.borderGold.withOpacity(0.4)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                              RatingStars(rating: r.rating, reviewsCount: 0),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            r.comment,
                                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky Action Bar at Bottom
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.borderGold.withOpacity(0.4))),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 18,
                      offset: Offset(0, -4),
                    )
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Quantity selector
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () {
                                if (quantity > 1) setState(() => quantity--);
                              },
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () {
                                setState(() => quantity++);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Add to Cart Button
                      Expanded(
                        child: ShadcnButton(
                          text: 'ADD TO CART • \$${totalPrice.toStringAsFixed(2)}',
                          icon: Icons.shopping_bag_outlined,
                          size: ShadcnButtonSize.lg,
                          variant: ShadcnButtonVariant.primary,
                          onPressed: () {
                            ref.read(cartProvider.notifier).addToCart(product, quantity: quantity);
                            ShadcnToast.show(
                              context: context,
                              title: 'Added to Shopping Bag!',
                              message: '$quantity x ${product.name} (${selectedSize}ML)',
                              icon: Icons.shopping_bag_rounded,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
