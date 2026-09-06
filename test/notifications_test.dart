import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/notification/data/notifications_api_service.dart';
import 'package:baobabe_0_2/features/notification/domain/entities/app_notification.dart';
import 'package:baobabe_0_2/features/notification/presentation/cubit/notifications_cubit.dart';
import 'package:baobabe_0_2/features/notification/presentation/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Les notifications, du serveur à l'écran.
///
/// Ce que ces tests tiennent :
///
/// - une notification d'un genre **inconnu** s'affiche quand même : une
///   version publiée avant l'ajout d'un genre ne doit pas rendre le fil
///   illisible ;
/// - l'état « lu » bascule **tout de suite** — l'utilisateur vient de la
///   toucher, il n'attend pas le réseau — mais le serveur reste seul juge du
///   compte de non-lues ;
/// - un visiteur sans compte lit une invitation à se connecter, pas un vide
///   qui ressemble à une panne.

Map<String, dynamic> _row({
  String id = 'n1',
  String kind = 'order_status',
  String title = 'Commande acceptée',
  String body = 'Kin Snacks a accepté votre commande.',
  String? route = '/orders',
  String? readAt,
  String createdAt = '2026-09-06T10:00:00+00:00',
}) => {
  'id': id,
  'kind': kind,
  'title': title,
  'body': body,
  'route': route,
  'subject_type': 'order',
  'subject_id': 'o1',
  'payload': {'status': 'confirmed'},
  'read_at': readAt,
  'created_at': createdAt,
};

/// Un service qui ne parle à personne, et qui compte ce qu'on lui demande.
class _FakeService extends NotificationsApiService {
  _FakeService({List<NotificationPage>? pages, this.failMarkRead = false})
    : pages = pages ?? const [];

  final List<NotificationPage> pages;
  final bool failMarkRead;

  int reads = 0;
  int marks = 0;
  String? lastMarkedId;
  bool lastMarkedAll = false;

  @override
  Future<NotificationPage> getPage({int page = 1, bool unreadOnly = false}) async {
    reads++;
    final index = page - 1;
    return index < pages.length ? pages[index] : const NotificationPage();
  }

  @override
  Future<int> markRead({String? id, bool all = false}) async {
    marks++;
    lastMarkedId = id;
    lastMarkedAll = all;
    if (failMarkRead) throw const NotificationException('Injoignable');
    return 0;
  }
}

/// Le cubit croit la session ouverte : `SessionService` n'existe pas hors de
/// l'application, et un cubit qui se croit toujours visiteur ne montre rien.
class _SignedInCubit extends NotificationsCubit {
  _SignedInCubit(NotificationsApiService service) : super(service: service);

  @override
  bool get isSignedIn => true;
}

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  group('La lecture du serveur', () {
    test('un genre inconnu ne fait pas tomber le fil', () {
      final notification = AppNotification.fromJson(
        _row(kind: 'quelque_chose_de_neuf'),
      );

      expect(notification.kind, NotificationKind.other);
      expect(notification.title, 'Commande acceptée');
      // Rien à proposer pour un genre qu'on ne connaît pas : un bouton qui
      // n'ouvre rien vaut moins que pas de bouton.
      expect(notification.kind.actionLabel, isNull);
    });

    test('l\'instant passe à l\'heure de l\'appareil', () {
      final notification = AppNotification.fromJson(
        _row(createdAt: '2026-09-06T10:00:00+00:00'),
      );

      expect(notification.createdAt.isUtc, isFalse);
      expect(notification.createdAt, DateTime.utc(2026, 9, 6, 10).toLocal());
    });

    test('« lu » se lit, et se déduit', () {
      expect(AppNotification.fromJson(_row()).isRead, isFalse);
      expect(
        AppNotification.fromJson(
          _row(readAt: '2026-09-06T11:00:00+00:00'),
        ).isRead,
        isTrue,
      );
    });

    test('une route vide vaut pas de route', () {
      expect(AppNotification.fromJson(_row(route: '')).route, isNull);
    });
  });

  group('La carte', () {
    Future<void> pump(WidgetTester tester, AppNotification notification) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.silvaTheme,
          home: Scaffold(
            body: NotificationTile(
              notification: notification,
              onTap: () {},
            ),
          ),
        ),
      );
    }

    testWidgets('une non-lue annonce ce qu\'elle ouvre', (tester) async {
      await pump(tester, AppNotification.fromJson(_row()));

      expect(find.text('Commande acceptée'), findsOneWidget);
      expect(find.text('Voir la commande'), findsOneWidget);
    });

    testWidgets('sans route, aucune action n\'est promise', (tester) async {
      await pump(tester, AppNotification.fromJson(_row(route: null)));

      expect(find.text('Voir la commande'), findsNothing);
    });

    testWidgets('le non-lu se voit au gras, pas à la seule couleur', (
      tester,
    ) async {
      await pump(tester, AppNotification.fromJson(_row()));
      final unread = tester.widget<Text>(find.text('Commande acceptée'));

      await pump(
        tester,
        AppNotification.fromJson(_row(readAt: '2026-09-06T11:00:00+00:00')),
      );
      final read = tester.widget<Text>(find.text('Commande acceptée'));

      expect(unread.style?.fontWeight, FontWeight.w700);
      expect(read.style?.fontWeight, FontWeight.w500);
    });
  });

  group('Le fil', () {
    NotificationPage page(
      List<Map<String, dynamic>> rows, {
      bool hasMore = false,
      int unread = 0,
    }) => NotificationPage(
      items: rows.map(AppNotification.fromJson).toList(),
      hasMore: hasMore,
      unread: unread,
    );

    test('un visiteur sans compte ne fait aucun appel', () async {
      final service = _FakeService();
      // Pas de session : `isSignedIn` retombe sur `SessionService`, qui
      // n'existe pas ici et répond faux.
      final cubit = NotificationsCubit(service: service);

      await cubit.load();

      expect(cubit.state.isGuest, isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(service.reads, 0);
      await cubit.close();
    });

    test('la première page arrive avec son compte de non-lues', () async {
      final cubit = _SignedInCubit(
        _FakeService(pages: [page([_row(), _row(id: 'n2')], unread: 2)]),
      );

      await cubit.load();

      expect(cubit.state.items.length, 2);
      expect(cubit.state.unread, 2);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isGuest, isFalse);
      await cubit.close();
    });

    test('marquer comme lu bascule sans attendre le réseau', () async {
      final service = _FakeService(
        pages: [page([_row()], unread: 1)],
      );
      final cubit = _SignedInCubit(service);
      await cubit.load();

      await cubit.markRead(cubit.state.items.first);

      expect(cubit.state.items.first.isRead, isTrue);
      expect(cubit.state.unread, 0);
      expect(service.lastMarkedId, 'n1');
      await cubit.close();
    });

    test('une notification déjà lue ne se remarque pas', () async {
      final service = _FakeService(
        pages: [page([_row(readAt: '2026-09-06T11:00:00+00:00')])],
      );
      final cubit = _SignedInCubit(service);
      await cubit.load();

      await cubit.markRead(cubit.state.items.first);

      expect(service.marks, 0);
      await cubit.close();
    });

    test('un refus du serveur fait relire plutôt que mentir', () async {
      final service = _FakeService(
        pages: [page([_row()], unread: 1)],
        failMarkRead: true,
      );
      final cubit = _SignedInCubit(service);
      await cubit.load();
      expect(service.reads, 1);

      await cubit.markRead(cubit.state.items.first);

      // Le serveur n'a pas accepté : on ne garde pas un état local qu'il
      // ignore, on relit.
      expect(service.reads, 2);
      expect(cubit.state.unread, 1);
      await cubit.close();
    });

    test("la page suivante s'ajoute à la liste", () async {
      final cubit = _SignedInCubit(
        _FakeService(
          pages: [
            page([_row()], hasMore: true, unread: 2),
            page([_row(id: 'n2')], unread: 2),
          ],
        ),
      );
      await cubit.load();

      await cubit.loadMore();

      expect(cubit.state.items.map((i) => i.id), ['n1', 'n2']);
      expect(cubit.state.hasMore, isFalse);
      await cubit.close();
    });

    test('sans page suivante, on ne demande rien', () async {
      final service = _FakeService(pages: [page([_row()])]);
      final cubit = _SignedInCubit(service);
      await cubit.load();

      await cubit.loadMore();

      expect(service.reads, 1);
      await cubit.close();
    });

    test('tout lire remet la pastille à zéro', () async {
      final service = _FakeService(
        pages: [page([_row(), _row(id: 'n2')], unread: 2)],
      );
      final cubit = _SignedInCubit(service);
      await cubit.load();

      await cubit.markAllRead();

      expect(cubit.state.unread, 0);
      expect(cubit.state.items.every((i) => i.isRead), isTrue);
      expect(service.lastMarkedAll, isTrue);
      await cubit.close();
    });
  });
}
