import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/feed_item.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/feed_repository.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';

/// Notifications construites à partir de l'activité réelle de
/// l'utilisateur : ses commandes et ses réservations.
///
/// Remplace l'implémentation de démonstration, qui affichait des messages
/// inventés à propos de commerces inexistants et proposait une action vers
/// une route morte. Aucune table dédiée n'a été créée : ce que l'utilisateur
/// veut savoir — où en sont ses commandes et ses réservations — est déjà en
/// base, il suffisait de le lui présenter.
class ActivityFeedRepository implements FeedRepository {
  final OrderApiService _orders;
  final ReservationApiService _reservations;

  /// Identifiants marqués comme lus pendant la session. Aucune table de
  /// suivi n'existe côté serveur : on ne prétend donc pas persister l'état
  /// au-delà de la session en cours.
  final Set<String> _read = <String>{};

  ActivityFeedRepository({
    OrderApiService? orders,
    ReservationApiService? reservations,
  }) : _orders = orders ?? OrderApiService(),
       _reservations = reservations ?? ReservationApiService();

  @override
  Future<List<FeedItem>> getFeedItems() async {
    final user = SessionService.instance.currentUser;
    // Un visiteur sans compte n'a par définition aucune activité ; on
    // renvoie une liste vide plutôt que d'inventer du contenu.
    if (user == null) return const [];

    final results = await Future.wait([
      _orders.getOrders(user.id).catchError((_) => <Order>[]),
      _reservations
          .getReservations(userId: user.id)
          .catchError((_) => <Reservation>[]),
    ]);

    final items = <FeedItem>[
      ...(results[0] as List<Order>).map(_fromOrder),
      ...(results[1] as List<Reservation>).map(_fromReservation),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return items
        .map((i) => _read.contains(i.id) ? i.copyWith(isRead: true) : i)
        .toList();
  }

  FeedItem _fromOrder(Order order) {
    return FeedItem(
      id: 'order_${order.id}',
      type: FeedItemType.notification,
      title: 'Commande ${order.status.displayName.toLowerCase()}',
      message:
          '${order.establishmentName} — ${order.totalAmount.toStringAsFixed(2)} \$',
      createdAt: order.orderDate,
      isRead: _read.contains('order_${order.id}'),
      actionLabel: 'Voir la commande',
      actionRoute: '/orders',
    );
  }

  FeedItem _fromReservation(Reservation reservation) {
    final date = reservation.reservationDate;
    final upcoming = date.isAfter(DateTime.now());
    return FeedItem(
      id: 'reservation_${reservation.id}',
      type: FeedItemType.notification,
      title: upcoming ? 'Réservation à venir' : 'Réservation passée',
      message: '${reservation.establishmentName} — '
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/${date.year}',
      createdAt: date,
      isRead: _read.contains('reservation_${reservation.id}'),
      actionLabel: 'Voir la réservation',
      actionRoute: '/orders',
    );
  }

  @override
  Future<void> markAsRead(String itemId) async {
    _read.add(itemId);
  }
}
