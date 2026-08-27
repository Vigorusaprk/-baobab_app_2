import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import '../database/local_cache.dart';
import '../../features/booking_page/data/models/reservation_service.dart';

class SyncService {
  final LocalCache _db = LocalCache.instance;
  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();
  final ReservationApiService _reservationApi;

  SyncService(this._reservationApi);

  /// Logique générique pour traiter une opération
  Future<void> handleOperation({
    required String tableName,
    required String operationType,
    required Map<String, dynamic> data,
    required Future<void> Function() apiCall,
  }) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = connectivityResult.any(
      (element) => element != ConnectivityResult.none,
    );

    if (isOnline) {
      try {
        _logger.i("Network: Online. Attempting API call for $tableName...");
        await apiCall();
        _logger.i("Sync: Success for $tableName.");
      } catch (e) {
        _logger.e("Sync: API failed, saving to local queue: $e");
        await _saveToLocal(tableName, operationType, data);
      }
    } else {
      _logger.w(
        "Network: Offline. Saving $tableName operation to local storage.",
      );
      await _saveToLocal(tableName, operationType, data);
    }
  }

  /// Sauvegarde locale en cas d'échec ou d'absence de réseau
  Future<void> _saveToLocal(
    String table,
    String type,
    Map<String, dynamic> data,
  ) async {
    await _db.enqueueOperation({
      'table_name': table,
      'operation_type': type,
      'data': jsonEncode(data),
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
    _logger.d("Local: Operation stored in pending queue.");
  }

  /// Exemple spécifique pour une réservation
  Future<void> createReservation(Map<String, dynamic> reservationData) async {
    await handleOperation(
      tableName: 'reservations',
      operationType: 'INSERT',
      data: reservationData,
      apiCall: () async {
        await _reservationApi.createReservation(
          businessId: reservationData['business_id'],
          type: reservationData['type'],
          reservationDate: DateTime.parse(reservationData['reservation_date']),
          totalAmount: (reservationData['total_amount'] as num).toDouble(),
          details: reservationData['details'],
          userId: reservationData['user_id'],
          establishmentName: reservationData['establishment_name'],
        );
      },
    );
  }
}

class SyncManager {
  final SyncService syncService;
  final ReservationApiService _reservationApi;
  final LocalCache _db = LocalCache.instance;
  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();

  SyncManager(this.syncService, this._reservationApi) {
    _logger.i("SyncManager: Initialized.");
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        _logger.i("SyncManager: Network recovered. Starting sync...");
        processPendingOperations();
      }
    });
  }

  Future<void> processPendingOperations() async {
    final all = await _db.pendingOperations();
    final pending = all.where((e) => e.data['status'] == 'pending').toList()
      ..sort(
        (a, b) => (a.data['created_at'] as String? ?? '').compareTo(
          b.data['created_at'] as String? ?? '',
        ),
      );

    if (pending.isEmpty) {
      _logger.d("SyncManager: No pending operations to sync.");
      return;
    }

    _logger.i("SyncManager: Found ${pending.length} pending operations.");

    for (final op in pending) {
      final key = op.key;
      try {
        await _db.updateOperation(key, {...op.data, 'status': 'syncing'});

        final data = jsonDecode(op.data['data'] as String);

        if (op.data['table_name'] == 'reservations') {
          if (op.data['operation_type'] == 'INSERT') {
            await _reservationApi.createReservation(
              businessId: data['business_id'],
              type: data['type'],
              reservationDate: DateTime.parse(data['reservation_date']),
              totalAmount: (data['total_amount'] as num).toDouble(),
              details: data['details'],
              userId: data['user_id'],
              establishmentName: data['establishment_name'],
            );
          }
        }

        await _db.removeOperation(key);
        _logger.i("SyncManager: Item $key synced and removed.");
      } catch (e) {
        _logger.e("SyncManager: Failed to sync $key: $e");
        await _db.updateOperation(key, {
          ...op.data,
          'status': 'failed',
          'error_message': e.toString(),
        });
      }
    }
  }

  Future<void> retryAllPending() async {
    _logger.i("SyncManager: Manual retry started.");
    await processPendingOperations();
  }
}
