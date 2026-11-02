import 'package:baobabe_0_2/core/constants/test_account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Envoi du code e-mail, vérification, et test de connexion des
/// comptes de démonstration.
class AuthOtpDataSource {
  AuthOtpDataSource(this.supabaseClient);

  final SupabaseClient supabaseClient;

  Future<void> requestEmailOtp(String email) async {
    if (email == TestAccount.appleEmailTest ||
        email == TestAccount.googleEmailTest ||
        email == TestAccount.userEmailTest) {
      return;
    }
    await supabaseClient.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
    );
  }

  Future<void> verifyEmailOtp(String email, String code) async {
    if (email == TestAccount.appleEmailTest &&
            code == TestAccount.appleOtpTest ||
        email == TestAccount.googleEmailTest &&
            code == TestAccount.googleOtpTest ||
        email == TestAccount.userEmailTest && code == TestAccount.userOtpTest) {
      await connectionTest(email);
      return;
    }
    await supabaseClient.auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.email,
    );
  }

  Future<void> connectionTest(String email) async {
    final String password = email == TestAccount.appleEmailTest
        ? TestAccount.appleMpTest
        : email == TestAccount.googleEmailTest
        ? TestAccount.googleMpTest
        : TestAccount.userMpTest;
    try {
      await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthApiException {
      rethrow;
    } catch (e) {
      throw AuthApiException(e.toString());
    }
  }
}
