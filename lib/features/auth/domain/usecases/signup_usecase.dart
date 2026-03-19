import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserEntity> execute(String name, String email, String password, String? imgUrl) {
    return repository.signUp(name, email, password, imgUrl: imgUrl);
  }
}

