class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? imgUrl;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final String? businessId;
  final String role;
  final String? phone;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.imgUrl,
    this.createdAt,
    this.lastLogin,
    this.businessId,
    required this.role,
    this.phone,
  });
}
