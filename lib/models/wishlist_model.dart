import 'product_model.dart';

class WishlistItemModel {
  final String id;
  final String userId;
  final String productId;
  final DateTime? createdAt;
  final ProductModel? product;

  WishlistItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    this.createdAt,
    this.product,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json, {ProductModel? product}) {
    return WishlistItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      product: product ?? (json['products'] != null ? ProductModel.fromJson(json['products']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
