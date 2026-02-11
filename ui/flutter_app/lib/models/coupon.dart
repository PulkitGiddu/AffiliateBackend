/// Coupon model from backend. discountType: PERCENT | FLAT.
class Coupon {
  const Coupon({
    required this.id,
    required this.code,
    this.description,
    this.discountType,
    this.discountValue,
    this.expiryAt,
    this.merchantId,
    this.isActive = true,
  });

  final String id;
  final String code;
  final String? description;
  final String? discountType;
  final double? discountValue;
  final DateTime? expiryAt;
  final String? merchantId;
  final bool isActive;

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString(),
      discountType: json['discountType']?.toString(),
      discountValue: (json['discountValue'] as num?)?.toDouble(),
      expiryAt: json['expiryAt'] != null
          ? DateTime.tryParse(json['expiryAt'].toString())
          : null,
      merchantId: json['merchantId']?.toString(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'description': description,
        'discountType': discountType,
        'discountValue': discountValue,
        'expiryAt': expiryAt?.toIso8601String(),
        'merchantId': merchantId,
        'isActive': isActive,
      };
}
