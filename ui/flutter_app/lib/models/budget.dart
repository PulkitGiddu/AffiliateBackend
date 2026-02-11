/// Budget / price alert from backend.
class Budget {
  const Budget({
    required this.id,
    required this.userId,
    this.productName,
    this.targetPrice,
    this.currentPrice,
    this.alertEnabled = true,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String? productName;
  final double? targetPrice;
  final double? currentPrice;
  final bool alertEnabled;
  final DateTime? createdAt;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      productName: json['productName']?.toString(),
      targetPrice: (json['targetPrice'] as num?)?.toDouble(),
      currentPrice: (json['currentPrice'] as num?)?.toDouble(),
      alertEnabled: json['alertEnabled'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'productName': productName,
        'targetPrice': targetPrice,
        'currentPrice': currentPrice,
        'alertEnabled': alertEnabled,
        'createdAt': createdAt?.toIso8601String(),
      };
}
