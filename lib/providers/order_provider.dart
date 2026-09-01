import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

class OrderState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? errorMessage;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OrderState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderService _orderService;
  final Ref _ref;

  OrderNotifier(this._orderService, this._ref) : super(OrderState()) {
    loadOrders();
  }

  String get _userId {
    final authState = _ref.read(authProvider);
    return authState.user?.id ?? 'guest-user';
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true);
    try {
      final orders = await _orderService.getUserOrders(_userId);
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<OrderModel?> placeOrder({
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    final cartState = _ref.read(cartProvider);
    if (cartState.items.isEmpty) return null;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final order = await _orderService.createOrder(
        userId: _userId,
        cartItems: cartState.items,
        total: cartState.total,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      );

      // Clear cart
      await _ref.read(cartProvider.notifier).clearCart();
      await loadOrders();

      state = state.copyWith(isLoading: false);
      return order;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref.watch(orderServiceProvider), ref);
});
