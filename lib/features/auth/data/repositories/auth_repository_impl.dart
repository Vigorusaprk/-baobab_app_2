import 'dart:convert';
import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  static const String _tokenKey = 'auth_token';
  static const String _expiryKey = 'auth_expiry';
  static const String _userKey = 'user_data';

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> login(String email, String password, {bool rememberMe = false}) async {
    try {
      final response = await remoteDataSource.login(email, password, rememberMe: rememberMe);
      await _saveAuthData(response.token);
      return UserEntity(
        id: response.id,
        name: response.name,
        email: response.email,
        imgUrl: response.imgUrl,
      );
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  @override
  Future<UserEntity> signUp(String name, String email, String password, {String? imgUrl}) async {
    try {
      final response = await remoteDataSource.signUp(name, email, password, imgUrl: imgUrl);
      await _saveAuthData(response.token);
      return UserEntity(
        id: response.id,
        name: response.name,
        email: response.email,
        imgUrl: response.imgUrl,
      );
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _getValidToken();
    return token != null;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryKey);
    await prefs.remove(_userKey);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await _getValidToken();
    if (token == null) return null;
    try {
      final userInfo = await remoteDataSource.getCurrentUser(token);
      return UserEntity(
        id: userInfo.id,
        name: userInfo.name,
        email: userInfo.email,
        imgUrl: userInfo.imgUrl,
      );
    } catch (e) {
      await logout();
      return null;
    }
  }

  Future<void> _saveAuthData(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    final decoded = JwtDecoder.decode(token);
    final expiry = DateTime.fromMillisecondsSinceEpoch(decoded['exp'] * 1000);
    await prefs.setString(_expiryKey, expiry.toIso8601String());
  }

  Future<String?> _getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return null;

    final expiryStr = prefs.getString(_expiryKey);
    if (expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry)) {
        await logout();
        return null;
      }
    } else {
      if (JwtDecoder.isExpired(token)) {
        await logout();
        return null;
      }
    }
    return token;
  }
}