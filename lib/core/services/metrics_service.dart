import 'package:baobabe_0_2/core/constants/supabase_client.dart';
import 'package:flutter/foundation.dart';

/// Ce que les fiches font : combien de fois on les ouvre, et combien de fois
/// on clique depuis une mise en avant.
///
/// Sans ces deux nombres, une campagne publicitaire n'a aucun résultat à
/// montrer et le tableau de bord d'un commerçant ne parle que de commandes —
/// or on ouvre une fiche cent fois pour une commande.
///
/// **Rien n'est attendu.** Une mesure est un accessoire : elle ne doit ni
/// retarder l'affichage d'une fiche, ni la faire échouer. L'appel part et
/// l'écran continue.
///
/// Compté aussi pour un visiteur anonyme — c'est la moitié du trafic d'une
/// application qu'on peut consulter sans compte.
class MetricsService {
  const MetricsService._();

  static const MetricsService instance = MetricsService._();

  /// Une fiche ouverte. [offerId] nul : c'est la fiche du commerce.
  void view({required String businessId, String? offerId}) =>
      _send(businessId: businessId, offerId: offerId, kind: 'view');

  /// Un clic depuis une mise en avant : c'est ce qui distingue une campagne
  /// vue d'une campagne qui a servi.
  void click({required String businessId, String? offerId}) =>
      _send(businessId: businessId, offerId: offerId, kind: 'click');

  void _send({
    required String businessId,
    required String? offerId,
    required String kind,
  }) {
    if (businessId.isEmpty) return;
    final client = SupabaseClientWrapper.clientOrNull;
    if (client == null) return;

    // Part et n'est pas attendu. `onError` est indispensable : sans lui,
    // une panne de réseau remonterait en exception non capturée dans la
    // zone de l'application.
    client.functions
        .invoke(
          'create-metric',
          body: {'businessId': businessId, 'offerId': offerId, 'kind': kind},
        )
        .then(
          (_) {},
          onError: (Object error) =>
              debugPrint('Mesure non enregistrée : $error'),
        );
  }
}
