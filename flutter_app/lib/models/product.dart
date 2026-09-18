class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final int stock;
  final int sold;
  final String? categoryId;
  final String? category;
  final String image;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isPopular;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.sold,
    this.categoryId,
    this.category,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.isFeatured,
    required this.isPopular,
  });

  double get displayPrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  bool get inStock => stock > 0;
  bool get isLowStock => stock > 0 && stock <= 5;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      sold: (json['sold'] as num?)?.toInt() ?? 0,
      categoryId: json['category_id'] as String?,
      category: json['category'] as String?,
      image: json['image'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isFeatured: (json['is_featured'] == 1 || json['is_featured'] == true),
      isPopular: (json['is_popular'] == 1 || json['is_popular'] == true),
    );
  }

  Product copyWith({double? price, double? discountPrice, int? stock}) {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      stock: stock ?? this.stock,
      sold: sold,
      categoryId: categoryId,
      category: category,
      image: image,
      rating: rating,
      reviewCount: reviewCount,
      isFeatured: isFeatured,
      isPopular: isPopular,
    );
  }
}

class Category {
  final String id;
  final String name;
  final String? icon;
  Category({required this.id, required this.name, this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name'], icon: json['icon']);
  }
}
