import 'package:baobabe_0_2/core/errors/failure.dart';
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/has_password.dart';
import 'package:baobabe_0_2/features/auth/domain/validators/password_validator.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('PasswordValidator', () {
    test('valide un mot de passe conforme à la politique', () {
      expect(PasswordValidator.isValid('ab12cd34ef'), isTrue);
      expect(PasswordValidator.isValid('Zz9aBc8dEf'), isTrue);
    });

    test('refuse un mot de passe trop court', () {
      expect(PasswordValidator.isValid('Ab1d2Ef'), isFalse);
    });

    test('refuse un mot de passe sans chiffre', () {
      expect(PasswordValidator.isValid('abcdefghij'), isFalse);
    });

    test('refuse un mot de passe sans lettre', () {
      expect(PasswordValidator.isValid('1234567890'), isFalse);
    });

    test('refuse un mot de passe identique à l\'e-mail', () {
      expect(
        PasswordValidator.isValid('user@baobab.cd', email: 'user@baobab.cd'),
        isFalse,
      );
      expect(
        PasswordValidator.isValid('User@Baobab.Cd', email: 'user@baobab.cd'),
        isFalse,
      );
    });

    test('refuse les mots de passe évidents', () {
      expect(PasswordValidator.isValid('Password1'), isFalse);
      expect(PasswordValidator.isValid('qwerty12'), isFalse);
    });
  });

  group('HasPassword', () {
    test('retourne true quand le compte a un mot de passe', () async {
      final usecase = HasPassword(
        _FakeAuthRepository(hasPasswordResult: true),
      );
      expect(await usecase(const HasPasswordParams()), true);
    });

    test('retourne false quand le compte n\'a pas de mot de passe', () async {
      final usecase = HasPassword(
        _FakeAuthRepository(hasPasswordResult: false),
      );
      expect(await usecase(const HasPasswordParams()), false);
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.hasPasswordResult});

  final bool hasPasswordResult;

  @override
  Future<Either<Failure, void>> requestEmailOtp(String email) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> verifyEmailOtp(String email, String code) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);

  @override
  Future<Either<Failure, AuthResponse>> authWithGoogle() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> authWithApple() async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> setPassword(String password) async =>
      const Right(null);

  @override
  Future<bool> hasPassword() async => hasPasswordResult;
}
