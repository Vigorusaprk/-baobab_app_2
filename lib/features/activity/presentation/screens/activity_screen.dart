import 'package:baobabe_0_2/core/animation/fade_swap.dart';
import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';
import 'package:baobabe_0_2/features/activity/domain/activity_entry.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/activity_empty.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/activity_flow.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/activity_skeleton.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// L'onglet « Activités ».
///
/// **Un seul flux, chronologique.** Il y avait deux onglets — « Commandes »
/// et « Réservations » — qui obligeaient à savoir, avant de chercher, dans
/// lequel des deux ranger ce qu'on cherche. Or on ne se souvient pas d'une
/// catégorie : on se souvient d'un commerce et d'un moment. La nature de la
/// demande est devenue une mention dans la ligne.
///
/// Toucher une ligne ouvre son reçu **en page entière**, hors du shell : un
/// détail n'est pas un onglet, et la barre de navigation n'a rien à proposer
/// pendant qu'on regarde un code à présenter au comptoir. La page rend
/// `true` quand elle a changé quelque chose, et c'est la seule chose qui
/// déclenche un rechargement.
///
/// Le Scaffold appartient à `MainShell`, seul Scaffold de la navigation
/// principale.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _orderApi = OrderApiService();
  final _resApi = ReservationApiService();

  List<ActivityEntry> _entries = [];
  bool _loading = true;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final user = SessionService.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    _userId = user.id;
    await _load();
  }

  Future<void> _load() async {
    if (_userId.isEmpty) return;
    if (mounted) setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _orderApi.getOrders(_userId),
        _resApi.getReservations(userId: _userId),
      ]);
      if (!mounted) return;
      final orders = results[0] as List<Order>;
      final reservations = results[1] as List<Reservation>;
      setState(() {
        _entries = [
          for (final order in orders) ActivityEntry.fromOrder(order),
          for (final r in reservations) ActivityEntry.fromReservation(r),
        ];
      });
    } catch (e) {
      debugPrint('Activités — chargement impossible : $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  /// Ouvre le reçu et ne recharge que s'il a changé quelque chose.
  Future<void> _open(ActivityEntry entry) async {
    final changed = await context.push<bool>('/activity', extra: entry);
    if (changed == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        // `stretch` : sans cela la colonne donne à l'en-tête sa largeur
        // intrinsèque et le centre, alors que tout l'écran est aligné à
        // gauche.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ActivityHeader(entries: _entries, loading: _loading),
          Expanded(
            child: FadeSwap(
              child: _loading
                  ? const ActivityFlowSkeleton(key: ValueKey('squelette'))
                  : _entries.isEmpty
                  ? CustomRefresh(
                      key: const ValueKey('vide'),
                      onRefresh: _load,
                      // `ListView` et non `Center` : le geste de
                      // rafraîchissement a besoin d'un défilement pour
                      // atteindre son seuil, même sur une page vide.
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.55,
                            child: const ActivityEmpty(),
                          ),
                        ],
                      ),
                    )
                  : CustomRefresh(
                      key: const ValueKey('flux'),
                      onRefresh: _load,
                      child: ActivityFlow(entries: _entries, onOpen: _open),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
