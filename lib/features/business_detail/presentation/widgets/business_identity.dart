import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Qui est ce commerce, et les deux gestes qu'on a en le lisant.
///
/// La feuille recouvre la photo de quelques pixels : elle dit que ce qui
/// suit est le commerce, pas une légende de l'image.
///
/// L'ordre répond aux questions dans l'ordre où on se les pose : son nom, ce
/// qu'il est et où, ce qu'on en dit, s'il est ouvert, comment le joindre.
class BusinessIdentity extends StatelessWidget {
  const BusinessIdentity({
    super.key,
    required this.business,
    required this.uiBusiness,
    required this.ratedOffers,
  });

  final Business business;
  final UIBusiness uiBusiness;

  /// Nombre d'offres notées. La note d'un commerce est la moyenne de celles
  /// de ses offres : dire sur combien elle porte évite de faire passer un
  /// seul avis pour un consensus.
  final int ratedOffers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hours = _hoursTag(business);

    return Container(
      // Le recouvrement : la feuille monte sur la photo.
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
        AppDimens.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    AppDimens.spacerSmall,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // La couleur de la catégorie, réduite à un point :
                        // elle situe sans repeindre la page.
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: uiBusiness.categoryColor(context),
                            ),
                          ),
                        ),
                        AppDimens.spacerSmallWidth,
                        Expanded(
                          child: Text(
                            business.address.isEmpty
                                ? uiBusiness.categoryLabel
                                : '${uiBusiness.categoryLabel} · '
                                      '${business.address}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (business.reviewCount > 0) ...[
                AppDimens.spacerMediumWidth,
                _Rating(rating: business.rating, ratedOffers: ratedOffers),
              ],
            ],
          ),
          if (hours != null) ...[AppDimens.spacerMedium, hours],
          AppDimens.spacerMedium,
          Row(
            children: [
              if (business.phone.isNotEmpty) ...[
                Expanded(
                  child: CustomActionButton(
                    label: 'Appeler',
                    icon: Icons.phone_outlined,
                    tone: ActionButtonTone.tonal,
                    expand: true,
                    onPressed: () => _launch('tel:${business.phone}'),
                  ),
                ),
                AppDimens.spacerSmallWidth,
              ],
              Expanded(
                child: CustomActionButton(
                  label: 'Itinéraire',
                  icon: Icons.map_outlined,
                  tone: ActionButtonTone.tonal,
                  expand: true,
                  onPressed: () => _launch(_mapsUrl(business)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Le point de départ, quand on l'a. Sans coordonnées, l'adresse écrite
  /// suffit à l'application de cartes.
  static String _mapsUrl(Business business) {
    final lat = business.latitude;
    final lng = business.longitude;
    final query = (lat != null && lng != null)
        ? '$lat,$lng'
        : Uri.encodeComponent('${business.name} ${business.address}');
    return 'https://www.google.com/maps/search/?api=1&query=$query';
  }

  static Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  /// « Ouvert · jusqu'à 23:00 », quand les horaires du jour se lisent.
  ///
  /// Le commerçant saisit du texte libre : on ne devine donc rien. Deux
  /// heures reconnues dans la ligne du jour, et seulement là, donnent
  /// l'état ; sinon la ligne est reprise telle quelle, sans jugement.
  static Widget? _hoursTag(Business business) {
    final today = _todayHours(business);
    if (today == null || today.trim().isEmpty) return null;

    final times = RegExp(r'(\d{1,2})\s*[:hH]\s*(\d{2})?').allMatches(today);
    if (times.length < 2) return _NeutralTag(label: today.trim());

    final list = times.toList();
    final open = _minutes(list.first);
    final close = _minutes(list[1]);
    final now = DateTime.now();
    final current = now.hour * 60 + now.minute;

    // Un service qui passe minuit ferme « le lendemain » : la comparaison
    // simple dirait fermé toute la soirée.
    final isOpen = close > open
        ? current >= open && current < close
        : current >= open || current < close;

    return _StateTag(
      open: isOpen,
      label: isOpen
          ? 'Ouvert · jusqu\'à ${_clock(close)}'
          : 'Fermé · ouvre à ${_clock(open)}',
    );
  }

  static String? _todayHours(Business business) {
    const days = {
      1: 'lundi',
      2: 'mardi',
      3: 'mercredi',
      4: 'jeudi',
      5: 'vendredi',
      6: 'samedi',
      7: 'dimanche',
    };
    final wanted = days[DateTime.now().weekday];
    for (final entry in business.openingHours.entries) {
      if (entry.key.trim().toLowerCase() == wanted) return entry.value;
    }
    return null;
  }

  static int _minutes(RegExpMatch match) =>
      int.parse(match.group(1)!) * 60 + int.parse(match.group(2) ?? '0');

  static String _clock(int minutes) {
    final hours = (minutes ~/ 60).toString().padLeft(2, '0');
    final rest = (minutes % 60).toString().padLeft(2, '0');
    return '$hours:$rest';
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.rating, required this.ratedOffers});

  final double rating;
  final int ratedOffers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plural = ratedOffers > 1 ? 's' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Icon(
              Icons.star_rounded,
              size: AppDimens.medium,
              color: OtherTheme.of(context).rating,
            ),
            AppDimens.spacerMiniWidth,
            Text(
              rating.toStringAsFixed(1).replaceAll('.', ','),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (ratedOffers > 0)
          Text(
            '$ratedOffers offre$plural notée$plural',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

/// L'étiquette d'état : ouvert en vert d'action, fermé en gris.
class _StateTag extends StatelessWidget {
  const _StateTag({required this.open, required this.label});

  final bool open;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = open ? scheme.primary : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.small + 2,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: open
            ? scheme.primaryContainer.withValues(alpha: 0.5)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          AppDimens.spacerSmallWidth,
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NeutralTag extends StatelessWidget {
  const _NeutralTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.small + 2,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
