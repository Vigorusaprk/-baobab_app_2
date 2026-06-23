import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository authRepository;

  SignUpUseCase(this.authRepository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) {
    return authRepository.signUp(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
  }
}