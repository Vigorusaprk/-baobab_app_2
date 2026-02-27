import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> signUp(String name, String email, String password);
  Future<bool> isAuthenticated();
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}