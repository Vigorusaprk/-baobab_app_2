import 'dart:convert';
import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource.dart';
import 'package:baobabe_0_2/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      await _saveAuthData(response.token, response);
      return UserEntity(
        id: response.id,
        name: response.name,
        email: response.email,
        imgUrl: response.imgUrl,
        loginTime: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  @override
  Future<UserEntity> signUp(String name, String email, String password, {String? imgUrl}) async {
    try {
      final response = await remoteDataSource.signUp(name, email, password, imgUrl: imgUrl);
      await _saveAuthData(response.token, response);
      return UserEntity(
        id: response.id,
        name: response.name,
        email: response.email,
        imgUrl: response.imgUrl,
        loginTime: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await _getToken();
    if (token == null) return null;
    try {
      final response = await remoteDataSource.getCurrentUser(token);
      return UserEntity(
        id: response.id,
        name: response.name,
        email: response.email,
        imgUrl: response.imgUrl,
        loginTime: DateTime.now(),
      );
    } catch (e) {
      // Token invalide -> on logout
      await logout();
      return null;
    }
  }

  Future<void> _saveAuthData(String token, AuthResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    final userJson = json.encode({
      'id': response.id,
      'name': response.name,
      'email': response.email,
      'imgUrl': response.imgUrl,
      'loginTime': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_userKey, userJson);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}