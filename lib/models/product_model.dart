class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final double? discountPrice;
  final int sizeMl;
  final String categoryId;
  final String fragranceFamily; // Fresh, Floral, Gourmand, Spicy, Woody, Rose
  final String longevity;
  final List<String> topNotes;
  final List<String> middleNotes;
  final List<String> baseNotes;
  final List<String> imageUrls;
  final int stock;
  final double rating;
  final int reviewsCount;
  final bool isFeatured;
  final bool isBestSeller;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.sizeMl,
    required this.categoryId,
    required this.fragranceFamily,
    required this.longevity,
    this.topNotes = const [],
    this.middleNotes = const [],
    this.baseNotes = const [],
    required this.imageUrls,
    required this.stock,
    this.rating = 4.8,
    this.reviewsCount = 0,
    this.isFeatured = false,
    this.isBestSeller = false,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((price - discountPrice!) / price) * 100).round();
  }

  String get mainImage => imageUrls.isNotEmpty
      ? imageUrls.first
      : 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=800&q=80';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String? ?? 'Luxury Parfums',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] as num).toDouble()
          : null,
      sizeMl: json['size_ml'] as int? ?? 100,
      categoryId: json['category_id'] as String? ?? '',
      fragranceFamily: json['fragrance_family'] as String? ?? 'Floral',
      longevity: json['longevity'] as String? ?? 'Long Lasting (8-12 hrs)',
      topNotes: List<String>.from(json['top_notes'] ?? []),
      middleNotes: List<String>.from(json['middle_notes'] ?? []),
      baseNotes: List<String>.from(json['base_notes'] ?? []),
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      stock: json['stock'] as int? ?? 50,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isBestSeller: json['is_best_seller'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'size_ml': sizeMl,
      'category_id': categoryId,
      'fragrance_family': fragranceFamily,
      'longevity': longevity,
      'top_notes': topNotes,
      'middle_notes': middleNotes,
      'base_notes': baseNotes,
      'image_urls': imageUrls,
      'stock': stock,
      'rating': rating,
      'reviews_count': reviewsCount,
      'is_featured': isFeatured,
      'is_best_seller': isBestSeller,
    };
  }
}
