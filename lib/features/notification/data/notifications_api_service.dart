import 'package:baobabe_0_2/features/notification/domain/entities/app_notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Le fil de notifications, servi par `get-notifications`, marqué lu par
/// `update-notification`.
///
/// Aucun `.from('notifications')` direct : c'est la règle du projet, et ici
/// elle a une raison de plus — le compte de non-lues et la page viennent du
/// même appel, donc de la même lecture. Deux appels finiraient par se
/// contredire d'un rafraîchissement à l'autre.
class NotificationsApiService {
  NotificationsApiService({SupabaseClient? supabase}) : _override = supabase;

  final SupabaseClient? _override;

  /// Résolu à l'usage : un double de test qui redéfinit les méthodes n'a pas
  /// besoin d'un Supabase initialisé pour exister.
  SupabaseClient get _supabase => _override ?? Supabase.instance.client;

  Future<NotificationPage> getPage({
    int page = 1,
    bool unreadOnly = false,
  }) async {
    final response = await _supabase.functions.invoke(
      'get-notifications',
      method: HttpMethod.get,
      queryParameters: {'page': '$page', if (unreadOnly) 'unreadOnly': 'true'},
    );

    final data = response.data;
    if (data is! Map) throw const NotificationException('Fil illisible');
    final json = Map<String, dynamic>.from(data);
    final error = json['error'];
    if (error != null) throw NotificationException(error.toString());

    final listed = json['notifications'];
    final rows = listed is Map
        ? (listed['data'] as List?) ?? const []
        : const [];

    return NotificationPage(
      items: rows
          .map(
            (e) =>
                AppNotification.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      hasMore: listed is Map && listed['hasMore'] == true,
      unread: (json['unread'] as num?)?.toInt() ?? 0,
    );
  }

  /// Marque une notification comme lue, ou toutes. Renvoie le nombre de
  /// non-lues qui restent, pour que la pastille se repeigne sans relire la
  /// liste entière.
  Future<int> markRead({String? id, bool all = false}) async {
    final response = await _supabase.functions.invoke(
      'update-notification',
      body: {'id': ?id, if (all) 'all': true},
    );

    final data = response.data;
    if (data is! Map) return 0;
    final json = Map<String, dynamic>.from(data);
    final error = json['error'];
    if (error != null) throw NotificationException(error.toString());
    final payload = json['data'];
    return payload is Map ? ((payload['unread'] as num?)?.toInt() ?? 0) : 0;
  }
}

/// Erreur déjà rédigée pour l'utilisateur.
class NotificationException implements Exception {
  const NotificationException(this.message);

  final String message;

  @override
  String toString() => message;
}
