/// Single price history record from backend.
class PriceHistoryEntry {
  const PriceHistoryEntry({
    required this.id,
    required this.productId,
    this.price,
    this.recordedAt,
  });

  final String id;
  final String productId;
  final double? price;
  final DateTime? recordedAt;

  factory PriceHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PriceHistoryEntry(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble(),
      recordedAt: json['recordedAt'] != null
          ? DateTime.tryParse(json['recordedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'price': price,
        'recordedAt': recordedAt?.toIso8601String(),
      };
}
