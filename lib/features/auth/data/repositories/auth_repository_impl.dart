import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiryKey = 'auth_expiry';
  static const String _userKey = 'user_data';

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> login(String email, String password, {bool rememberMe = false}) async {
    try {
      final response = await remoteDataSource.login(email, password, rememberMe: rememberMe);
      await _saveAuthData(response.token, response.refreshToken);
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
      await _saveAuthData(response.token, response.refreshToken);
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);
    return token != null || (refreshToken != null && refreshToken.isNotEmpty);
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await remoteDataSource.logout(refreshToken);
      } catch (_) {}
    }
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_expiryKey);
    await prefs.remove(_userKey);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await _getUsableToken();
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

  Future<void> _saveAuthData(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
    final decoded = JwtDecoder.decode(token);
    final expiry = DateTime.fromMillisecondsSinceEpoch(decoded['exp'] * 1000);
    await prefs.setString(_expiryKey, expiry.toIso8601String());
  }

  Future<String?> _getUsableToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null && !JwtDecoder.isExpired(token)) {
      return token;
    }

    final refreshToken = prefs.getString(_refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      await logout();
      return null;
    }

    try {
      final refreshed = await remoteDataSource.refreshSession(refreshToken);
      await _saveAuthData(refreshed.token, refreshed.refreshToken);
      return refreshed.token;
    } catch (_) {
      await logout();
      return null;
    }
  }
}