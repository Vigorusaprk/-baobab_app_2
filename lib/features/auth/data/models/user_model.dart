import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.imgUrl,
    super.createdAt,
    super.lastLogin,
    super.businessId,
    required super.role,
    super.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      imgUrl: json['img_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login'] as String) : null,
      businessId: json['business_id'] as String?,
      role: json['role'] as String? ?? 'user',
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'img_url': imgUrl,
      'created_at': createdAt?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'business_id': businessId,
      'role': role,
      'phone': phone,
    };
  }
}