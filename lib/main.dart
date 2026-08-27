import 'package:baobabe_0_2/app/main_app.dart';
import 'package:baobabe_0_2/core/constants/supabase_client.dart';
import 'package:baobabe_0_2/core/database/local_cache.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/services/sync_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'core/constants/firebase_options.dart';

/// Kept alive for the app lifetime so its connectivity listener keeps running.
late final SyncManager syncManager;

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Cache local ouvert avant tout appel réseau : les sources de données
  // écrivent leur cache dans le même `try` que la requête, donc un cache
  // non initialisé se confondrait avec une panne réseau.
  await LocalCache.initialize();

  await SupabaseClientWrapper.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final reservationApiService = ReservationApiService(
    SupabaseClientWrapper.client,
  );
  syncManager = SyncManager(
    SyncService(reservationApiService),
    reservationApiService,
  );

  runApp(const MainApp());
}
