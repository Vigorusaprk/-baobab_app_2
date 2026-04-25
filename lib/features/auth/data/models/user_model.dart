import 'package:jwt_decoder/jwt_decoder.dart';

class LoginRequest {
  final String email;
  final String password;
  LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class SignUpRequest {
  final String name;
  final String email;
  final String password;
  final String? imgUrl;
  SignUpRequest({required this.name, required this.email, required this.password, this.imgUrl});
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'imgUrl': imgUrl,
  };
}

// Réponse pour login / signup (avec token)
class AuthResponse {
  final String id;
  final String name;
  final String email;
  final String? imgUrl;
  final String token;
  final String refreshToken;
  final DateTime expirationDate;

  AuthResponse({
    required this.id,
    required this.name,
    required this.email,
    this.imgUrl,
    required this.token,
    required this.refreshToken,
    required this.expirationDate,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = (json['accessToken'] ?? json['token']) as String;
    final refreshToken = (json['refreshToken'] ?? '') as String;
    final decoded = JwtDecoder.decode(token);
    final expirationDate = DateTime.fromMillisecondsSinceEpoch(decoded['exp'] * 1000);
    return AuthResponse(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      imgUrl: json['imgUrl']?.toString(),
      token: token,
      refreshToken: refreshToken,
      expirationDate: expirationDate,
    );
  }
}

// Informations utilisateur (sans token)
class UserInfo {
  final String id;
  final String name;
  final String email;
  final String? imgUrl;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    this.imgUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      imgUrl: json['imgUrl']?.toString(),
    );
  }
}