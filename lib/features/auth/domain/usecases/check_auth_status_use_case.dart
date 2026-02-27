// File: check_auth_status_use_case.dart
import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<UserEntity?> execute() async {
    final user = await repository.getCurrentUser();
    if (user == null) return null;

    final isAuthenticated = await repository.isAuthenticated();
    return isAuthenticated ? user : null;
  }
}