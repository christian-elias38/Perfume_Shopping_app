import 'product_model.dart';

class CartItemModel {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final ProductModel? product;

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  double get unitPrice => product?.discountPrice ?? product?.price ?? 0.0;
  double get totalPrice => unitPrice * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json, {ProductModel? product}) {
    return CartItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int? ?? 1,
      product: product ?? (json['products'] != null ? ProductModel.fromJson(json['products']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    String? id,
    String? userId,
    String? productId,
    int? quantity,
    ProductModel? product,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
    );
  }
}
