class ReviewModel {
  final String id;
  final String userId;
  final String productId;
  final double rating;
  final String comment;
  final String userName;
  final String? userAvatar;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.comment,
    this.userName = 'Verified Buyer',
    this.userAvatar,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? userMap = json['users'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String? ?? '',
      userName: userMap?['name'] as String? ?? 'Fragrance Lover',
      userAvatar: userMap?['avatar_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
