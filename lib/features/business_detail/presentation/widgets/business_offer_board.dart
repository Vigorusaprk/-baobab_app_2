import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/core/widgets/remote_image.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Le catalogue du commerce, filtré par ce qu'on peut en faire.
///
/// C'étaient des carrousels — un par rayon déclaré par le commerçant
/// (Entrées, Chambres, Séances). Deux défauts : un carrousel cache ce qui
/// dépasse de l'écran, et le rayon est un classement de commerçant, pas une
/// question de client. La question du client est **ce qu'il peut en faire** :
/// commander, réserver, ou passer le prendre.
///
/// Le filtre reste donc épinglé en haut pendant qu'on descend, et les offres
/// se lisent en colonne, sans rien cacher.
///
/// Ce widget **rend un sliver** : c'est ce qui permet d'épingler le filtre
/// sans sortir l'état du filtre de son propre widget.
class BusinessOfferBoard extends StatefulWidget {
  const BusinessOfferBoard({super.key, required this.offers});

  final List<Offer> offers;

  @override
  State<BusinessOfferBoard> createState() => _BusinessOfferBoardState();
}

/// Ce que le filtre laisse passer.
enum _Lens {
  all,
  order,
  booking,
  inStore;

  String get label => switch (this) {
    _Lens.all => 'Tout',
    _Lens.order => 'Commander',
    _Lens.booking => 'Réserver',
    _Lens.inStore => 'Boutique',
  };

  Fulfilment? get fulfilment => switch (this) {
    _Lens.all => null,
    _Lens.order => Fulfilment.order,
    _Lens.booking => Fulfilment.booking,
    _Lens.inStore => Fulfilment.inStore,
  };
}

class _BusinessOfferBoardState extends State<BusinessOfferBoard> {
  _Lens _lens = _Lens.all;

  /// Les seuls filtres proposés sont ceux qui trient quelque chose : un
  /// onglet vide n'apprend rien, et un onglet unique ne trie rien.
  List<_Lens> get _lenses {
    final kinds = widget.offers.map((o) => o.fulfilment).toSet();
    if (kinds.length < 2) return const [];
    return [
      _Lens.all,
      for (final lens in [_Lens.order, _Lens.booking, _Lens.inStore])
        if (kinds.contains(lens.fulfilment)) lens,
    ];
  }

  List<Offer> get _visible {
    final wanted = _lens.fulfilment;
    if (wanted == null) return widget.offers;
    return widget.offers.where((o) => o.fulfilment == wanted).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty) {
      return const SliverToBoxAdapter(child: _NoOffer());
    }

    final lenses = _lenses;
    final groups = _groups(_visible);

    return SliverMainAxisGroup(
      slivers: [
        if (lenses.isNotEmpty)
          SliverPersistentHeader(
            pinned: true,
            delegate: _LensHeader(
              topInset: MediaQuery.paddingOf(context).top,
              child: _LensRow(
                lenses: lenses,
                current: _lens,
                total: widget.offers.length,
                onPick: (lens) => setState(() => _lens = lens),
              ),
            ),
          ),
        SliverList(
          delegate: SliverChildListDelegate([
            for (final group in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.appPaddingValue,
                  AppDimens.medium,
                  AppDimens.appPaddingValue,
                  AppDimens.small,
                ),
                child: Text(
                  group.key.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              for (final offer in group.value) BusinessOfferRow(offer: offer),
            ],
          ]),
        ),
      ],
    );
  }

  /// Groupe par mode d'obtention, dans l'ordre où l'on s'en sert : ce qui
  /// se commande, ce qui se réserve, ce qui se prend sur place.
  static Map<String, List<Offer>> _groups(List<Offer> offers) {
    final groups = <String, List<Offer>>{};
    for (final fulfilment in Fulfilment.values) {
      final slice = offers.where((o) => o.fulfilment == fulfilment).toList();
      if (slice.isEmpty) continue;
      groups[switch (fulfilment) {
            Fulfilment.order => 'À commander',
            Fulfilment.booking => 'À réserver',
            Fulfilment.inStore => 'En boutique',
          }] =
          slice;
    }
    return groups;
  }
}

/// Ce qui épingle la rangée de filtres.
///
/// Le fond est **opaque** : sans lui, les rangées défileraient visiblement
/// sous les pastilles.
///
/// Il réserve aussi la barre d'état. La page est bord à bord — la photo passe
/// sous l'horloge, ce qui est voulu — mais une fois épinglées, les pastilles
/// s'y collaient aussi et « Tout · 10 » se peignait par-dessus l'heure. La
/// réserve est **permanente** : un décalage qui n'apparaîtrait qu'à
/// l'épinglage ferait sauter la liste, alors qu'ici il ne fait qu'ouvrir un
/// peu d'air sous la carte d'identité du commerce.
class _LensHeader extends SliverPersistentHeaderDelegate {
  const _LensHeader({required this.child, required this.topInset});

  final Widget child;
  final double topInset;

  /// La hauteur d'une pastille, plus l'air au-dessus et en dessous.
  static const double _height = 62;

  @override
  double get minExtent => _height + topInset;

  @override
  double get maxExtent => _height + topInset;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      height: _height + topInset,
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.only(top: topInset),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(
              // Le filet n'apparaît qu'une fois quelque chose passé dessous.
              alpha: overlaps ? 1 : 0,
            ),
            width: 0.7,
          ),
        ),
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_LensHeader oldDelegate) =>
      oldDelegate.child != child || oldDelegate.topInset != topInset;
}

/// La rangée de filtres, épinglée par le sliver de la page.
class _LensRow extends StatelessWidget {
  const _LensRow({
    required this.lenses,
    required this.current,
    required this.total,
    required this.onPick,
  });

  final List<_Lens> lenses;
  final _Lens current;
  final int total;
  final ValueChanged<_Lens> onPick;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.appPaddingValue,
      ),
      child: Row(
        spacing: AppDimens.small - 2,
        children: [
          for (final lens in lenses)
            _LensChip(
              // Le compte n'est porté que par « Tout » : sur les autres, il
              // répéterait la longueur de la liste juste en dessous.
              label: lens == _Lens.all ? '${lens.label} · $total' : lens.label,
              selected: lens == current,
              onTap: () => onPick(lens),
            ),
        ],
      ),
    );
  }
}

class _LensChip extends StatelessWidget {
  const _LensChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.55)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.small + 4,
            vertical: AppDimens.small + 1,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Une offre, en rangée.
///
/// La photo tient 74 px : assez pour reconnaître un plat, pas assez pour
/// pousser le prix hors de vue. Le geste de droite dit ce qui va se passer —
/// un plus pour ce qui se commande, un agenda pour ce qui se réserve, rien
/// pour ce qui se prend sur place.
class BusinessOfferRow extends StatelessWidget {
  const BusinessOfferRow({super.key, required this.offer});

  final Offer offer;

  static const double _thumb = 74;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final image = offer.displayImage;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.appPaddingValue,
        0,
        AppDimens.appPaddingValue,
        AppDimens.small + 2,
      ),
      child: Material(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: InkWell(
          onTap: () => _open(context),
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.small + 2),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.small),
                  child: SizedBox(
                    width: _thumb,
                    height: _thumb,
                    child: image != null && image.isNotEmpty
                        ? RemoteImage(url: image, fallback: const _NoPhoto())
                        : const _NoPhoto(),
                  ),
                ),
                AppDimens.spacerMediumWidth,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (offer.description.isNotEmpty) ...[
                        AppDimens.spacerMini,
                        Text(
                          offer.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                      AppDimens.spacerSmall,
                      Row(
                        children: [
                          Text(
                            offer.isFree ? 'Sur demande' : _money(offer.price),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (offer.reviewCount > 0) ...[
                            AppDimens.spacerSmallWidth,
                            Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: OtherTheme.of(context).rating,
                            ),
                            Text(
                              offer.rating
                                  .toStringAsFixed(1)
                                  .replaceAll('.', ','),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (!offer.isInStoreOnly) ...[
                  AppDimens.spacerSmallWidth,
                  CustomIconButton(
                    onPressed: () => _open(context),
                    tooltip: offer.isOrderable
                        ? 'Commander ${offer.name}'
                        : 'Réserver ${offer.name}',
                    icon: offer.isOrderable
                        ? Icons.add_rounded
                        : Icons.event_available_outlined,
                    tone: IconButtonTone.ghost,
                    circle: true,
                    iconSize: AppDimens.medium + 2,
                    button: 40,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) => context.push('/offer/${offer.id}');

  static String _money(double amount) =>
      '${amount.toStringAsFixed(2).replaceAll('.', ',')} \$';
}

class _NoPhoto extends StatelessWidget {
  const _NoPhoto();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_outlined,
        size: AppDimens.medium + 2,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

/// Un commerce inscrit qui n'a rien publié.
///
/// La section disparaissait purement et simplement, et la fiche s'arrêtait
/// sur les horaires — sans dire si le commerce n'a rien à vendre ou si
/// l'application avait échoué à le lire.
class _NoOffer extends StatelessWidget {
  const _NoOffer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.appPaddingValue,
        vertical: AppDimens.medium,
      ),
      child: Row(
        children: [
          Icon(
            Icons.storefront_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: Text(
              'Ce commerce ne propose encore rien dans l\'application. '
              'Vous pouvez le contacter directement.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
