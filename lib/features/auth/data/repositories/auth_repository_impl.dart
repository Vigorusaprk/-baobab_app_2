import 'package:baobabe_0_2/core/errors/failure.dart';
import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

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
    Failure? localFailure;

    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: localFailure!.message));
    }
  }
}
