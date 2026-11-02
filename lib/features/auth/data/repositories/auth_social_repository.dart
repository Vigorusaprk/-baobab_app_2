import 'package:baobabe_0_2/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource.dart';

/// Connexions OAuth (Google / Apple), au même titre que le reste du flux
/// d'auth : toute action passe par le datasource, jamais par une table.
class AuthSocialRepository {
  AuthSocialRepository(this.remoteDataSource);

  final AuthRemoteDataSource remoteDataSource;

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
}
