import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import 'auth_provider.dart';

final cartServiceProvider = Provider<CartService>((ref) => CartService());

class CartState {
  final List<CartItemModel> items;
  final bool isLoading;
  final String? appliedCoupon;
  final double discountAmount;

  CartState({
    this.items = const [],
    this.isLoading = false,
    this.appliedCoupon,
    this.discountAmount = 0.0,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get shippingFee => subtotal > 200 || subtotal == 0 ? 0.0 : 15.0;

  double get total => (subtotal - discountAmount + shippingFee).clamp(0.0, double.infinity);

  CartState copyWith({
    List<CartItemModel>? items,
    bool? isLoading,
    String? appliedCoupon,
    double? discountAmount,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final CartService _cartService;
  final Ref _ref;

  CartNotifier(this._cartService, this._ref) : super(CartState()) {
    loadCart();
  }

  String get _userId {
    final authState = _ref.read(authProvider);
    return authState.user?.id ?? 'guest-user';
  }

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _cartService.getCartItems(_userId);
      state = state.copyWith(items: items, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    await _cartService.addToCart(
      userId: _userId,
      product: product,
      quantity: quantity,
    );
    await loadCart();
  }


  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    await _cartService.updateQuantity(cartItemId, newQuantity);
    await loadCart();
  }

  Future<void> removeFromCart(String cartItemId) async {
    await _cartService.removeFromCart(cartItemId);
    await loadCart();
  }

  void applyCoupon(String code) {
    if (code.trim().toUpperCase() == 'LUXURY20') {
      final discount = state.subtotal * 0.20;
      state = state.copyWith(appliedCoupon: 'LUXURY20 (20% OFF)', discountAmount: discount);
    } else if (code.trim().toUpperCase() == 'PERFUME10') {
      state = state.copyWith(appliedCoupon: 'PERFUME10 (\$10 OFF)', discountAmount: 10.0);
    }
  }

  Future<void> clearCart() async {
    await _cartService.clearCart(_userId);
    state = CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref.watch(cartServiceProvider), ref);
});
