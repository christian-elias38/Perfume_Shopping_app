import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../screens/product/product_detail_screen.dart';
import 'rating_stars.dart';
import 'shadcn/shadcn_badge.dart';
import 'shadcn/shadcn_button.dart';
import 'shadcn/shadcn_progress.dart';
import 'shadcn/shadcn_sheet.dart';
import 'shadcn/shadcn_toast.dart';

class ProductQuickViewSheet extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductQuickViewSheet({super.key, required this.product});

  static void show(BuildContext context, ProductModel product) {
    ShadcnSheet.show(
      context: context,
      maxHeightFactor: 0.88,
      child: ProductQuickViewSheet(product: product),
    );
  }

  @override
  ConsumerState<ProductQuickViewSheet> createState() => _ProductQuickViewSheetState();
}

class _ProductQuickViewSheetState extends ConsumerState<ProductQuickViewSheet> {
  int selectedSize = 100;
  int quantity = 1;

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
    final basePrice = widget.product.discountPrice ?? widget.product.price;
    final finalPrice = basePrice * sizeMultiplier * quantity;
    final wishlistNotifier = ref.watch(wishlistProvider.notifier);
    final isWishlisted = ref.watch(wishlistProvider).items.any((i) => i.productId == widget.product.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image & Badges Banner
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 1.35,
                child: Hero(
                  tag: 'quick-view-${widget.product.id}',
                  child: Image.network(
                    widget.product.mainImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.local_florist, size: 60, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Row(
                children: [
                  ShadcnBadge(
                    label: widget.product.fragranceFamily,
                    variant: ShadcnBadgeVariant.gold,
                    icon: Icons.auto_awesome,
                  ),
                  if (widget.product.hasDiscount) ...[
                    const SizedBox(width: 8),
                    ShadcnBadge(
                      label: '${widget.product.discountPercentage}% OFF',
                      variant: ShadcnBadgeVariant.defaultBadge,
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    wishlistNotifier.toggleWishlist(widget.product);
                    ShadcnToast.show(
                      context: context,
                      title: isWishlisted ? 'Removed from Wishlist' : 'Saved to Wishlist!',
                      icon: isWishlisted ? Icons.favorite_border : Icons.favorite,
                      iconColor: AppColors.primary,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6)
                      ],
                    ),
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isWishlisted ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Brand & Title
        Text(
          widget.product.brand.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.accentGold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.product.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        RatingStars(rating: widget.product.rating, reviewsCount: widget.product.reviewsCount),

        const SizedBox(height: 14),

        // Price display
        Row(
          children: [
            Text(
              '\$${finalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (widget.product.hasDiscount) ...[
              const SizedBox(width: 10),
              Text(
                '\$${(widget.product.price * sizeMultiplier * quantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textLight,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
            const Spacer(),
            ShadcnBadge(
              label: widget.product.gender,
              variant: ShadcnBadgeVariant.secondary,
              icon: Icons.person_outline,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Sillage & Intensity Indicators
        ShadcnProgress(
          label: 'Fragrance Intensity',
          trailingText: '${widget.product.intensityRating} / 5',
          value: widget.product.intensityRating / 5.0,
          color: AppColors.accentGold,
        ),
        const SizedBox(height: 10),
        ShadcnProgress(
          label: 'Sillage & Projection',
          trailingText: widget.product.sillage,
          value: widget.product.sillage == 'Enormous'
              ? 1.0
              : (widget.product.sillage == 'Strong' ? 0.8 : 0.5),
          color: AppColors.primary,
        ),

        const SizedBox(height: 18),

        // Bottle Size Selector
        const Text(
          'Select Size',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel ? AppColors.accentGold : AppColors.border,
                        width: isSel ? 1.8 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${size}ML',
                        style: TextStyle(
                          fontSize: 12,
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

        const SizedBox(height: 16),

        // Scent Notes Breakdown Chips
        const Text(
          'Key Scent Notes',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ...widget.product.topNotes.take(2).map((n) => ShadcnBadge(
                  label: 'Top: $n',
                  variant: ShadcnBadgeVariant.outline,
                )),
            ...widget.product.middleNotes.take(2).map((n) => ShadcnBadge(
                  label: 'Heart: $n',
                  variant: ShadcnBadgeVariant.gold,
                )),
            ...widget.product.baseNotes.take(2).map((n) => ShadcnBadge(
                  label: 'Base: $n',
                  variant: ShadcnBadgeVariant.secondary,
                )),
          ],
        ),

        const SizedBox(height: 24),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: ShadcnButton(
                text: 'ADD TO CART • \$${finalPrice.toStringAsFixed(2)}',
                icon: Icons.shopping_bag_outlined,
                variant: ShadcnButtonVariant.primary,
                size: ShadcnButtonSize.lg,
                onPressed: () {
                  ref.read(cartProvider.notifier).addToCart(widget.product, quantity: quantity);
                  Navigator.pop(context);
                  ShadcnToast.show(
                    context: context,
                    title: 'Added to Shopping Bag!',
                    message: '$quantity x ${widget.product.name} (${selectedSize}ML)',
                    icon: Icons.shopping_bag_rounded,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: ShadcnButton(
            text: 'View Full Fragrance Details',
            variant: ShadcnButtonVariant.ghost,
            suffixIcon: Icons.arrow_forward_rounded,
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productId: widget.product.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
