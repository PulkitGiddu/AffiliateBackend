/// Product model from backend.
class Product {
  const Product({
    required this.id,
    required this.productName,
    this.description,
    required this.productUniqueId,
    this.originalPrice,
    required this.salePrice,
    this.reviewScore,
    this.reviewCount = 0,
    required this.affiliateUrl,
    this.imageUrl,
    required this.merchantId,
    required this.categoryId,
    this.isActive = true,
    this.dealsExpiresAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String productName;
  final String? description;
  final String productUniqueId;
  final double? originalPrice;
  final double salePrice;
  final double? reviewScore;
  final int reviewCount;
  final String affiliateUrl;
  final String? imageUrl;
  final String merchantId;
  final String categoryId;
  final bool isActive;
  final DateTime? dealsExpiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  double? get discountPercent {
    if (originalPrice == null || originalPrice! <= 0) return null;
    return ((originalPrice! - salePrice) / originalPrice!) * 100;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      description: json['description']?.toString(),
      productUniqueId: json['productUniqueId']?.toString() ?? '',
      originalPrice: _toDouble(json['originalPrice']),
      salePrice: _toDouble(json['salePrice']) ?? 0,
      reviewScore: _toDouble(json['reviewScore']),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      affiliateUrl: json['affiliateUrl']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      merchantId: json['merchantId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      isActive: json['isActive'] ?? true,
      dealsExpiresAt: json['dealsExpiresAt'] != null
          ? DateTime.tryParse(json['dealsExpiresAt'].toString())
          : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'description': description,
        'productUniqueId': productUniqueId,
        'originalPrice': originalPrice,
        'salePrice': salePrice,
        'reviewScore': reviewScore,
        'reviewCount': reviewCount,
        'affiliateUrl': affiliateUrl,
        'imageUrl': imageUrl,
        'merchantId': merchantId,
        'categoryId': categoryId,
        'isActive': isActive,
        'dealsExpiresAt': dealsExpiresAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
