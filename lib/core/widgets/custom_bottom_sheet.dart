import 'dart:math' as math;
import 'dart:ui';

import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:flutter/material.dart';

/// Ce que porte l'en-tête d'une feuille : un titre, et de quoi revenir.
class SheetHeader {
  const SheetHeader({this.title, this.onBack});

  final String? title;

  /// `null` : pas de retour possible, la flèche disparaît.
  final VoidCallback? onBack;
}

/// L'en-tête d'une feuille, **modifiable depuis son contenu**.
///
/// Un parcours en plusieurs étapes — saisir son e-mail, puis le code reçu,
/// puis la confirmation — change de titre à chaque écran, et le retour
/// n'apparaît qu'à partir du deuxième. Sans ce pilote, chaque étape devrait
/// redessiner sa propre barre, ce qui est exactement ce qu'on cherche à
/// éviter.
///
/// ```dart
/// SheetHeaderScope.of(context)?.value = const SheetHeader(
///   title: 'Code de confirmation',
///   onBack: _retourEmail,
/// );
/// ```
///
/// À appeler hors d'un `build` — depuis `initState` différé, un
/// gestionnaire d'événement ou un `listener` — puisque cela reconstruit
/// l'en-tête.
class SheetHeaderController extends ValueNotifier<SheetHeader> {
  SheetHeaderController(super.value);
}

/// Donne accès au [SheetHeaderController] de la feuille englobante.
class SheetHeaderScope extends InheritedNotifier<SheetHeaderController> {
  const SheetHeaderScope({
    super.key,
    required SheetHeaderController super.notifier,
    required super.child,
  });

  /// `null` hors d'une feuille : un contenu réutilisé dans une page pleine
  /// n'a pas d'en-tête à piloter, et ce n'est pas une erreur.
  static SheetHeaderController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SheetHeaderScope>()?.notifier;
}

/// La feuille modale de l'application.
///
/// Tout ce qui monte du bas passe par elle : filtres, profil, commande,
/// connexion. Un écran qui rebâtirait son propre `showModalBottomSheet`
/// n'aurait ni le flou, ni la poignée, ni le bouton de fermeture, ni le
/// comportement au clavier — c'était le cas de trois écrans.
///
/// [title] et [onBack] composent l'en-tête : le retour à gauche, la poignée
/// au centre, la fermeture à droite. Un parcours en plusieurs étapes (saisie
/// de l'e-mail puis du code, par exemple) n'a donc pas à redessiner sa barre.
Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  Color? color,
  double? minHeight,
  String? title,

  /// Affiché à gauche de la poignée. `null` : pas de retour possible.
  VoidCallback? onBack,

  /// La croix de fermeture. On ne la retire que pour une feuille dont la
  /// sortie est déjà portée par un bouton de son contenu.
  bool showCloseButton = true,
}) {
  final theme = Theme.of(context);

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,

    // Assombrissement derrière la feuille. `scrim` est le rôle du thème fait
    // pour ça : un noir écrit en dur ne suivrait pas un thème sombre.
    //
    // Il valait 8 % : la page restait presque aussi claire que la feuille,
    // qui flottait dessus sans s'en détacher. À 32 %, et vu au travers du
    // flou, le fond recule vraiment. C'est le seul réglage à toucher pour
    // cela — le voile est peint **sous** le flou, donc l'assombrissement est
    // lui aussi flouté, et le fond ne devient pas un rectangle gris net.
    barrierColor: theme.colorScheme.scrim.withValues(alpha: 0.32),

    builder: (ctx) => _SheetFrame(
      color: color,
      minHeight: minHeight,
      title: title,
      onBack: onBack,
      showCloseButton: showCloseButton,
      child: child,
    ),
  );
}

class _SheetFrame extends StatefulWidget {
  const _SheetFrame({
    required this.child,
    required this.color,
    required this.minHeight,
    required this.title,
    required this.onBack,
    required this.showCloseButton,
  });

  final Widget child;
  final Color? color;
  final double? minHeight;
  final String? title;
  final VoidCallback? onBack;
  final bool showCloseButton;

  @override
  State<_SheetFrame> createState() => _SheetFrameState();
}

class _SheetFrameState extends State<_SheetFrame> {
  late final SheetHeaderController _header = SheetHeaderController(
    SheetHeader(title: widget.title, onBack: widget.onBack),
  );

  @override
  void dispose() {
    _header.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Lus **ici**, et par aspect. Ils l'étaient auparavant sur le contexte
    // appelant, avant l'ouverture de la route : `viewInsets` y valait donc
    // toujours zéro, et la feuille restait sous le clavier. Au passage,
    // `MediaQuery.of` abonnait l'écran appelant à *toutes* les métriques —
    // chaque trame d'ouverture du clavier le reconstruisait en entier.
    //
    // Réserve : tout ceci suppose que le système **annonce** son clavier. Sur
    // un émulateur Android 16 en mode bord-à-bord, il ne le fait pas — il fait
    // glisser la fenêtre entière, `viewInsets` reste à zéro et aucune trame
    // n'est reconstruite. Rien, au niveau du widget, ne rattrape ce cas : la
    // feuille suit alors la fenêtre. C'est vérifié, pas supposé.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // La hauteur de la barre d'état, lue sur la **vue** et non sur un
    // `MediaQuery`. Ceux-ci se manipulent en chemin : `showModalBottomSheet`
    // retire l'encart du haut de celui qu'il donne à son contenu, si bien
    // qu'une feuille ouverte depuis une autre feuille — ce que fait « Modifier
    // mon profil » — trouvait zéro et remontait sous l'heure du système.
    final view = View.of(context);
    final topInset = view.viewPadding.top / view.devicePixelRatio;

    // Même lecture pour le bas : la zone que le système se réserve, barre de
    // geste ou barre à trois boutons. Depuis que le bord à bord est imposé
    // (cible API 35), la feuille s'y posait dessous.
    //
    // `max` et non une somme : clavier ouvert, la barre de geste est **dans**
    // la zone du clavier, et additionner les deux ferait flotter la feuille
    // au-dessus de rien.
    final systemBottom = view.viewPadding.bottom / view.devicePixelRatio;
    final bottomInset = math.max(keyboard, systemBottom);

    // Ce qui reste au-dessus de tout cela. Sans cette soustraction, la
    // feuille remonte mais garde sa hauteur : elle déborde par le haut.
    final available = screenHeight - bottomInset;

    // Deux plafonds, et c'est le plus bas qui gagne :
    //
    // - une proportion de l'espace libre, pour qu'une feuille courte garde
    //   l'air d'une feuille et non d'une page ;
    // - la place réelle sous la barre d'état. Sans ce second plafond, un
    //   formulaire ouvert au-dessus du clavier remontait jusqu'à glisser sa
    //   poignée et sa croix sous l'heure et les icônes du système.
    final maxSheetHeight = math.min(
      available * 0.88,
      available - topInset - AppDimens.appPaddingValue * 2,
    );

    return Stack(
      children: [
        // ----------------------------------------------------------------
        // FLOU DE L'ARRIÈRE-PLAN
        // ----------------------------------------------------------------
        // Le voile porte lui-même la fermeture, et ce n'est pas un choix
        // de confort : `BottomSheet` enveloppe son contenu dans un `Material`
        // dont `absorbHitTest` vaut `true`. Comme le voile est plein écran,
        // ce `Material` l'est aussi — il avale donc **toute** touche, et la
        // barrière de la route, qui aurait normalement fermé la feuille, n'en
        // reçoit aucune. Le clic à l'extérieur ne faisait rien.
        //
        // `RepaintBoundary` : le flou se recalcule à chaque repeinture de sa
        // couche. Isolé, il ne suit plus le contenu de la feuille ; sans
        // cela, **chaque caractère tapé** refloutait tout l'écran.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: RepaintBoundary(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),

        // ----------------------------------------------------------------
        // LA FEUILLE
        // ----------------------------------------------------------------
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              left: AppDimens.appPaddingValue,
              right: AppDimens.appPaddingValue,
              // Le clavier pousse la feuille au lieu de la recouvrir.
              bottom: AppDimens.appPaddingValue + bottomInset,
            ),
            child: _Entrance(
              child: Material(
                // Le fond d'une feuille est un fond de **page**, pas un fond
                // de carte : les puces et les champs qu'elle contient sont
                // blancs ; sur du blanc ils disparaissent.
                color: widget.color ?? theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(AppDimens.bottomSheet),
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: widget.minHeight != null
                        ? available * widget.minHeight!
                        : 0,
                    maxHeight: maxSheetHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.appPaddingValue,
                      AppDimens.small,
                      AppDimens.appPaddingValue,
                      AppDimens.large,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // L'en-tête suit le pilote : c'est le contenu
                        // qui décide de son titre et de son retour, étape
                        // par étape.
                        ValueListenableBuilder<SheetHeader>(
                          valueListenable: _header,
                          builder: (context, header, _) => _Header(
                            title: header.title,
                            onBack: header.onBack,
                            showCloseButton: widget.showCloseButton,
                          ),
                        ),
                        AppDimens.spacerSmall,
                        Flexible(
                          // Le contenu est isolé du cadre : ce qui se
                          // repeint en tapant ne fait pas repeindre le flou.
                          child: RepaintBoundary(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: SheetHeaderScope(
                                notifier: _header,
                                child: widget.child,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Poignée, retour, fermeture.
class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.onBack,
    required this.showCloseButton,
  });

  final String? title;
  final VoidCallback? onBack;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: AppDimens.touchTarget,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: AppDimens.bottomSheetHandleWidth,
                height: AppDimens.bottomSheetHandleHeight,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.30,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimens.borderRadiusFull,
                  ),
                ),
              ),
              if (onBack != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomIconButton(
                    onPressed: onBack!,
                    tooltip: 'Étape précédente',
                    icon: Icons.arrow_back_ios_new_rounded,
                    tone: IconButtonTone.ghost,
                    iconSize: AppDimens.medium,
                  ),
                ),
              if (showCloseButton)
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomIconButton(
                    // Fermer d'un geste, sans avoir à viser l'extérieur ni
                    // à faire glisser la feuille vers le bas.
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Fermer',
                    icon: Icons.close_rounded,
                    tone: IconButtonTone.ghost,
                    iconSize: AppDimens.medium,
                  ),
                ),
            ],
          ),
        ),
        if (title != null) ...[
          AppDimens.spacerSmall,
          Text(
            title!,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

/// L'entrée de la feuille : une montée courte doublée d'un fondu.
///
/// Une fois entrée, l'animation s'efface complètement de l'arbre — un
/// `Opacity` ou un `Transform` laissé en place coûte une couche de
/// composition à chaque trame, pour ne plus rien animer.
class _Entrance extends StatelessWidget {
  const _Entrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: AppMotion.duration(context, AppMotion.base),
      curve: AppMotion.enter,
      tween: Tween(begin: 0, end: 1),
      child: child,
      builder: (context, value, sheetChild) {
        if (value == 1) return sheetChild!;
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: sheetChild),
        );
      },
    );
  }
}
