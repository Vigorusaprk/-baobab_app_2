import 'dart:convert';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static const String _ordersKey = 'user_orders';

  static Future<void> saveOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> orders = prefs.getStringList(_ordersKey) ?? [];
    orders.add(json.encode(order.toMap()));
    await prefs.setStringList(_ordersKey, orders);
  }

  static Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ordersData = prefs.getStringList(_ordersKey) ?? [];
    return ordersData.map((data) {
      final map = json.decode(data);
      return Order.fromMap(Map<String, dynamic>.from(map));
    }).toList();
  }

  static Future<void> deleteOrder(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> orders = prefs.getStringList(_ordersKey) ?? [];
    orders.removeWhere((data) {
      final map = json.decode(data);
      return map['id'] == id;
    });
    await prefs.setStringList(_ordersKey, orders);
  }

  static Future<void> updateOrderStatus(String id, OrderStatus newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> orders = prefs.getStringList(_ordersKey) ?? [];
    final index = orders.indexWhere((data) {
      final map = json.decode(data);
      return map['id'] == id;
    });
    if (index != -1) {
      final map = json.decode(orders[index]);
      map['status'] = newStatus.index;
      orders[index] = json.encode(map);
      await prefs.setStringList(_ordersKey, orders);
    }
  }
}