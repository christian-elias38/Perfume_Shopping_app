import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/luxury_background.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shadcn/shadcn_badge.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final ScrollController _genderScrollController = ScrollController();
  Timer? _genderScrollTimer;

  @override
  void initState() {
    super.initState();
    _genderScrollController.addListener(_loopGenderFilters);
    _genderScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!_genderScrollController.hasClients) return;
      final maxScroll = _genderScrollController.position.maxScrollExtent;
      if (maxScroll > 0) {
        _genderScrollController.jumpTo(_genderScrollController.offset + 0.35);
      }
    });
  }

  void _loopGenderFilters() {
    if (!_genderScrollController.hasClients) return;

    final midpoint = _genderScrollController.position.maxScrollExtent / 2;
    if (midpoint > 0 && _genderScrollController.offset >= midpoint) {
      _genderScrollController.jumpTo(_genderScrollController.offset - midpoint);
    }
  }

  @override
  void dispose() {
    _genderScrollTimer?.cancel();
    _genderScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final selectedGender = ref.watch(selectedGenderProvider);
    final selectedFamily = ref.watch(selectedFragranceFamilyProvider);
    const genderFilters = ['All', 'Women', 'Men', 'Unisex'];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Shop'),
        actions: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
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
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LuxuryBackground(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView.separated(
                controller: _genderScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: genderFilters.length * 2,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final label = genderFilters[index % genderFilters.length];
                  final isSel = selectedGender == label;
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSel,
                    onSelected: (_) {
                      ref.read(selectedGenderProvider.notifier).state = label;
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceVariant,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Active filter indicator bar if family is selected
            if (selectedFamily != 'All')
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Fragrance Family: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    ShadcnBadge(
                      label: selectedFamily,
                      variant: ShadcnBadgeVariant.gold,
                      onTap: () {
                        ref
                                .read(selectedFragranceFamilyProvider.notifier)
                                .state =
                            'All';
                      },
                    ),
                  ],
                ),
              ),

            // Products Grid View with Entrance Animations
            Expanded(
              child: ref
                  .watch(productsProvider)
                  .when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    error: (err, _) =>
                        Center(child: Text('Error loading products: $err')),
                    data: (products) {
                      if (products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 54,
                                color: AppColors.textLight,
                              ),
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
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: TextButton(
                                  onPressed: () {
                                    ref
                                            .read(
                                              selectedCategoryProvider.notifier,
                                            )
                                            .state =
                                        'All';
                                    ref
                                            .read(
                                              selectedGenderProvider.notifier,
                                            )
                                            .state =
                                        'All';
                                    ref
                                            .read(
                                              selectedFragranceFamilyProvider
                                                  .notifier,
                                            )
                                            .state =
                                        'All';
                                    ref
                                            .read(priceRangeProvider.notifier)
                                            .state =
                                        null;
                                  },
                                  child: const Text(
                                    'Reset All Filters',
                                    style: TextStyle(color: AppColors.primary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.54,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(
                              milliseconds: 250 + (index * 50),
                            ),
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
                              product: products[index],
                              width: double.infinity,
                            ),
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
