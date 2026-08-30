import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/core/database/local_cache.dart';

class OrderApiService {
  final SupabaseClient _supabase;
  final LocalCache _db = LocalCache.instance;
  final Connectivity _connectivity = Connectivity();

  OrderApiService([SupabaseClient? supabase])
    : _supabase = supabase ?? Supabase.instance.client;

  /// Délègue à l'Edge Function `create-order`, qui insère la commande et ses
  /// lignes dans une seule transaction Postgres (create_order_with_items) —
  /// plus de risque de commande orpheline si l'insertion des lignes échoue
  /// après coup, comme c'était possible avec les deux inserts séquentiels
  /// précédents.
  Future<void> createOrder({
    required String userId,
    required String businessId,
    required List<OrderItem> items,
    String? deliveryAddress,
    double? deliveryFee,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      await _supabase.functions.invoke(
        'create-order',
        method: HttpMethod.post,
        body: {
          'businessId': businessId,
          // On n'envoie que quoi et combien : les prix, les noms et le
          // total sont établis par le serveur à partir du catalogue. Le
          // client n'a plus voix au chapitre sur le montant.
          'items': items
              .map(
                (item) => {
                  'offerId': item.menuItemId,
                  'quantity': item.quantity,
                  if (item.specialInstructions != null)
                    'specialInstructions': item.specialInstructions,
                },
              )
              .toList(),
          'deliveryAddress': ?deliveryAddress,
          'deliveryFee': ?deliveryFee,
          'paymentMethod': ?paymentMethod,
          'notes': ?notes,
        },
      );
    } catch (e) {
      throw Exception('Erreur lors de la création de la commande : $e');
    }
  }

  /// Annule une commande du client. Le serveur refuse si le commerçant a
  /// déjà commencé la préparation.
  Future<void> cancelOrder(String orderId) async {
    try {
      await _supabase.functions.invoke(
        'cancel-order-client',
        method: HttpMethod.post,
        body: {'orderId': orderId},
      );
    } catch (e) {
      throw Exception("Impossible d'annuler la commande : $e");
    }
  }

  Future<List<Order>> getOrders(String userId) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = connectivityResult.any(
      (element) => element != ConnectivityResult.none,
    );

    if (!isOnline) {
      final cached = await _db.getCache('orders_$userId');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => Order.fromMap(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    try {
      // L'Edge Function `orders-list` renvoie déjà les commandes enrichies
      // (lignes + noms de plats + établissement) en un seul aller-retour —
      // plus besoin de order_enrichment_helper.dart côté client.
      final response = await _supabase.functions.invoke(
        'get-orders-client',
        method: HttpMethod.get,
        queryParameters: {'pageSize': '50'},
      );
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      final orders = data
          .map((json) => Order.fromMap(json as Map<String, dynamic>))
          .toList();

      final ordersJson = jsonEncode(orders.map((e) => e.toMap()).toList());
      await _db.saveCache('orders_$userId', ordersJson);

      return orders;
    } catch (e) {
      final cached = await _db.getCache('orders_$userId');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => Order.fromMap(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur lors du chargement des commandes : $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _supabase.functions.invoke(
        'update-order-status',
        method: HttpMethod.post,
        body: {'orderId': orderId, 'status': status.name},
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut : $e');
    }
  }
}
