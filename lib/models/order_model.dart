import 'product_model.dart';

class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double priceAtPurchase;
  final ProductModel? product;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json, {ProductModel? product}) {
    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      priceAtPurchase: (json['price_at_purchase'] as num?)?.toDouble() ?? 0.0,
      product: product ?? (json['products'] != null ? ProductModel.fromJson(json['products']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final double total;
  final String status; // pending, processing, shipped, delivered, cancelled
  final String shippingAddress;
  final String paymentMethod;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['order_items'] as List<dynamic>? ?? [];
    List<OrderItemModel> itemList = rawItems
        .map((itemJson) => OrderItemModel.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      shippingAddress: json['shipping_address'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? 'Credit Card',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      items: itemList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total': total,
      'status': status,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
