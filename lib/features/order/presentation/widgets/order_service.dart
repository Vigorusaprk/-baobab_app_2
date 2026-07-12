import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/core/database/database_helper.dart';

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
    final totalAmount = items.fold<double>(0, (sum, item) => sum + item.total) + (deliveryFee ?? 0);
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
    final isOnline = connectivityResult.any((element) => element != ConnectivityResult.none);

    if (!isOnline) {
      final cached = await _db.getCache('orders_$userId');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded.map((json) => Order.fromMap(json as Map<String, dynamic>)).toList();
      }
      return [];
    }

    try {
      List<Order> orders;
      try {
        orders = await _getOrdersWithRelatedItems(userId);
      } catch (e) {
        final message = e is PostgrestException ? e.message : e.toString();
        if (message.contains('Could not find a relationship between') ||
            message.contains('relationship between')) {
          orders = await _getOrdersWithoutRelationships(userId);
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
        return decoded.map((json) => Order.fromMap(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Erreur lors du chargement des commandes : $e');
    }
  }

  Future<List<Order>> _getOrdersWithRelatedItems(String userId) async {
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

    final allMenuItemIds = ordersData
        .expand((order) {
          final items = order['items'];
          if (items is List) {
            return items
                .map((item) => item is Map<String, dynamic> ? item['menu_item_id']?.toString() : null)
                .whereType<String>();
          }
          return <String>[];
        })
        .toSet()
        .toList();

    if (allMenuItemIds.isNotEmpty) {
      final menuItems = await _loadMenuItemNames(allMenuItemIds);

      for (final order in ordersData) {
        final items = order['items'];
        if (items is List) {
          for (final item in items) {
            if (item is Map<String, dynamic>) {
              final menuItemId = item['menu_item_id']?.toString();
              if ((item['name'] == null || item['name'] == '') && menuItemId != null) {
                item['name'] = menuItems[menuItemId] ?? item['name'];
              }
            }
          }
        }
      }
    }

    final allBusinessIds = ordersData
        .map((order) => order['business_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    if (allBusinessIds.isNotEmpty) {
      final businesses = await _loadBusinessInfos(allBusinessIds);
      for (final order in ordersData) {
        final businessId = order['business_id']?.toString();
        if (businessId != null && businesses.containsKey(businessId)) {
          final businessInfo = businesses[businessId]!;
          order['establishment_name'] = (order['establishment_name']?.toString().isNotEmpty == true
                  ? order['establishment_name']
                  : businessInfo['name'])
              .toString();
          order['establishment_type'] = order['establishment_type'] ?? businessInfo['type'];
        }
      }
    }

    // Load customer/user info and attach under 'customer'
    final allUserIds = ordersData
        .map((order) => order['user_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    if (allUserIds.isNotEmpty) {
      final users = await _loadUserInfos(allUserIds);
      for (final order in ordersData) {
        final userId = order['user_id']?.toString();
        if (userId != null && users.containsKey(userId)) {
          final userInfo = users[userId]!;
          order['customer'] = userInfo;
        }
      }
    }

    return ordersData.map((json) => Order.fromMap(json)).toList();
  }

  Future<List<Order>> _getOrdersWithoutRelationships(String userId) async {
    final ordersResponse = await _supabase
        .from('orders')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final ordersData = (ordersResponse as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map<String, dynamic>))
        .toList();

    final orderIds = ordersData
        .map((order) => order['id']?.toString())
        .whereType<String>()
        .toList();

    if (orderIds.isEmpty) {
      return ordersData.map((json) => Order.fromMap(json)).toList();
    }

    final itemsResponse = await _supabase
        .from('order_items')
        .select('*')
        .inFilter('order_id', orderIds);

    final orderItems = (itemsResponse as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map<String, dynamic>))
        .toList();

    final allMenuItemIds = orderItems
        .map((item) => item['menu_item_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    final menuItems = <String, String>{};
    if (allMenuItemIds.isNotEmpty) {
      menuItems.addAll(await _loadMenuItemNames(allMenuItemIds));
    }

    final orderItemsByOrderId = <String, List<Map<String, dynamic>>>{};
    for (final item in orderItems) {
      final orderId = item['order_id']?.toString();
      if (orderId == null) continue;
      final menuItemId = item['menu_item_id']?.toString();
      if ((item['name'] == null || item['name'] == '') && menuItemId != null) {
        item['name'] = menuItems[menuItemId] ?? item['name'];
      }
      orderItemsByOrderId.putIfAbsent(orderId, () => []).add(item);
    }

    for (final order in ordersData) {
      final orderId = order['id']?.toString();
      if (orderId != null) {
        order['items'] = orderItemsByOrderId[orderId] ?? [];
      }
    }

    final allBusinessIds = ordersData
        .map((order) => order['business_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    if (allBusinessIds.isNotEmpty) {
      final businesses = await _loadBusinessInfos(allBusinessIds);
      for (final order in ordersData) {
        final businessId = order['business_id']?.toString();
        if (businessId != null && businesses.containsKey(businessId)) {
          final businessInfo = businesses[businessId]!;
          order['establishment_name'] = (order['establishment_name']?.toString().isNotEmpty == true
                  ? order['establishment_name']
                  : businessInfo['name'])
              .toString();
          order['establishment_type'] = order['establishment_type'] ?? businessInfo['type'];
        }
      }
    }

    // Load customer/user info for orders without relationships
    final allUserIds2 = ordersData
        .map((order) => order['user_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    if (allUserIds2.isNotEmpty) {
      final users = await _loadUserInfos(allUserIds2);
      for (final order in ordersData) {
        final userId = order['user_id']?.toString();
        if (userId != null && users.containsKey(userId)) {
          order['customer'] = users[userId]!;
        }
      }
    }

    return ordersData.map((json) => Order.fromMap(json)).toList();
  }

  Future<Map<String, String>> _loadMenuItemNames(List<String> ids) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select('id,name')
          .inFilter('id', ids);

      return (response as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .fold<Map<String, String>>({}, (map, item) {
            final id = item['id']?.toString();
            final name = item['name']?.toString();
            if (id != null && name != null) {
              map[id] = name;
            }
            return map;
          });
    } catch (e) {
      final message = e is PostgrestException ? e.message : e.toString();
      if (message.contains('column menu_items.name does not exist') ||
          message.contains('column "name" does not exist') ||
          message.contains('column menu_items.item_name does not exist') ||
          message.contains('column "item_name" does not exist')) {
        final response = await _supabase
            .from('menu_items')
            .select('id,item_name')
            .inFilter('id', ids);

        return (response as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .fold<Map<String, String>>({}, (map, item) {
              final id = item['id']?.toString();
              final name = item['item_name']?.toString();
              if (id != null && name != null) {
                map[id] = name;
              }
              return map;
            });
      }
      rethrow;
    }
  }

  Future<Map<String, Map<String, String>>> _loadBusinessInfos(List<String> ids) async {
    final response = await _supabase
        .from('business')
        .select('id,name,type')
        .inFilter('id', ids);

    return (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .fold<Map<String, Map<String, String>>>({}, (map, item) {
          final id = item['id']?.toString();
          final name = item['name']?.toString();
          final type = item['type']?.toString();
          if (id != null) {
            map[id] = {
              'name': name ?? '',
              'type': type ?? '',
            };
          }
          return map;
        });
  }

  Future<Map<String, Map<String, String>>> _loadUserInfos(List<String> ids) async {
    final response = await _supabase
        .from('users')
        .select('id,name,email,phone')
        .inFilter('id', ids);

    return (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .fold<Map<String, Map<String, String>>>({}, (map, item) {
          final id = item['id']?.toString();
          final name = item['name']?.toString();
          final email = item['email']?.toString();
          final phone = item['phone']?.toString();
          if (id != null) {
            map[id] = {
              'id': id,
              'name': name ?? '',
              'email': email ?? '',
              'phone': phone ?? '',
            };
          }
          return map;
        });
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
