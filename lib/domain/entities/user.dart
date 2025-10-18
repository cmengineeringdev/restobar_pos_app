class User {
  final String userId;
  final String username;
  final String companyCode;
  final String firstName;
  final String lastName;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  User({
    required this.userId,
    required this.username,
    required this.companyCode,
    required this.firstName,
    required this.lastName,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  String get fullName => '$firstName $lastName';

  bool get isTokenExpired => DateTime.now().isAfter(expiresAt);

  User copyWith({
    String? userId,
    String? username,
    String? companyCode,
    String? firstName,
    String? lastName,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      companyCode: companyCode ?? this.companyCode,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() {
    return 'User{userId: $userId, username: $username, companyCode: $companyCode, fullName: $fullName}';
  }
}
