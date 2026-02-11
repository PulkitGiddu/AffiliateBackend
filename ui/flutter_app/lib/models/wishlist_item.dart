/// Wishlist item from backend (userId, productId, createdAt).
class WishlistItem {
  const WishlistItem({
    required this.userId,
    required this.productId,
    this.createdAt,
  });

  final String userId;
  final String productId;
  final DateTime? createdAt;

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      userId: json['userId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'productId': productId,
        'createdAt': createdAt?.toIso8601String(),
      };
}
