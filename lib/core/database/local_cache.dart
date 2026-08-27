import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

/// Cache local de l'application, adossé à Hive.
///
/// Remplace le cache `sqflite` : celui-ci n'existe pas sur le web, où le
/// moindre appel levait une exception. Comme l'écriture du cache se fait à
/// l'intérieur du `try` qui entoure l'appel réseau, cette exception était
/// interprétée comme un échec réseau et faisait échouer l'écran entier —
/// l'accueil ne s'affichait donc jamais sur le web, même en ligne.
///
/// L'API publique est volontairement identique à celle de l'ancien
/// `DatabaseHelper` ([saveCache] / [getCache]) pour que les appelants
/// existants n'aient rien à changer.
class LocalCache {
  LocalCache._();

  static final LocalCache instance = LocalCache._();

  static const String _cacheBoxName = 'baobab_cache';
  static const String _queueBoxName = 'baobab_pending_operations';

  static Box<String>? _cacheBox;
  static Box<Map>? _queueBox;

  /// À appeler une seule fois au démarrage, avant `runApp`.
  ///
  /// Ouvre les boîtes une bonne fois pour toutes afin que les lectures et
  /// écritures ultérieures soient synchrones côté Hive, et donc qu'un cache
  /// indisponible ne puisse plus se confondre avec une panne réseau.
  ///
  /// [path] n'est utilisé que par les tests, qui n'ont pas de plugin de
  /// chemin d'application ; en production on laisse Hive choisir.
  static Future<void> initialize({String? path}) async {
    if (path != null) {
      Hive.init(path);
    } else {
      await Hive.initFlutter();
    }
    // On rouvre si la boîte a été fermée : un `??=` laisserait une
    // référence fermée en place et le cache resterait inerte pour toute la
    // durée du process, sans le moindre signal.
    if (!(_cacheBox?.isOpen ?? false)) {
      _cacheBox = await Hive.openBox<String>(_cacheBoxName);
    }
    if (!(_queueBox?.isOpen ?? false)) {
      _queueBox = await Hive.openBox<Map>(_queueBoxName);
    }
  }

  bool get _isReady => _cacheBox?.isOpen ?? false;

  // --- Cache clé/valeur -------------------------------------------------

  /// Écrit [data] sous [key]. N'échoue jamais : le cache est un confort,
  /// pas une source de vérité, et son indisponibilité ne doit pas faire
  /// échouer l'opération métier qui l'entoure.
  Future<void> saveCache(String key, String data) async {
    if (!_isReady) return;
    try {
      await _cacheBox!.put(key, data);
    } catch (_) {
      // Ignoré volontairement : voir la remarque ci-dessus.
    }
  }

  /// Lit la valeur de [key], ou null si absente ou illisible.
  Future<String?> getCache(String key) async {
    if (!_isReady) return null;
    try {
      return _cacheBox!.get(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> removeCache(String key) async {
    if (!_isReady) return;
    try {
      await _cacheBox!.delete(key);
    } catch (_) {
      // Ignoré : suppression best-effort.
    }
  }

  // --- File des opérations hors-ligne -----------------------------------
  //
  // Reprend le rôle de la table `pending_operations` : les écritures faites
  // hors connexion sont empilées ici puis rejouées au retour du réseau.

  /// Empile une opération à rejouer. Retourne son identifiant, ou null si
  /// la file est indisponible.
  Future<int?> enqueueOperation(Map<String, dynamic> operation) async {
    if (!(_queueBox?.isOpen ?? false)) return null;
    try {
      return await _queueBox!.add(operation);
    } catch (_) {
      return null;
    }
  }

  /// Opérations en attente, avec leur clé Hive pour pouvoir les mettre à
  /// jour ou les retirer une fois traitées.
  Future<List<({dynamic key, Map<String, dynamic> data})>>
  pendingOperations() async {
    if (!(_queueBox?.isOpen ?? false)) return const [];
    try {
      return _queueBox!.keys
          .map(
            (key) => (
              key: key,
              data: Map<String, dynamic>.from(_queueBox!.get(key) ?? const {}),
            ),
          )
          .where((entry) => entry.data.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> updateOperation(dynamic key, Map<String, dynamic> data) async {
    if (!(_queueBox?.isOpen ?? false)) return;
    try {
      await _queueBox!.put(key, data);
    } catch (_) {
      // Ignoré : la file est best-effort.
    }
  }

  Future<void> removeOperation(dynamic key) async {
    if (!(_queueBox?.isOpen ?? false)) return;
    try {
      await _queueBox!.delete(key);
    } catch (_) {
      // Ignoré : la file est best-effort.
    }
  }

  // --- Aides JSON -------------------------------------------------------

  /// Écrit une valeur JSON-sérialisable.
  Future<void> saveJson(String key, Object? value) =>
      saveCache(key, jsonEncode(value));

  /// Lit une valeur JSON, ou null si absente ou corrompue.
  Future<dynamic> readJson(String key) async {
    final raw = await getCache(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      // Entrée corrompue : on la retire pour ne pas rester bloqué dessus.
      await removeCache(key);
      return null;
    }
  }
}
