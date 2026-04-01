// Request models
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

// Response model
class AuthResponse {
  final String id;
  final String name;
  final String email;
  final String imgUrl;
  final String token;
  AuthResponse({required this.id, required this.name, required this.email, required this.imgUrl, required this.token});
  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    imgUrl: json['imgUrl'] ?? '',
    token: json['token'],
  );
}