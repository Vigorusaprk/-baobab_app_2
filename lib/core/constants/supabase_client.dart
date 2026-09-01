import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientWrapper {
  static SupabaseClient? _client;

  /// Le client, une fois [initialize] appelé.
  static SupabaseClient get client => _client!;

  /// Le client **s'il existe**.
  ///
  /// Sous test — et pendant le tout premier instant du démarrage — Supabase
  /// n'est pas initialisé. Un code qui se contente de demander « qui est
  /// connecté ? » ne doit pas planter pour autant : la bonne réponse est
  /// « personne », pas une exception.
  static SupabaseClient? get clientOrNull => _client;

  static Future<void> initialize() async {
    // 1. Utilisez l'URL officielle de votre projet Supabase (sans /rest/v1)
    const String supabaseUrl = 'https://wrutwzbtnquxigxetxfx.supabase.co';

    // 2. La clé publiable du projet (l'ancien nom était « anon »).
    const String publishableKey =
        'sb_publishable_lCKQ9R0_LzFk6EbRYuDnbQ_WITRinDO';

    final supabase = await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: publishableKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    _client = supabase.client;
  }
}
