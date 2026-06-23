import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository authRepository;

  LogoutUseCase(this.authRepository);

  Future<void> call() {
    return authRepository.logout();
  }
}