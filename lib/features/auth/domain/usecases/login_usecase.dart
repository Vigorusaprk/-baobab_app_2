import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> execute(String email, String password) {
    return repository.login(email, password);
  }
}
