import 'package:baobabe_0_2/features/auth/data/models/user_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(String email, String password, {bool rememberMe = false});
  Future<AuthResponse> signUp(String name, String email, String password, {String? imgUrl});
  Future<UserInfo> getCurrentUser(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AuthRemoteDataSourceImpl({required this.dio, this.baseUrl = 'http://10.0.2.2:3000/api'});

  @override
  Future<AuthResponse> login(String email, String password, {bool rememberMe = false}) async {
    final response = await dio.post(
      '$baseUrl/auth/login',
      data: {
        'email': email,
        'password': password,
        'rememberMe': rememberMe,
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> signUp(String name, String email, String password, {String? imgUrl}) async {
    final response = await dio.post(
      '$baseUrl/auth/signup',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'imgUrl': imgUrl,
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<UserInfo> getCurrentUser(String token) async {
    final response = await dio.get(
      '$baseUrl/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return UserInfo.fromJson(response.data);
  }
}