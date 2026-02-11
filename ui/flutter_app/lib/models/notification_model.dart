/// Notification from backend.
class NotificationModel {
  const NotificationModel({
    required this.id,
    this.userId,
    this.message,
    this.isRead = false,
    this.createdAt,
  });

  final String id;
  final String? userId;
  final String? message;
  final bool isRead;
  final DateTime? createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString(),
      message: json['message']?.toString(),
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'message': message,
        'isRead': isRead,
        'createdAt': createdAt?.toIso8601String(),
      };
}
