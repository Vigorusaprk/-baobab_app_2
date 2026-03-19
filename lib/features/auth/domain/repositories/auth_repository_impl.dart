import 'dart:convert';
import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _userKey = 'current_user';
  static const String _sessionExpiryKey = 'session_expiry';
  static const int _sessionDurationHours = 2;

  @override
  Future<UserEntity> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.isNotEmpty) {
      final user = UserEntity(
        id: '1',
        name: 'Utilisateur Test',
        imgUrl: '',
        email: email,
        loginTime: DateTime.now(),
      );

      await _saveUserToPrefs(user);
      return user;
    } else {
      throw Exception('Email ou mot de passe invalide');
    }
  }

  @override
  Future<UserEntity> signUp(String name, String email, String password, {String? imgUrl}) async {
    await Future.delayed(const Duration(seconds: 1));

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      final user = UserEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        imgUrl: imgUrl,
        email: email,
        loginTime: DateTime.now(),
      );

      await _saveUserToPrefs(user);
      return user;
    } else {
      throw Exception('Tous les champs sont requis');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final user = await getCurrentUser();
    if (user == null) return false;

    // Vérifier si la session a expiré
    final expiryTime = user.loginTime!.add(const Duration(hours: 2));
    final now = DateTime.now();

    if (now.isAfter(expiryTime)) {
      await logout();
      return false;
    }

    return true;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_sessionExpiryKey);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null) return null;

    try {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserEntity.fromJson(userMap);
    } catch (e) {
      await logout();
      return null;
    }
  }

  Future<void> _saveUserToPrefs(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = json.encode(user.toJson());

    await prefs.setString(_userKey, userJson);

    // Sauvegarder le temps d'expiration
    final expiryTime = DateTime.now().add(const Duration(hours: _sessionDurationHours));
    await prefs.setString(_sessionExpiryKey, expiryTime.toIso8601String());
  }

  Future<DateTime?> getSessionExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_sessionExpiryKey);
    return expiryString != null ? DateTime.parse(expiryString) : null;
  }
}