import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';

class OrderApiService {
  final SupabaseClient _supabase;

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
    final totalAmount = items.fold<double>(0, (sum, item) => sum + item.total) + (deliveryFee ?? 0);
    final payload = {
      'user_id': userId,
      'business_id': businessId,
      'status': 'pending',
      'total_amount': totalAmount,
      'delivery_address': deliveryAddress,
      'delivery_fee': deliveryFee,
      'payment_method': paymentMethod,
      'notes': notes,
    };
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

      final orderItems = items.map((item) => {
        'order_id': orderId,
        'menu_item_id': item.menuItemId,
        'quantity': item.quantity,
        'unit_price': item.price,
        'special_instructions': item.specialInstructions,
      }).toList();

      if (orderItems.isNotEmpty) {
        await _supabase.from('order_items').insert(orderItems);
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la commande : $e');
    }
  }

  Future<List<Order>> getOrders(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final ordersData = (response as List<dynamic>)
          .map((item) {
            final map = Map<String, dynamic>.from(item as Map<String, dynamic>);
            if (map.containsKey('order_items')) {
              map['items'] = map['order_items'];
            }
            return map;
          })
          .toList();

      return ordersData.map((json) => Order.fromMap(json)).toList();
    } catch (e) {
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
