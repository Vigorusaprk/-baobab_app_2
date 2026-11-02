import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SetPasswordParams {
  final String password;

  const SetPasswordParams({required this.password});
}

/// Définit un mot de passe pour l'utilisateur courant.
///
/// Un commerçant qui arrive via Google ou Apple n'a pas de mot de
/// passe : l'app publique s'y connecte par code e-mail / OAuth, et
/// l'espace commerçant, lui, exige e-mail + mot de passe. Ce cas
/// d'usage pose ce mot de passe — la clé `password_set` du metadata
/// signale ensuite qu'il a été défini.
class SetPassword implements UseCase<Either<Failure, void>, SetPasswordParams> {
  final AuthRepository repository;

  SetPassword(this.repository);

  @override
  Future<Either<Failure, void>> call(SetPasswordParams params) async {
    return await repository.setPassword(params.password);
  }
}
