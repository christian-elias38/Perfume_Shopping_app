import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import 'supabase_service.dart';

class CartService {
  static final List<CartItemModel> _localCart = [];

  Future<List<CartItemModel>> getCartItems(String userId) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final data = await SupabaseService.client!
            .from('cart_items')
            .select('*, products(*)')
            .eq('user_id', userId);

        return (data as List)
            .map((json) => CartItemModel.fromJson(json))
            .toList();
      } catch (_) {}
    }
    return _localCart;
  }

  Future<CartItemModel> addToCart({
    required String userId,
    required ProductModel product,
    int quantity = 1,
  }) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        // Check if item exists
        final existing = await SupabaseService.client!
            .from('cart_items')
            .select()
            .eq('user_id', userId)
            .eq('product_id', product.id)
            .maybeSingle();

        if (existing != null) {
          final currentQty = existing['quantity'] as int;
          final updatedQty = currentQty + quantity;

          final response = await SupabaseService.client!
              .from('cart_items')
              .update({'quantity': updatedQty})
              .eq('id', existing['id'])
              .select('*, products(*)')
              .single();

          return CartItemModel.fromJson(response, product: product);
        } else {
          final response = await SupabaseService.client!
              .from('cart_items')
              .insert({
                'user_id': userId,
                'product_id': product.id,
                'quantity': quantity,
              })
              .select('*, products(*)')
              .single();

          return CartItemModel.fromJson(response, product: product);
        }
      } catch (_) {}
    }

    // Local state fallback
    final index = _localCart.indexWhere((item) => item.productId == product.id);
    if (index >= 0) {
      final existing = _localCart[index];
      final updated = existing.copyWith(quantity: existing.quantity + quantity);
      _localCart[index] = updated;
      return updated;
    } else {
      final newItem = CartItemModel(
        id: 'cart-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        productId: product.id,
        quantity: quantity,
        product: product,
      );
      _localCart.add(newItem);
      return newItem;
    }
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        await SupabaseService.client!
            .from('cart_items')
            .update({'quantity': newQuantity})
            .eq('id', cartItemId);
        return;
      } catch (_) {}
    }

    final index = _localCart.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      _localCart[index] = _localCart[index].copyWith(quantity: newQuantity);
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        await SupabaseService.client!
            .from('cart_items')
            .delete()
            .eq('id', cartItemId);
        return;
      } catch (_) {}
    }
    _localCart.removeWhere((item) => item.id == cartItemId);
  }

  Future<void> clearCart(String userId) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        await SupabaseService.client!
            .from('cart_items')
            .delete()
            .eq('user_id', userId);
        return;
      } catch (_) {}
    }
    _localCart.clear();
  }
}
