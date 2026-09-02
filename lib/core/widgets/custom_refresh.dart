import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';

/// Le geste « tirer pour rafraîchir », partout pareil.
///
/// Cinq écrans en avaient un `RefreshIndicator` écrit à la main, chacun avec
/// ses couleurs par défaut ; les dix autres n'en avaient aucun. Or c'est le
/// seul recours quand une donnée est en retard — une commande acceptée, un
/// commerce qui vient d'ouvrir — et une application où le geste marche sur
/// une page et pas sur la suivante apprend à ne pas l'essayer.
///
/// Le contenu doit être **défilable**, et défilable jusqu'en haut : un
/// `ListView`, un `CustomScrollView`, ou un `SingleChildScrollView` en
/// `AlwaysScrollableScrollPhysics` — sinon le geste n'atteint jamais le seuil
/// de déclenchement sur une page courte.
class CustomRefresh extends StatelessWidget {
  const CustomRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  /// Rappelé au geste. La roue tourne jusqu'à ce que ce futur s'achève : lui
  /// rendre la main tout de suite ferait clignoter l'indicateur sans rien
  /// dire de l'état réel.
  final Future<void> Function() onRefresh;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: scheme.primary,
      backgroundColor: scheme.surfaceContainerLowest,
      // La bande de l'accueil et les app bars mangent le haut de l'écran :
      // sans ce décalage, la roue apparaît sous elles.
      edgeOffset: AppDimens.small,
      child: child,
    );
  }
}

/// Attend qu'un bloc ait fini de recharger.
///
/// `RefreshIndicator` fait tourner sa roue jusqu'à ce que le futur qu'on lui
/// donne s'achève. Or la plupart des rechargements de l'application passent
/// par un événement de bloc, qui ne rend rien : sans cette attente, la roue
/// disparaîtrait avant que les données arrivent, et le geste n'apprendrait
/// rien à personne.
///
/// [settled] reconnaît un état d'arrivée — chargé **ou** en erreur. Une
/// erreur est une fin : continuer à tourner ferait croire à un espoir.
///
/// Le délai de garde existe pour le cas où le bloc n'émet jamais rien : la
/// roue doit s'arrêter de toute façon, sinon la page semble bloquée.
Future<void> awaitSettled<S>(
  Stream<S> states,
  bool Function(S state) settled, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  try {
    await states.firstWhere(settled).timeout(timeout);
  } catch (_) {
    // Rien à signaler : l'écran montre déjà son propre état.
  }
}
