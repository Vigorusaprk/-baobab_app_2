// core/constants/supabase_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientWrapper {
  static late final SupabaseClient client;

  static Future<void> initialize() async {
    // 1. Utilisez l'URL officielle de votre projet Supabase (sans /rest/v1)
    const String supabaseUrl = 'https://wrutwzbtnquxigxetxfx.supabase.co';

    // 2. Utilisez votre clé publique 'anon'
    const String anonKey = 'sb_publishable_lCKQ9R0_LzFk6EbRYuDnbQ_WITRinDO';

    final supabase = await Supabase.initialize(
      url: supabaseUrl,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    client = supabase.client;
  }
}