import 'package:dio/dio.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';

class OrderApiService {
  final Dio _dio;
  final String _baseUrl;

  OrderApiService({Dio? dio, String baseUrl = 'http://10.0.2.2:3000/api'})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl;

  Future<void> createOrder({
    required String userId,
    required String businessId,
    required List<OrderItem> items,
    String? deliveryAddress,
    double? deliveryFee,
    String? paymentMethod,
    String? notes,
  }) async {
    final payload = {
      'user_id': userId,
      'business_id': businessId,
      'items': items.map((item) => {
        'menu_item_id': item.menuItemId,
        'quantity': item.quantity,
        'special_instructions': item.specialInstructions,
      }).toList(),
      'delivery_address': deliveryAddress,
      'delivery_fee': deliveryFee,
      'payment_method': paymentMethod,
      'notes': notes,
    };
    try {
      await _dio.post('$_baseUrl/orders', data: payload);
    } catch (e) {
      throw Exception('Erreur lors de la création de la commande : $e');
    }
  }

  Future<List<Order>> getOrders(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/orders', queryParameters: {'user_id': userId});
      final List data = response.data;
      return data.map((json) => Order.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des commandes : $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _dio.patch('$_baseUrl/orders/$orderId', data: {'status': status.name});
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut : $e');
    }
  }
}