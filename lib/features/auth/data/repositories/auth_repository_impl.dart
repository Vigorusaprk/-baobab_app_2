import 'package:baobabe_0_2/core/errors/failure.dart';
import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:baobabe_0_2/core/services/session_hooks.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.remoteDataSource);

  final AuthRemoteDataSource remoteDataSource;

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
  Future<Either<Failure, AuthResponse>> authWithGoogle() async {
    try {
      final remoteResult = await remoteDataSource.authWithGoogle();
      final authResponse = remoteResult.getOrElse(() => throw Exception());
      return Right(authResponse);
    } catch (e) {
      if (e is AuthApiException) {
        return Left(AuthFailure(message: e.message));
      }
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> authWithApple() async {
    try {
      await remoteDataSource.authWithApple();
      return const Right(null);
    } catch (e) {
      if (e is AuthApiException) {
        return Left(AuthFailure(message: e.message));
      }
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Avant de fermer la session, et non après : passé `signOut`, il n'y a
      // plus de jeton à présenter au serveur, et l'appareil resterait
      // rattaché à ce compte. La personne suivante à se connecter sur ce
      // téléphone recevrait alors ses notifications.
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
}
