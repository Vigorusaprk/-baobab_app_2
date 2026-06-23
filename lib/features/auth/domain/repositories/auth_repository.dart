import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  });
  Future<void> logout();
  Future<UserEntity?> checkAuthStatus();
}