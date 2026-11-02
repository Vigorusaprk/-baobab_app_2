import 'package:baobabe_0_2/core/errors/failure.dart';
import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:baobabe_0_2/core/services/session_hooks.dart';
import 'package:baobabe_0_2/features/auth/data/repositories/auth_social_repository.dart';

/// Accès aux cas d'usage d'authentification : e-mail + code, mot de
/// passe, déconnexion. Les connexions OAuth vivent dans
/// [AuthSocialRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.remoteDataSource)
    : _social = AuthSocialRepository(remoteDataSource);

  final AuthRemoteDataSource remoteDataSource;
  final AuthSocialRepository _social;

  @override
  Future<Either<Failure, void>> requestEmailOtp(String email) async {
    try {
      await remoteDataSource.requestEmailOtp(email);
      return const Right(null);
    } catch (e) {
      if (e is AuthApiException) {
        return Left(AuthFailure(message: e.message));
      }
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmailOtp(
    String email,
    String code,
  ) async {
    try {
      await remoteDataSource.verifyEmailOtp(email, code);
      return const Right(null);
    } catch (e) {
      if (e is AuthApiException) {
        return Left(AuthFailure(message: e.message));
      }
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setPassword(String password) async {
    try {
      await remoteDataSource.setPassword(password);
      return const Right(null);
    } catch (e) {
      if (e is AuthException) {
        return Left(AuthFailure(message: e.message));
      }
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> hasPassword() async {
    try {
      return await remoteDataSource.hasPassword();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await SessionHooks.runBeforeSignOut();
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      // Il y avait ici `localFailure!.message`, sur une variable toujours
      // nulle : au premier échec réseau, cette ligne levait au lieu de
      // renvoyer une erreur. L'exception traversait le bloc, qui n'émettait
      // alors **aucun** état — et l'écran qui attend l'issue de la
      // déconnexion restait suspendu pour de bon.
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> authWithGoogle() =>
      _social.authWithGoogle();

  @override
  Future<Either<Failure, void>> authWithApple() => _social.authWithApple();
}
