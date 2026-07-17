import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';

/// Fonctions d'enrichissement des commandes chargées depuis Supabase :
/// association des noms d'articles, des informations d'établissement et
/// des informations client lorsqu'elles ne sont pas fournies directement
/// via une relation Supabase.

Future<List<Order>> getOrdersWithRelatedItems(SupabaseClient supabase, String userId) async {
  final response = await supabase
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
    final menuItems = await loadMenuItemNames(supabase, allMenuItemIds);

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
    final businesses = await loadBusinessInfos(supabase, allBusinessIds);
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
    final users = await loadUserInfos(supabase, allUserIds);
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

Future<List<Order>> getOrdersWithoutRelationships(SupabaseClient supabase, String userId) async {
  final ordersResponse = await supabase
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

  final itemsResponse = await supabase
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
    menuItems.addAll(await loadMenuItemNames(supabase, allMenuItemIds));
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
    final businesses = await loadBusinessInfos(supabase, allBusinessIds);
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
    final users = await loadUserInfos(supabase, allUserIds2);
    for (final order in ordersData) {
      final userId = order['user_id']?.toString();
      if (userId != null && users.containsKey(userId)) {
        order['customer'] = users[userId]!;
      }
    }
  }

  return ordersData.map((json) => Order.fromMap(json)).toList();
}

Future<Map<String, String>> loadMenuItemNames(SupabaseClient supabase, List<String> ids) async {
  try {
    final response = await supabase
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
      final response = await supabase
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

Future<Map<String, Map<String, String>>> loadBusinessInfos(SupabaseClient supabase, List<String> ids) async {
  final response = await supabase
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

Future<Map<String, Map<String, String>>> loadUserInfos(SupabaseClient supabase, List<String> ids) async {
  final response = await supabase
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
