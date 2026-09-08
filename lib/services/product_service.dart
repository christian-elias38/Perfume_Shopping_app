import '../core/constants/mock_data.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import 'supabase_service.dart';

class ProductService {
  Future<List<CategoryModel>> getCategories() async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final data = await SupabaseService.client!
            .from('categories')
            .select()
            .order('name');
        
        if ((data as List).isNotEmpty) {
          return data.map((json) => CategoryModel.fromJson(json)).toList();
        }
      } catch (_) {}
    }
    return MockData.categories;
  }

  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? gender,
    String? fragranceFamily,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? sortBy, // 'price_asc', 'price_desc', 'rating', 'best_seller'
  }) async {
    List<ProductModel> products = [];

    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        var query = SupabaseService.client!.from('products').select();
        
        if (categoryId != null && categoryId.isNotEmpty && categoryId != 'All') {
          query = query.eq('category_id', categoryId);
        }
        
        if (fragranceFamily != null && fragranceFamily.isNotEmpty && fragranceFamily != 'All') {
          query = query.eq('fragrance_family', fragranceFamily);
        }

        final data = await query;
        products = (data as List).map((json) => ProductModel.fromJson(json)).toList();
      } catch (_) {
        products = List.from(MockData.products);
      }
    } else {
      products = List.from(MockData.products);
    }

    // Apply filtering and search logic
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'All') {
      products = products.where((p) => p.categoryId == categoryId).toList();
    }

    if (fragranceFamily != null && fragranceFamily.isNotEmpty && fragranceFamily != 'All') {
      products = products.where((p) => 
        p.fragranceFamily.toLowerCase() == fragranceFamily.toLowerCase()
      ).toList();
    }

    if (gender != null && gender.isNotEmpty && gender != 'All') {
      products = products.where((p) {
        if (gender == 'Women') return p.gender == 'Pour Femme';
        if (gender == 'Men') return p.gender == 'Pour Homme';
        if (gender == 'Unisex') return p.gender == 'Unisex';
        return true;
      }).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      products = products.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.brand.toLowerCase().contains(q) ||
        p.fragranceFamily.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q) ||
        p.topNotes.any((note) => note.toLowerCase().contains(q)) ||
        p.middleNotes.any((note) => note.toLowerCase().contains(q)) ||
        p.baseNotes.any((note) => note.toLowerCase().contains(q))
      ).toList();
    }

    if (minPrice != null) {
      products = products.where((p) => (p.discountPrice ?? p.price) >= minPrice).toList();
    }

    if (maxPrice != null) {
      products = products.where((p) => (p.discountPrice ?? p.price) <= maxPrice).toList();
    }

    // Sorting
    if (sortBy == 'price_asc') {
      products.sort((a, b) => (a.discountPrice ?? a.price).compareTo(b.discountPrice ?? b.price));
    } else if (sortBy == 'price_desc') {
      products.sort((a, b) => (b.discountPrice ?? b.price).compareTo(a.discountPrice ?? a.price));
    } else if (sortBy == 'rating') {
      products.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sortBy == 'best_seller') {
      products.sort((a, b) => (b.isBestSeller ? 1 : 0).compareTo(a.isBestSeller ? 1 : 0));
    }

    return products;
  }

  Future<ProductModel?> getProductById(String id) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final data = await SupabaseService.client!
            .from('products')
            .select()
            .eq('id', id)
            .maybeSingle();

        if (data != null) {
          return ProductModel.fromJson(data);
        }
      } catch (_) {}
    }
    try {
      return MockData.products.firstWhere((p) => p.id == id);
    } catch (_) {
      return MockData.products.first;
    }
  }

  Future<List<ReviewModel>> getProductReviews(String productId) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final data = await SupabaseService.client!
            .from('reviews')
            .select('*, users(name, avatar_url)')
            .eq('product_id', productId)
            .order('created_at', ascending: false);

        if ((data as List).isNotEmpty) {
          return data.map((json) => ReviewModel.fromJson(json)).toList();
        }
      } catch (_) {}
    }
    return MockData.reviews.where((r) => r.productId == productId).toList();
  }
}
