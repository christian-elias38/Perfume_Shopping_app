import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/luxury_background.dart';
import '../../widgets/product_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Saved Fragrances'),
      ),
      body: LuxuryBackground(
        child: wishlistState.items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_border_rounded, size: 72, color: AppColors.accentGold),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Wishlist is Empty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Save your favorite luxury scents to view them anytime.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: wishlistState.items.length,
                itemBuilder: (context, index) {
                  final item = wishlistState.items[index];
                  final product = item.product;
                  if (product == null) return const SizedBox();

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 250 + (index * 60)),
                    curve: Curves.easeOutQuad,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 18 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: ProductCard(
                      product: product,
                      width: double.infinity,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
