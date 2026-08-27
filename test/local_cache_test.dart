import 'dart:io';

import 'package:baobabe_0_2/core/database/local_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Vérifie le cache local qui remplace sqflite. L'enjeu n'est pas Hive
/// lui-même mais le contrat attendu par les sources de données : la même
/// API qu'avant, et surtout un cache qui ne lève jamais — sinon son échec
/// serait pris pour une panne réseau et ferait échouer l'écran entier,
/// exactement ce qui rendait l'accueil inutilisable sur le web.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('baobab_cache_test');
    await LocalCache.initialize(path: tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('une valeur écrite est relue à l\'identique', () async {
    final cache = LocalCache.instance;
    await cache.saveCache('home_feed_all', '{"discover":[1,2,3]}');

    expect(await cache.getCache('home_feed_all'), '{"discover":[1,2,3]}');
  });

  test('une clé absente renvoie null au lieu de lever', () async {
    expect(await LocalCache.instance.getCache('jamais_ecrit'), isNull);
  });

  test('le JSON fait un aller-retour complet', () async {
    final cache = LocalCache.instance;
    await cache.saveJson('categories', [
      {'slug': 'restaurant', 'label': 'Restaurants'},
      {'slug': 'event', 'label': 'Événements'},
    ]);

    final read = await cache.readJson('categories') as List;
    expect(read, hasLength(2));
    expect(read.first['slug'], 'restaurant');
  });

  test('une entrée corrompue est purgée au lieu de bloquer', () async {
    final cache = LocalCache.instance;
    await cache.saveCache('categories', 'ceci n est pas du json');

    expect(await cache.readJson('categories'), isNull);
    // La purge évite de rester bloqué indéfiniment sur la même entrée.
    expect(await cache.getCache('categories'), isNull);
  });

  test('la file hors-ligne empile, relit et retire', () async {
    final cache = LocalCache.instance;
    await cache.enqueueOperation({
      'table_name': 'reservations',
      'operation_type': 'INSERT',
      'status': 'pending',
      'created_at': DateTime(2026, 1, 1).toIso8601String(),
    });

    var pending = await cache.pendingOperations();
    expect(pending, hasLength(1));
    expect(pending.first.data['table_name'], 'reservations');

    await cache.updateOperation(pending.first.key, {
      ...pending.first.data,
      'status': 'failed',
    });
    pending = await cache.pendingOperations();
    expect(pending.first.data['status'], 'failed');

    await cache.removeOperation(pending.first.key);
    expect(await cache.pendingOperations(), isEmpty);
  });
}
