import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/product_card.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);

    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedFamily = ref.watch(selectedFragranceFamilyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Shop Fragrances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const FilterBottomSheet(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Category Selector Chips
          categoriesAsync.when(
            loading: () => const SizedBox(height: 50),
            error: (_, __) => const SizedBox(),
            data: (categories) {
              return SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSel = selectedCategory == 'All';
                      return ChoiceChip(
                        label: const Text('All Categories'),
                        selected: isSel,
                        onSelected: (_) {
                          ref.read(selectedCategoryProvider.notifier).state = 'All';
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceVariant,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }

                    final cat = categories[index - 1];
                    final isSel = selectedCategory == cat.id;

                    return ChoiceChip(
                      label: Text(cat.name),
                      selected: isSel,
                      onSelected: (_) {
                        ref.read(selectedCategoryProvider.notifier).state = cat.id;
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceVariant,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Active filter indicator bar if family is selected
          if (selectedFamily != 'All')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text('Family: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Chip(
                    label: Text(selectedFamily),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      ref.read(selectedFragranceFamilyProvider.notifier).state = 'All';
                    },
                    backgroundColor: AppColors.accentGold.withOpacity(0.2),
                    labelStyle: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // Products Grid View
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(child: Text('Error loading products: $err')),
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 54, color: AppColors.textLight),
                        const SizedBox(height: 12),
                        const Text(
                          'No products match your current filters.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ref.read(selectedCategoryProvider.notifier).state = 'All';
                            ref.read(selectedFragranceFamilyProvider.notifier).state = 'All';
                            ref.read(priceRangeProvider.notifier).state = null;
                          },
                          child: const Text('Reset All Filters', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
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
          ),
        ],
      ),
    );
  }
}
