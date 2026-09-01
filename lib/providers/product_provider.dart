import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import 'category_provider.dart';

final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  final category = ref.watch(selectedCategoryProvider);
  final family = ref.watch(selectedFragranceFamilyProvider);
  final query = ref.watch(searchQueryProvider);
  final maxPrice = ref.watch(priceRangeProvider);
  final sortBy = ref.watch(sortByProvider);

  return productService.getProducts(
    categoryId: category == 'All' ? null : category,
    fragranceFamily: family == 'All' ? null : family,
    searchQuery: query,
    maxPrice: maxPrice,
    sortBy: sortBy,
  );
});

final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  final all = await productService.getProducts();
  return all.where((p) => p.isFeatured || p.isBestSeller).toList();
});

final bestSellersProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  final all = await productService.getProducts();
  return all.where((p) => p.isBestSeller).toList();
});

final productDetailProvider = FutureProvider.family<ProductModel?, String>((ref, id) async {
  final productService = ref.watch(productServiceProvider);
  return productService.getProductById(id);
});
