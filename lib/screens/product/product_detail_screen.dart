import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/fragrance_notes_view.dart';
import '../../widgets/luxury_background.dart';
import '../../widgets/rating_stars.dart';

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

          final unitPrice = product.discountPrice ?? product.price;
          final totalPrice = unitPrice * quantity;

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Sliver AppBar with Hero Image PageView
                    SliverAppBar(
                      expandedHeight: 400.0,
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
                                        boxShadow: [
                                          if (selectedImageIndex == idx)
                                            BoxShadow(
                                              color: AppColors.accentGold.withOpacity(0.4),
                                              blurRadius: 6,
                                            )
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Product Information Details
                    SliverToBoxAdapter(
                      child: LuxuryBackground(
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Brand & Category Tag
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    product.brand.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentGold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                    ),
                                    child: Text(
                                      product.fragranceFamily,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Name & Price
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Text(
                                    '\$${unitPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (product.hasDiscount) ...[
                                    const SizedBox(width: 10),
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textLight,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'SAVE \$${(product.price - product.discountPrice!).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 12),
                              RatingStars(rating: product.rating, reviewsCount: product.reviewsCount),
                              const Divider(height: 32, color: AppColors.border),

                              // Size Selector (50ML / 100ML / 200ML) with Hover feedback
                              const Text(
                                'Bottle Size',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [50, 100, 200].map((size) {
                                  final isSel = selectedSize == size;
                                  return _SizeSelectorPill(
                                    size: size,
                                    isSelected: isSel,
                                    onTap: () => setState(() => selectedSize = size),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 24),

                              // Description
                              const Text(
                                'Fragrance Description',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Fragrance Notes Pyramid Breakdown
                              FragranceNotesView(
                                topNotes: product.topNotes,
                                middleNotes: product.middleNotes,
                                baseNotes: product.baseNotes,
                                longevity: product.longevity,
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Sticky Action Bar
              Container(
                padding: const EdgeInsets.all(20),
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
                      // Quantity Counter
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () {
                                  if (quantity > 1) setState(() => quantity--);
                                },
                              ),
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () {
                                  setState(() => quantity++);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Add to Cart Button
                      Expanded(
                        child: CustomButton(
                          text: 'ADD TO CART • \$${totalPrice.toStringAsFixed(2)}',
                          icon: Icons.shopping_bag_outlined,
                          onPressed: () {
                            ref.read(cartProvider.notifier).addToCart(product, quantity: quantity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$quantity x ${product.name} added to cart!'),
                                backgroundColor: AppColors.primaryDark,
                                behavior: SnackBarBehavior.floating,
                              ),
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

class _SizeSelectorPill extends StatefulWidget {
  final int size;
  final bool isSelected;
  final VoidCallback onTap;

  const _SizeSelectorPill({
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SizeSelectorPill> createState() => _SizeSelectorPillState();
}

class _SizeSelectorPillState extends State<_SizeSelectorPill> {
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
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isSelected ? AppColors.primary : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.accentGold
                    : (_isHovered ? AppColors.borderGold : AppColors.border),
                width: widget.isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                if (widget.isSelected || _isHovered)
                  BoxShadow(
                    color: widget.isSelected
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.accentGold.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
              ],
            ),
            child: Text(
              '${widget.size}ML',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: widget.isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
