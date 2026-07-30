import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/core/database/database_helper.dart';
import 'package:baobabe_0_2/features/order/data/services/order_enrichment_helper.dart';

class OrderApiService {
  final SupabaseClient _supabase;
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Connectivity _connectivity = Connectivity();

  OrderApiService([SupabaseClient? supabase])
    : _supabase = supabase ?? Supabase.instance.client;

  Future<void> createOrder({
    required String userId,
    required String businessId,
    required List<OrderItem> items,
    String? deliveryAddress,
    double? deliveryFee,
    String? paymentMethod,
    String? notes,
  }) async {
    final totalAmount =
        items.fold<double>(0, (sum, item) => sum + item.total) +
        (deliveryFee ?? 0);
    final payload = {
      'user_id': userId,
      'business_id': businessId,
      'status': 'pending',
      'total_amount': totalAmount,
      // Some DB schemas use `total_price` instead of `total_amount`.
      // Include both keys to be compatible with either schema.
      'total_price': totalAmount,
    };

    if (deliveryAddress != null) {
      payload['delivery_address'] = deliveryAddress;
    }
    if (deliveryFee != null) {
      payload['delivery_fee'] = deliveryFee;
    }
    if (paymentMethod != null) {
      payload['payment_method'] = paymentMethod;
    }
    if (notes != null) {
      payload['notes'] = notes;
    }
    try {
      final orderResponse = await _supabase
          .from('orders')
          .insert(payload)
          .select()
          .single();

      final orderId = orderResponse['id']?.toString();
      if (orderId == null || orderId.isEmpty) {
        throw Exception('Impossible de créer la commande');
      }

      final orderItems = items.map((item) {
        final map = {
          'order_id': orderId,
          'menu_item_id': item.menuItemId,
          'quantity': item.quantity,
          'unit_price': item.price,
        };
        if (item.specialInstructions != null) {
          map['special_instructions'] = item.specialInstructions!;
        }
        return map;
      }).toList();

      if (orderItems.isNotEmpty) {
        await _insertOrderItems(orderItems);
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la commande : $e');
    }
  }

  Future<void> _insertOrderItems(List<Map<String, dynamic>> orderItems) async {
    try {
      await _supabase.from('order_items').insert(orderItems);
    } catch (e) {
      final message = e is PostgrestException ? e.message : e.toString();

      if (message.contains("Could not find the 'unit_price' column") ||
          message.contains('column "unit_price" does not exist')) {
        final fallbackItems = orderItems.map((item) {
          final map = Map<String, dynamic>.from(item);
          map['price'] = map.remove('unit_price');
          return map;
        }).toList();
        await _supabase.from('order_items').insert(fallbackItems);
        return;
      }

      if (message.contains("Could not find the 'price' column") ||
          message.contains('column "price" does not exist')) {
        final fallbackItems = orderItems.map((item) {
          final map = Map<String, dynamic>.from(item);
          map['unit_price'] = map.remove('price');
          return map;
        }).toList();
        await _supabase.from('order_items').insert(fallbackItems);
        return;
      }

      rethrow;
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
      List<Order> orders;
      try {
        orders = await getOrdersWithRelatedItems(_supabase, userId);
      } catch (e) {
        final message = e is PostgrestException ? e.message : e.toString();
        if (message.contains('Could not find a relationship between') ||
            message.contains('relationship between')) {
          orders = await getOrdersWithoutRelationships(_supabase, userId);
        } else {
          rethrow;
        }
      }

      // Sauvegarder dans le cache
      final ordersJson = jsonEncode(orders.map((e) => e.toMap()).toList());
      await _db.saveCache('orders_$userId', ordersJson);

      return orders;
    } catch (e) {
      // Fallback au cache en cas d'erreur API
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
      await _supabase
          .from('orders')
          .update({'status': status.name})
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut : $e');
    }
  }
}
