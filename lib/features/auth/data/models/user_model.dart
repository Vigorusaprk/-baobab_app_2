// File: features/auth/data/models/user_model.dart
import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final String? imgUrl;
  final String email;
  final String? loginTime;

  UserModel({required this.id, required this.name, required this.email,required this.imgUrl, this.loginTime});

  // From Entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      imgUrl: entity.imgUrl,
      email: entity.email,
      loginTime: entity.loginTime?.toIso8601String(),
    );
  }

  // To Entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      imgUrl : imgUrl,
      email: email,
      loginTime: loginTime != null ? DateTime.parse(loginTime!) : null,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imgUrl': imgUrl,
      'email': email,
      'loginTime': loginTime,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      imgUrl: json['imgUrl'],
      loginTime: json['loginTime'],
    );
  }
}