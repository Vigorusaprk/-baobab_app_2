import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource.dart';
import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  // Pas de SupabaseClient ici, uniquement la datasource
  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    return await remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<UserEntity> signUp({required String name, required String email, required String password, String? phone}) async {
    return await remoteDataSource.signUp(name: name, email: email, password: password, phone: phone);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<UserEntity?> checkAuthStatus() async {
    return await remoteDataSource.checkAuthStatus();
  }
}