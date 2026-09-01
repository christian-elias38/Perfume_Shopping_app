import '../models/product_model.dart';
import '../models/wishlist_model.dart';
import 'supabase_service.dart';

class WishlistService {
  static final List<WishlistItemModel> _localWishlist = [];

  Future<List<WishlistItemModel>> getWishlist(String userId) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final data = await SupabaseService.client!
            .from('wishlist')
            .select('*, products(*)')
            .eq('user_id', userId);

        return (data as List)
            .map((json) => WishlistItemModel.fromJson(json))
            .toList();
      } catch (_) {}
    }
    return _localWishlist;
  }

  Future<bool> isInWishlist(String userId, String productId) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final data = await SupabaseService.client!
            .from('wishlist')
            .select()
            .eq('user_id', userId)
            .eq('product_id', productId)
            .maybeSingle();

        return data != null;
      } catch (_) {}
    }
    return _localWishlist.any((item) => item.productId == productId);
  }

  Future<WishlistItemModel> addToWishlist(String userId, ProductModel product) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final response = await SupabaseService.client!
            .from('wishlist')
            .insert({
              'user_id': userId,
              'product_id': product.id,
            })
            .select('*, products(*)')
            .single();

        return WishlistItemModel.fromJson(response, product: product);
      } catch (_) {}
    }

    final newItem = WishlistItemModel(
      id: 'wishlist-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      productId: product.id,
      createdAt: DateTime.now(),
      product: product,
    );
    if (!_localWishlist.any((item) => item.productId == product.id)) {
      _localWishlist.add(newItem);
    }
    return newItem;
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        await SupabaseService.client!
            .from('wishlist')
            .delete()
            .eq('user_id', userId)
            .eq('product_id', productId);
        return;
      } catch (_) {}
    }
    _localWishlist.removeWhere((item) => item.productId == productId);
  }
}
