import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import 'supabase_service.dart';

class OrderService {
  static final List<OrderModel> _localOrders = [];

  Future<OrderModel> createOrder({
    required String userId,
    required List<CartItemModel> cartItems,
    required double total,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final orderResponse = await SupabaseService.client!
            .from('orders')
            .insert({
              'user_id': userId,
              'total': total,
              'status': 'processing',
              'shipping_address': shippingAddress,
              'payment_method': paymentMethod,
            })
            .select()
            .single();

        final orderId = orderResponse['id'] as String;

        final orderItemInserts = cartItems.map((item) => {
          'order_id': orderId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'price_at_purchase': item.unitPrice,
        }).toList();

        await SupabaseService.client!.from('order_items').insert(orderItemInserts);

        final List<OrderItemModel> items = cartItems.map((item) {
          return OrderItemModel(
            id: 'item-${DateTime.now().millisecondsSinceEpoch}',
            orderId: orderId,
            productId: item.productId,
            quantity: item.quantity,
            priceAtPurchase: item.unitPrice,
            product: item.product,
          );
        }).toList();

        return OrderModel(
          id: orderId,
          userId: userId,
          total: total,
          status: 'processing',
          shippingAddress: shippingAddress,
          paymentMethod: paymentMethod,
          createdAt: DateTime.now(),
          items: items,
        );
      } catch (_) {}
    }

    final newOrderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final List<OrderItemModel> items = cartItems.map((item) {
      return OrderItemModel(
        id: 'item-${DateTime.now().millisecondsSinceEpoch}',
        orderId: newOrderId,
        productId: item.productId,
        quantity: item.quantity,
        priceAtPurchase: item.unitPrice,
        product: item.product,
      );
    }).toList();

    final localOrder = OrderModel(
      id: newOrderId,
      userId: userId,
      total: total,
      status: 'processing',
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      items: items,
    );

    _localOrders.insert(0, localOrder);
    return localOrder;
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final data = await SupabaseService.client!
            .from('orders')
            .select('*, order_items(*, products(*))')
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        return (data as List).map((json) => OrderModel.fromJson(json)).toList();
      } catch (_) {}
    }
    return _localOrders;
  }
}
