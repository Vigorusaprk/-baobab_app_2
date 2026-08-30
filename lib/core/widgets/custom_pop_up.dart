import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';

/// La nature de ce qu'on demande de confirmer.
///
/// Elle ne décide pas d'une couleur au cas par cas : elle nomme l'intention,
/// et le thème dit à quoi ressemble cette intention. Un thème sombre
/// redéfinit `error` une fois, toutes les confirmations destructrices
/// suivent.
enum PopUpIntent {
  /// Annuler, supprimer, retirer, refuser, se déconnecter — une action qui
  /// défait quelque chose et que l'utilisateur ne peut pas reprendre seul.
  destructive,

  /// Une confirmation ordinaire : on demande un accord, rien ne se perd.
  neutral,
}

/// La fenêtre de confirmation de l'application.
///
/// Un seul modèle pour toutes les demandes du type « êtes-vous sûr ? ». Avant
/// cette centralisation, chaque écran redessinait la sienne : l'activité
/// posait un bouton texte rouge, la déconnexion un bouton plein rouge, et les
/// deux nommaient leurs libellés à la main. Deux gabarits pour une même
/// question, c'est deux endroits à corriger quand la règle change.
///
/// L'usage courant passe par [showCustomPopUp], qui renvoie `true` seulement
/// si l'utilisateur a confirmé — fermer d'un geste ou d'un retour arrière
/// vaut « non ».
///
/// La précision est portée par la question ; les boutons, eux, se contentent
/// de « Retour » et « Confirmer » et tiennent sur une seule ligne.
///
/// ```dart
/// final confirme = await showCustomPopUp(
///   context: context,
///   title: 'Voulez-vous vraiment annuler votre commande ?',
///   message: 'Votre commande chez Chez Nadine sera annulée. '
///       'Vous pourrez en passer une nouvelle quand vous voulez.',
/// );
/// if (!confirme) return;
/// ```
class CustomPopUp extends StatelessWidget {
  const CustomPopUp({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirmer',
    this.cancelLabel = 'Retour',
    this.intent = PopUpIntent.destructive,
    this.icon,
  });

  /// La question posée à l'utilisateur, en toutes lettres : « Voulez-vous
  /// vraiment annuler votre commande ? ». C'est le titre qui est précis,
  /// pas les boutons.
  final String title;

  /// Ce que la confirmation va provoquer, et ce qui reste possible ensuite.
  /// C'est ici que se dit la conséquence — pas dans le titre.
  final String message;

  /// Le libellé du bouton qui agit.
  ///
  /// Il reste court : la question, elle, est déjà dans le titre. Nommer
  /// l'action ici produisait « Annuler la commande » face à « Annuler » —
  /// deux boutons portant le même mot pour des sens opposés, et un libellé
  /// assez long pour renvoyer les boutons à la ligne.
  final String confirmLabel;

  /// Le libellé du bouton qui renonce.
  ///
  /// « Retour » plutôt que « Annuler » : quand l'action confirmée *est* une
  /// annulation, « Annuler » ne veut plus rien dire.
  final String cancelLabel;

  final PopUpIntent intent;

  /// Pictogramme facultatif, affiché au-dessus du titre.
  final IconData? icon;

  bool get _isDestructive => intent == PopUpIntent.destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Le rôle `error` porte déjà le sens « attention, ceci défait quelque
    // chose ». Une confirmation ordinaire prend la couleur d'action normale.
    final actionColor = _isDestructive ? scheme.error : scheme.primary;
    final onActionColor = _isDestructive ? scheme.onError : scheme.onPrimary;

    return AlertDialog(
      // Le reste de l'habillage — fond, style du titre, style du corps —
      // vient de `dialogTheme` dans app_theme.dart.
      icon: icon == null ? null : Icon(icon, color: actionColor),
      title: Text(title),
      // La zone de contenu d'`AlertDialog` ne défile pas : un message long,
      // ou un facteur d'agrandissement du texte élevé, en coupait la fin
      // sans rien laisser paraître. La conséquence de l'action est
      // précisément ce qu'il ne faut pas tronquer.
      content: SingleChildScrollView(
        child: Text(message, style: Theme.of(context).textTheme.bodySmall),
      ),
      // Les deux boutons tiennent sur une seule ligne, à parts égales.
      //
      // `actions` passe normalement par un `OverflowBar`, qui empile les
      // boutons dès qu'ils ne tiennent plus côte à côte — c'est ce qui
      // renvoyait « Annuler la commande » sous « Annuler ». On lui donne donc
      // une ligne déjà composée : la décision se lit d'un seul regard,
      // gauche contre droite, quelle que soit la longueur des libellés.
      //
      // La marge est reprise à la main pour que la ligne de boutons s'aligne
      // exactement sur le bloc de texte au-dessus : `OverflowBar` ajoute
      // sinon son propre retrait et la ligne paraît flotter.
      actionsPadding: const EdgeInsets.fromLTRB(
        AppDimens.large,
        AppDimens.small,
        AppDimens.large,
        AppDimens.large,
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimens.medium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                    ),
                  ),
                  child: Text(
                    cancelLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.small),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: actionColor,
                    foregroundColor: onActionColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimens.small,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.borderRadiusSmallButton,
                      ),
                    ),
                  ),
                  child: Text(
                    confirmLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pose la question et attend la réponse.
///
/// Renvoie `true` uniquement si l'utilisateur a appuyé sur le bouton d'action.
/// Tout le reste — le bouton d'annulation, le geste vers l'extérieur, le
/// retour arrière du système — renvoie `false`. Le point compte : un `null`
/// remonté tel quel se lit comme « faux » dans un `if`, mais se lit comme
/// « vrai » dans un `!= false`. On tranche ici, une fois.
Future<bool> showCustomPopUp({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirmer',
  String cancelLabel = 'Retour',
  PopUpIntent intent = PopUpIntent.destructive,
  IconData? icon,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => CustomPopUp(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      intent: intent,
      icon: icon,
    ),
  );
  return confirmed ?? false;
}
