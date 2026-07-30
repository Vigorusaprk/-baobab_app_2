import 'package:baobabe_0_2/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<void> requestEmailOtp(String email);

  Future<void> verifyEmailOtp(String email, String code);

  Future<void> signOut();

  Future<void> authWithApple();

  Future<Either<Failure, AuthResponse>> authWithGoogle();
}
