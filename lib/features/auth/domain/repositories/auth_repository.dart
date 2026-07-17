import 'package:baobabe_0_2/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> requestEmailOtp(String email);

  Future<Either<Failure, void>> verifyEmailOtp(String email, String code);

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, AuthResponse>> authWithGoogle();

  Future<Either<Failure, void>> authWithApple();
}