import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import '../database/database_helper.dart';
import '../../features/booking_page/data/models/reservation_service.dart';

class SyncService {
  final DatabaseHelper _db = DatabaseHelper.instance;
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
    await _db.insert('pending_operations', {
      'table_name': table,
      'operation_type': type,
      'data': jsonEncode(data),
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
    _logger.d("Local: Operation stored in pending_operations.");
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
  final DatabaseHelper _db = DatabaseHelper.instance;
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
    final pending = await _db.query(
      'pending_operations',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );

    if (pending.isEmpty) {
      _logger.d("SyncManager: No pending operations to sync.");
      return;
    }

    _logger.i("SyncManager: Found ${pending.length} pending operations.");

    for (var op in pending) {
      final id = op['id'];
      try {
        await _db.update(
          'pending_operations',
          {'status': 'syncing'},
          where: 'id = ?',
          whereArgs: [id],
        );

        final data = jsonDecode(op['data'] as String);

        if (op['table_name'] == 'reservations') {
          if (op['operation_type'] == 'INSERT') {
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

        await _db.delete(
          'pending_operations',
          where: 'id = ?',
          whereArgs: [id],
        );
        _logger.i("SyncManager: Item $id synced and removed.");
      } catch (e) {
        _logger.e("SyncManager: Failed to sync $id: $e");
        await _db.update(
          'pending_operations',
          {'status': 'failed', 'error_message': e.toString()},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
  }

  Future<void> retryAllPending() async {
    _logger.i("SyncManager: Manual retry started.");
    await processPendingOperations();
  }
}
