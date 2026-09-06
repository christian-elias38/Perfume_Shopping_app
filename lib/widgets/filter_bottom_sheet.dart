import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/category_provider.dart';
import 'custom_button.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late String selectedFamily;
  late double maxPrice;
  late String selectedSort;

  final List<String> families = [
    'All',
    'Fresh',
    'Floral',
    'Gourmand',
    'Spicy',
    'Woody',
    'Rose',
  ];
  final Map<String, String> sortOptions = {
    'best_seller': 'Most Popular / Best Sellers',
    'price_asc': 'Price: Low to High',
    'price_desc': 'Price: High to Low',
    'rating': 'Highest Rated',
  };

  @override
  void initState() {
    super.initState();
    selectedFamily = ref.read(selectedFragranceFamilyProvider);
    maxPrice = ref.read(priceRangeProvider) ?? 400.0;
    selectedSort = ref.read(sortByProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter & Sort',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedFamily = 'All';
                    maxPrice = 400.0;
                    selectedSort = 'best_seller';
                  });
                },
                child: const Text(
                  'RESET',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Fragrance Family
          const Text(
            'Fragrance Family',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: families.map((fam) {
              final isSel = selectedFamily == fam;
              return ChoiceChip(
                label: Text(fam),
                selected: isSel,
                onSelected: (selected) {
                  if (selected) setState(() => selectedFamily = fam);
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceVariant,
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Maximum Price Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Max Price Range',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${maxPrice.toInt()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: maxPrice,
            min: 50,
            max: 400,
            divisions: 35,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (val) {
              setState(() => maxPrice = val);
            },
          ),
          const SizedBox(height: 20),

          // Sort By
          const Text(
            'Sort By',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: selectedSort,
            onChanged: (val) {
              if (val != null) setState(() => selectedSort = val);
            },
            child: Column(
              children: sortOptions.entries.map((entry) {
                return RadioListTile<String>(
                  value: entry.key,
                  title: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 14),
                  ),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Apply Button
          CustomButton(
            text: 'APPLY FILTERS',
            onPressed: () {
              ref.read(selectedFragranceFamilyProvider.notifier).state =
                  selectedFamily;
              ref.read(priceRangeProvider.notifier).state = maxPrice == 400
                  ? null
                  : maxPrice;
              ref.read(sortByProvider.notifier).state = selectedSort;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
