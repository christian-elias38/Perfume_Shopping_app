import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) => ProductService());

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  return productService.getCategories();
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final selectedGenderProvider = StateProvider<String>((ref) => 'All');
final selectedFragranceFamilyProvider = StateProvider<String>((ref) => 'All');
final searchQueryProvider = StateProvider<String>((ref) => '');
final priceRangeProvider = StateProvider<double?>((ref) => null);
final sortByProvider = StateProvider<String>((ref) => 'best_seller');
