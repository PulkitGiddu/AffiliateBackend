/// User model (from profile or auth context).
class User {
  const User({
    required this.id,
    required this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    this.referralCode,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;
  final String? referralCode;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? json['email_id']?.toString() ?? '',
      username: json['username']?.toString(),
      firstName: json['firstName'] ?? json['first_name']?.toString(),
      lastName: json['lastName'] ?? json['last_name']?.toString(),
      profilePictureUrl: json['profilePictureUrl'] ?? json['profile_picture_url']?.toString(),
      referralCode: json['referralCode'] ?? json['referral_code']?.toString(),
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'profilePictureUrl': profilePictureUrl,
        'referralCode': referralCode,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
