/// Backend auth response: userId, email, token.
class AuthResponse {
  const AuthResponse({
    required this.userId,
    required this.email,
    required this.token,
  });

  final String userId;
  final String email;
  final String token;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? json['email_id']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() =>
      {'userId': userId, 'email': email, 'token': token};
}
