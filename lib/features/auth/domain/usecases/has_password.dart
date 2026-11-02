import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class HasPasswordParams {
  const HasPasswordParams();
}

/// Savoir si l'utilisateur courant a déjà un mot de passe.
///
/// Convention : un utilisateur « a un mot de passe » dès lors que son
/// user_metadata Supabase porte la clé `password_set`, posée par
/// [SetPassword]. Un compte OAuth pur n'a jamais cette clé.
class HasPassword implements UseCase<bool, HasPasswordParams> {
  final AuthRepository repository;

  HasPassword(this.repository);

  @override
  Future<bool> call(HasPasswordParams params) async {
    return await repository.hasPassword();
  }
}
