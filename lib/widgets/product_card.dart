import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import 'product_quick_view_sheet.dart';
import 'rating_stars.dart';
import 'shadcn/shadcn_badge.dart';
import 'shadcn/shadcn_toast.dart';

class ProductCard extends ConsumerStatefulWidget {
  final ProductModel product;
  final double width;

  const ProductCard({super.key, required this.product, this.width = 170});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      lowerBound: 1.0,
      upperBound: 1.4,
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _triggerHeartAnimation() {
    _heartController.forward().then((_) => _heartController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final wishlistNotifier = ref.watch(wishlistProvider.notifier);
    final isWishlisted = ref
        .watch(wishlistProvider)
        .items
        .any((i) => i.productId == widget.product.id);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // Open Quick View Sheet on tap with spring entrance animation!
          ProductQuickViewSheet.show(context, widget.product);
        },
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: widget.width,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _isHovered
                    ? AppColors.accentGold
                    : AppColors.borderGold.withValues(alpha: 0.4),
                width: _isHovered ? 1.6 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? AppColors.accentGold.withValues(alpha: 0.28)
                      : AppColors.shadowColor,
                  blurRadius: _isHovered ? 20 : 10,
                  spreadRadius: _isHovered ? 1 : 0,
                  offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image & Floating Quick View / Wishlist Action Badges
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(21),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: AnimatedScale(
                          scale: _isHovered ? 1.09 : 1.0,
                          duration: const Duration(milliseconds: 320),
                          child: Image.network(
                            widget.product.mainImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(
                                Icons.local_florist,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Discount Badge (Shadcn style)
                    if (widget.product.hasDiscount)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: ShadcnBadge(
                          label: '${widget.product.discountPercentage}% OFF',
                          variant: ShadcnBadgeVariant.defaultBadge,
                        ),
                      ),

                    // Quick View eye button overlay on hover
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: AnimatedOpacity(
                        opacity: _isHovered ? 1.0 : 0.85,
                        duration: const Duration(milliseconds: 180),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.remove_red_eye_rounded,
                                size: 12,
                                color: AppColors.accentGold,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Quick View',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Floating Heart Wishlist Trigger
                    Positioned(
                      top: 10,
                      right: 10,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            _triggerHeartAnimation();
                            wishlistNotifier.toggleWishlist(widget.product);
                            ShadcnToast.show(
                              context: context,
                              title: isWishlisted
                                  ? 'Removed from Wishlist'
                                  : 'Saved to Wishlist!',
                              icon: isWishlisted
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                              iconColor: AppColors.primary,
                            );
                          },
                          child: ScaleTransition(
                            scale: _heartController,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: isWishlisted
                                        ? AppColors.primary.withValues(
                                            alpha: 0.3,
                                          )
                                        : Colors.black12,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: isWishlisted
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Information Section
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.brand.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentGold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          ShadcnBadge(
                            label: widget.product.fragranceFamily,
                            variant: ShadcnBadgeVariant.gold,
                            fontSize: 9,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RatingStars(
                        rating: widget.product.rating,
                        reviewsCount: widget.product.reviewsCount,
                      ),
                      const SizedBox(height: 10),

                      // Price & Add to Cart Trigger
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${(widget.product.discountPrice ?? widget.product.price).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (widget.product.hasDiscount)
                                Text(
                                  '\$${widget.product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),

                          // Add to Cart Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .addToCart(widget.product);
                                ShadcnToast.show(
                                  context: context,
                                  title: 'Added to Shopping Bag!',
                                  message: widget.product.name,
                                  icon: Icons.shopping_bag_rounded,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: _isHovered
                                      ? AppColors.primaryDark
                                      : AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: _isHovered ? 8 : 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_shopping_cart_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
