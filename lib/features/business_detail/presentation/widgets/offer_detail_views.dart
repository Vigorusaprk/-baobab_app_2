import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/dashed_rule.dart';
import 'package:baobabe_0_2/core/widgets/remote_image.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/offer_detail_cubit.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_detail_parts.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offers_carousel_section.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Les trois fiches d'offre.
///
/// Il n'y en avait qu'une, avec des `if` : une photo en tête, le nom, le
/// prix, la description, un bloc de faits, et une barre d'achat qui portait
/// la date, la quantité, le total et le bouton. Or les trois situations ne
/// posent pas les mêmes questions :
///
/// - **commander** : combien j'en prends, et combien ça fait ;
/// - **réserver** : quel jour, combien de places, et est-ce ferme ;
/// - **en boutique** : où, et quand y aller.
///
/// Chacune a donc sa mise en page, et l'ordre de chacune suit ses propres
/// questions. Ce qui leur est commun vit dans `offer_detail_parts.dart`.

/// Le retrait latéral des fiches d'offre.
///
/// Porté par chaque bloc et non par la liste : le carrousel de fin apporte le
/// sien, et une liste en retrait le lui ajouterait une seconde fois.
const EdgeInsets _sides = EdgeInsets.symmetric(
  horizontal: AppDimens.appPaddingValue + 4,
);

/// Une offre qu'on commande.
class OfferOrderView extends StatelessWidget {
  const OfferOrderView({
    super.key,
    required this.state,
    required this.onQuantityChanged,
  });

  final OfferDetailLoaded state;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = state.detail;
    final offer = detail.offer;

    return Column(
      children: [
        OfferTopBar(offer: offer, merchantName: detail.merchant?.name),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(
              top: AppDimens.medium,
              bottom: AppDimens.large,
            ),
            children: [
              Padding(
                padding: _sides,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OfferHeadline(offer: offer),
                    AppDimens.spacerMedium,
                    OfferPhoto(
                      url: offerImage(offer, detail.merchant),
                      height: 172,
                    ),
                    if (offer.description.isNotEmpty) ...[
                      AppDimens.spacerMedium,
                      Text(
                        offer.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                    AppDimens.spacerMedium,
                    const OfferFactBlock(
                      children: [
                        OfferFactLine(
                          icon: Icons.shopping_bag_outlined,
                          text:
                              'Se commande · vous indiquez où livrer au '
                              'moment de valider',
                        ),
                        OfferFactLine(
                          icon: Icons.wallet_outlined,
                          text:
                              'Paiement sur place ou à la livraison — rien '
                              'n\'est encaissé ici',
                          muted: true,
                        ),
                      ],
                    ),
                    if (!detail.isSoldOut) ...[
                      AppDimens.spacerMedium,
                      OfferCounterRow(
                        label: 'Quantité',
                        value: state.quantity,
                        max: detail.remainingCapacity,
                        onChanged: onQuantityChanged,
                      ),
                    ],
                    AppDimens.spacerLarge,
                    OfferReviews(detail: detail),
                  ],
                ),
              ),
              if (detail.otherOffers.isNotEmpty) _MoreFrom(state: state),
            ],
          ),
        ),
      ],
    );
  }
}

/// Une offre qu'on réserve.
///
/// La photo tient la tête : on choisit une soirée en terrasse sur ce qu'on en
/// voit. La date arrive juste après, parce que c'est la première décision.
class OfferBookingView extends StatelessWidget {
  const OfferBookingView({
    super.key,
    required this.state,
    required this.onQuantityChanged,
    required this.onPickDay,
    required this.onOpenCalendar,
  });

  final OfferDetailLoaded state;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<DateTime> onPickDay;
  final VoidCallback onOpenCalendar;

  static const double photoHeight = 226;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final detail = state.detail;
    final offer = detail.offer;
    final image = offerImage(offer, detail.merchant);
    final capacity = offer.capacity;
    final remaining = detail.remainingCapacity;
    final height = photoHeight + MediaQuery.paddingOf(context).top;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          children: [
            OfferPhotoFallback(
              height: height,
              child: image == null
                  ? null
                  : RemoteImage(
                      url: image,
                      fallback: OfferPhotoFallback(height: height),
                    ),
            ),
            OfferTopBar(
              offer: offer,
              merchantName: detail.merchant?.name,
              onFloating: true,
            ),
          ],
        ),
        Container(
          transform: Matrix4.translationValues(0, -14, 0),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radius16),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppDimens.appPaddingValue + 4,
            AppDimens.medium + 2,
            AppDimens.appPaddingValue + 4,
            AppDimens.large,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookingTag(fixedDate: offer.startsAt),
              AppDimens.spacerMedium,
              OfferHeadline(
                offer: offer,
                priceSuffix: capacity != null ? 'par place' : null,
              ),
              if (offer.description.isNotEmpty) ...[
                AppDimens.spacerMedium,
                Text(
                  offer.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ],
              AppDimens.spacerLarge,
              // Une séance impose son heure ; une table, un soin ou une
              // chambre laissent choisir.
              if (state.needsDateChoice)
                OfferDateChoice(
                  chosen: state.chosenDate,
                  onPickDay: onPickDay,
                  onOpenCalendar: onOpenCalendar,
                )
              else if (offer.startsAt != null)
                OfferFactLine(
                  icon: Icons.event_outlined,
                  text: DateFormat(
                    'EEEE d MMMM à HH:mm',
                    'fr_FR',
                  ).format(offer.startsAt!.toLocal()),
                ),
              if (capacity != null && remaining != null) ...[
                AppDimens.spacerLarge,
                OfferSeatsGauge(
                  capacity: capacity,
                  remaining: remaining,
                  taken: state.quantity,
                ),
              ],
              if (!detail.isSoldOut) ...[
                AppDimens.spacerLarge,
                OfferCounterRow(
                  label: capacity != null ? 'Nombre de places' : 'Quantité',
                  value: state.quantity,
                  max: remaining,
                  onChanged: onQuantityChanged,
                ),
              ],
              AppDimens.spacerMedium,
              const OfferPendingNotice(),
              AppDimens.spacerLarge,
              OfferReviews(detail: detail),
            ],
          ),
        ),
        if (detail.otherOffers.isNotEmpty) _MoreFrom(state: state),
      ],
    );
  }
}

/// Une offre qu'on ne peut que venir chercher.
///
/// Rien à valider, donc rien à décider : la page dit ce que c'est, où c'est,
/// et quand y aller. C'est la seule des trois sans compteur ni date.
class OfferInStoreView extends StatelessWidget {
  const OfferInStoreView({super.key, required this.state});

  final OfferDetailLoaded state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = state.detail;
    final offer = detail.offer;
    final merchant = detail.merchant;
    final hours = merchant?.todayHours;
    final address = merchant?.address;

    return Column(
      children: [
        OfferTopBar(offer: offer, merchantName: merchant?.name),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(
              top: AppDimens.medium,
              bottom: AppDimens.large,
            ),
            children: [
              Padding(
                padding: _sides,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OfferHeadline(offer: offer),
                    AppDimens.spacerMedium,
                    const _InStoreBanner(),
                    AppDimens.spacerMedium,
                    OfferPhoto(url: offerImage(offer, merchant), height: 150),
                    if (offer.description.isNotEmpty) ...[
                      AppDimens.spacerMedium,
                      Text(
                        offer.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                    AppDimens.spacerMedium,
                    if (address != null && address.isNotEmpty)
                      OfferFactLine(
                        icon: Icons.place_outlined,
                        text: '${merchant!.name} · $address',
                      ),
                    if (hours != null)
                      OfferFactLine(
                        icon: Icons.schedule_outlined,
                        text: 'Au comptoir, aujourd\'hui $hours',
                      ),
                    AppDimens.spacerLarge,
                    OfferReviews(detail: detail),
                  ],
                ),
              ),
              if (detail.otherOffers.isNotEmpty) _MoreFrom(state: state),
            ],
          ),
        ),
      ],
    );
  }
}

/// L'étiquette qui dit d'entrée ce qu'on regarde.
class _BookingTag extends StatelessWidget {
  const _BookingTag({required this.fixedDate});

  final DateTime? fixedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.small + 2,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available_outlined, size: 13, color: scheme.primary),
          AppDimens.spacerSmallWidth,
          Text(
            fixedDate == null ? 'Sur réservation' : 'Séance à date fixe',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Le bandeau d'une offre en boutique : ce qui n'aura pas lieu dans
/// l'application, dit avant qu'on cherche le bouton.
class _InStoreBanner extends StatelessWidget {
  const _InStoreBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        const DashedRule(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.medium),
          child: Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                size: AppDimens.large,
                color: scheme.primary,
              ),
              AppDimens.spacerMediumWidth,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disponible en boutique',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppDimens.spacerMini,
                    Text(
                      'Ni commande ni réservation : à prendre sur place.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const DashedRule(),
      ],
    );
  }
}

/// De quoi rebondir sans repasser par la fiche du commerçant.
class _MoreFrom extends StatelessWidget {
  const _MoreFrom({required this.state});

  final OfferDetailLoaded state;

  @override
  Widget build(BuildContext context) {
    return OffersCarouselSection(
      title: 'Chez le même commerçant',
      offers: state.detail.otherOffers,
    );
  }
}
