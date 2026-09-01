import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/fragrance_notes_view.dart';
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
      backgroundColor: AppColors.background,
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
                    // Sliver AppBar with Image PageView
                    SliverAppBar(
                      expandedHeight: 380.0,
                      pinned: true,
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      actions: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
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
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          children: [
                            PageView.builder(
                              itemCount: product.imageUrls.isNotEmpty ? product.imageUrls.length : 1,
                              onPageChanged: (idx) => setState(() => selectedImageIndex = idx),
                              itemBuilder: (context, idx) {
                                return Image.network(
                                  product.imageUrls.isNotEmpty ? product.imageUrls[idx] : product.mainImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.primaryDark,
                                    child: const Icon(Icons.local_florist, size: 80, color: AppColors.accentGold),
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
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      width: selectedImageIndex == idx ? 20 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: selectedImageIndex == idx ? AppColors.accentGold : Colors.white60,
                                        borderRadius: BorderRadius.circular(3),
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
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Brand & Category
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  product.brand.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentGold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
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
                            const SizedBox(height: 6),

                            // Name & Price
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Text(
                                  '\$${unitPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (product.hasDiscount) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textLight,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

                            const SizedBox(height: 10),
                            RatingStars(rating: product.rating, reviewsCount: product.reviewsCount),
                            const Divider(height: 32, color: AppColors.border),

                            // Size Selector (50ML / 100ML)
                            const Text(
                              'Bottle Size',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [50, 100, 200].map((size) {
                                final isSel = selectedSize == size;
                                return GestureDetector(
                                  onTap: () => setState(() => selectedSize = size),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSel ? AppColors.primary : AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSel ? AppColors.primary : AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      '${size}ML',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSel ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
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
                              style: TextStyle(
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
                  ],
                ),
              ),

              // Bottom Sticky Action Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 16,
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                                backgroundColor: AppColors.primary,
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
