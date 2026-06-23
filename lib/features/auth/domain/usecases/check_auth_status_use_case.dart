import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository authRepository;

  CheckAuthStatusUseCase(this.authRepository);

  Future<UserEntity?> call() {
    return authRepository.checkAuthStatus();
  }
}