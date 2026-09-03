import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/core/widgets/dashed_rule.dart';
import 'package:baobabe_0_2/core/widgets/remote_image.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_detail.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/review_list_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

/// Les pièces communes aux trois fiches d'offre.
///
/// Une offre se commande, se réserve, ou se prend en boutique — et ces trois
/// situations ne posent pas les mêmes questions. Elles partaient pourtant
/// d'une seule page : même photo en tête, même bloc de faits, même barre
/// d'achat, avec des `if` pour éteindre ce qui ne servait pas. Une offre en
/// boutique héritait donc d'une barre d'achat vide, et une réservation
/// cachait sa date dans une ligne de bas de page.
///
/// Chaque mode a maintenant sa mise en page ; ce fichier porte ce qu'elles
/// ont réellement en commun.

/// La barre du haut : retour, chez qui, partage.
class OfferTopBar extends StatelessWidget {
  const OfferTopBar({
    super.key,
    required this.offer,
    this.merchantName,
    this.onFloating = false,
  });

  final Offer offer;
  final String? merchantName;

  /// Posée **sur la photo** : les boutons prennent alors un disque blanc,
  /// sinon ils se perdent dans l'image.
  final bool onFloating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = merchantName ?? offer.businessName;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.small + 2,
        MediaQuery.paddingOf(context).top + AppDimens.small,
        AppDimens.small + 2,
        0,
      ),
      child: Row(
        children: [
          CustomIconButton(
            onPressed: () => _back(context),
            tooltip: 'Retour',
            icon: Icons.arrow_back_rounded,
            tone: onFloating ? IconButtonTone.surface : IconButtonTone.ghost,
            circle: true,
            iconSize: AppDimens.medium + 2,
          ),
          if (!onFloating && name != null && name.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: AppDimens.tiny),
                child: Text(
                  name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          CustomIconButton(
            onPressed: () => _share(name),
            tooltip: 'Partager cette offre',
            icon: Icons.ios_share_rounded,
            tone: onFloating ? IconButtonTone.surface : IconButtonTone.ghost,
            circle: true,
            iconSize: AppDimens.medium + 2,
          ),
        ],
      ),
    );
  }

  void _back(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go('/home');
    }
  }

  /// Un partage **texte** : il n'existe pas d'adresse web par offre.
  Future<void> _share(String? merchant) {
    final where = (merchant == null || merchant.isEmpty)
        ? ''
        : '\nChez $merchant';
    return SharePlus.instance.share(
      ShareParams(
        text: '${offer.name}$where\n\nVu sur Baobabe.',
        subject: offer.name,
      ),
    );
  }
}

/// Le nom de l'offre et son prix, en grand.
///
/// C'est la première chose qu'on cherche, et c'était un `titleMedium` suivi
/// d'un prix de la taille du corps de texte.
class OfferHeadline extends StatelessWidget {
  const OfferHeadline({
    super.key,
    required this.offer,
    this.priceSuffix,
    this.showRating = true,
  });

  final Offer offer;

  /// « par personne », « pot de 250 ml » : ce que le prix couvre, quand ce
  /// n'est pas évident.
  final String? priceSuffix;

  final bool showRating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          offer.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.08,
          ),
        ),
        AppDimens.spacerMedium,
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              offer.isFree ? 'Sur demande' : offerMoney(offer.price),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
            AppDimens.spacerSmallWidth,
            if (priceSuffix != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  priceSuffix!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            const Spacer(),
            if (showRating && offer.reviewCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: AppDimens.medium,
                      color: OtherTheme.of(context).rating,
                    ),
                    AppDimens.spacerMiniWidth,
                    Text(
                      '${offer.rating.toStringAsFixed(1).replaceAll('.', ',')}'
                      ' · ${offer.reviewCount} avis',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// La photo de l'offre, à la hauteur que sa fiche lui donne.
///
/// L'URL est **déjà résolue** par la fiche : `get-offer-detail` ne renvoie
/// pas l'image du commerce dans la ligne de l'offre, alors que les cartes de
/// l'accueil l'utilisent en repli. Une offre sans visuel propre affichait
/// donc un rectangle gris vide, là où l'accueil montrait la photo du
/// commerce. Voir [offerImage].
class OfferPhoto extends StatelessWidget {
  const OfferPhoto({super.key, required this.url, required this.height});

  final String? url;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: OfferPhotoFallback(
          height: height,
          child: url == null || url!.isEmpty
              ? null
              : RemoteImage(
                  url: url,
                  fallback: OfferPhotoFallback(height: height),
                ),
        ),
      ),
    );
  }
}

/// Le repli d'une photo absente ou illisible : une forme propre et une
/// icône, jamais un rectangle vide qui ressemble à une panne.
class OfferPhotoFallback extends StatelessWidget {
  const OfferPhotoFallback({super.key, required this.height, this.child});

  final double height;

  /// L'image, quand il y en a une : le repli n'est alors que son fond.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child:
          child ??
          Icon(
            Icons.image_outlined,
            size: AppDimens.large,
            color: scheme.onSurfaceVariant,
          ),
    );
  }
}

/// Le visuel d'une offre sur sa fiche.
///
/// Celui de l'offre, à défaut celui du commerce. `Offer.displayImage` fait
/// déjà ce repli, mais sur `businessImage` — un champ que `get-offer-detail`
/// ne renseigne pas, puisqu'il renvoie le commerce à part. La fiche recolle
/// donc les deux.
String? offerImage(Offer offer, OfferMerchant? merchant) {
  final own = offer.displayImage;
  if (own != null && own.isNotEmpty) return own;
  final theirs = merchant?.image;
  return (theirs != null && theirs.isNotEmpty) ? theirs : null;
}

/// Une ligne de fait : une icône, une phrase.
class OfferFactLine extends StatelessWidget {
  const OfferFactLine({
    super.key,
    required this.icon,
    required this.text,
    this.muted = false,
  });

  final IconData icon;
  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.small + 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppDimens.medium, color: theme.colorScheme.primary),
          AppDimens.spacerSmallWidth,
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: muted
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Un bloc de faits, entre deux perforations.
class OfferFactBlock extends StatelessWidget {
  const OfferFactBlock({
    super.key,
    required this.children,
    this.topOnly = false,
  });

  final List<Widget> children;

  /// Un seul filet, en haut : pour un bloc qui termine une section.
  final bool topOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashedRule(),
        AppDimens.spacerMedium,
        ...children,
        if (!topOnly) ...[AppDimens.spacerSmall, const DashedRule()],
      ],
    );
  }
}

/// Ce que la demande va devenir : en attente, jusqu'à ce que le commerce
/// confirme.
///
/// Le mot manquait. Une réservation partait sans prévenir qu'elle n'était pas
/// ferme, et l'utilisateur se présentait sur place avec une demande que
/// personne n'avait acceptée.
class OfferPendingNotice extends StatelessWidget {
  const OfferPendingNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final other = OtherTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.small + 4),
      decoration: BoxDecoration(
        color: other.warningContainer,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: AppDimens.medium,
            color: other.onWarningContainer,
          ),
          AppDimens.spacerSmallWidth,
          Expanded(
            child: Text(
              'La demande partira en attente : elle devient ferme quand le '
              'commerce la confirme.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: other.onWarningContainer,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Les avis sur l'offre, en rail.
///
/// Deux suffisent à donner le ton ; le reste s'ouvre dans une feuille. La
/// fiche empilait les dix avis chargés, ce qui repoussait tout ce qui suit
/// hors de l'écran.
class OfferReviews extends StatelessWidget {
  const OfferReviews({super.key, required this.detail});

  final OfferDetail detail;

  static const int _preview = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviews = detail.reviews;
    if (reviews.isEmpty) return const SizedBox.shrink();

    final offer = detail.offer;
    final shown = reviews.take(_preview).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashedRule(),
        AppDimens.spacerMedium,
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'AVIS SUR CETTE OFFRE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.star_rounded,
              size: AppDimens.medium,
              color: OtherTheme.of(context).rating,
            ),
            AppDimens.spacerMiniWidth,
            Text(
              offer.rating.toStringAsFixed(1).replaceAll('.', ','),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ' · ${offer.reviewCount} avis',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        AppDimens.spacerMedium,
        for (var i = 0; i < shown.length; i++)
          ReviewListItem(review: shown[i], accent: i == 0),
        if (reviews.length > _preview)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _openAll(context),
              child: Text(
                'Tous les avis',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _openAll(BuildContext context) {
    final reviews = detail.reviews;
    final truncated = detail.offer.reviewCount > reviews.length;

    showCustomBottomSheet<void>(
      context: context,
      title: 'Avis · ${detail.offer.reviewCount}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (truncated) ...[
            Text(
              'Les ${reviews.length} plus récents.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            AppDimens.spacerMedium,
          ],
          for (var i = 0; i < reviews.length; i++)
            ReviewListItem(review: reviews[i], accent: i == 0),
        ],
      ),
    );
  }
}

/// La jauge de places.
///
/// Le nombre de places restantes était une ligne de texte parmi d'autres. Une
/// jauge dit d'un coup d'œil ce qu'une phrase fait lire : ce qui est pris, ce
/// qui reste, et ce que la demande en cours va prendre.
class OfferSeatsGauge extends StatelessWidget {
  const OfferSeatsGauge({
    super.key,
    required this.capacity,
    required this.remaining,
    required this.taken,
  });

  final int capacity;
  final int remaining;

  /// Ce que la demande en cours réserverait.
  final int taken;

  /// Au-delà, les barres ne se distinguent plus les unes des autres.
  static const int _maxBars = 8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bars = capacity.clamp(1, _maxBars);
    // Ramené à l'échelle des barres quand la salle est plus grande que huit.
    final free = (remaining * bars / capacity).round().clamp(0, bars);
    // Une place demandée dans une salle de 80 tombait à zéro barre par
    // arrondi : le compteur bougeait sans que la jauge réagisse.
    final scaled = (taken * bars / capacity).round();
    final held = (taken > 0 ? (scaled < 1 ? 1 : scaled) : 0).clamp(0, free);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'PLACES',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            Text(
              remaining <= 0
                  ? 'Complet'
                  : '$remaining restante${remaining > 1 ? 's' : ''} '
                        'sur $capacity',
              style: theme.textTheme.labelMedium?.copyWith(
                color: remaining <= 0 ? scheme.error : scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        AppDimens.spacerSmall,
        Row(
          spacing: 4,
          children: [
            for (var i = 1; i <= bars; i++)
              Expanded(
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: i <= held
                        ? scheme.primary
                        : i <= free
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Le choix de la date, en pastilles.
///
/// C'était un `showDatePicker` derrière une ligne « Choisir une date » au bas
/// de la page : deux écrans de calendrier pour réserver ce soir. Les trois
/// prochains jours sont donc là, et le calendrier reste pour le reste.
class OfferDateChoice extends StatelessWidget {
  const OfferDateChoice({
    super.key,
    required this.chosen,
    required this.onPickDay,
    required this.onOpenCalendar,
  });

  final DateTime? chosen;

  /// Le jour touché. L'heure suit, demandée aussitôt : une table sans heure
  /// n'est pas une réservation.
  final ValueChanged<DateTime> onPickDay;

  final VoidCallback onOpenCalendar;

  /// Trois lignes — le jour, le chiffre, le mois — et le bouton calendrier
  /// qui se cale sur la même hauteur.
  static const double chipHeight = 68;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final days = [
      for (var i = 0; i < 3; i++)
        DateTime(today.year, today.month, today.day + i),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.1,
          ),
        ),
        AppDimens.spacerSmall,
        Row(
          spacing: AppDimens.small,
          children: [
            for (final day in days)
              Expanded(
                child: _DayChip(
                  day: day,
                  selected: _isSameDay(day, chosen),
                  onTap: () => onPickDay(day),
                ),
              ),
            CustomIconButton(
              onPressed: onOpenCalendar,
              tooltip: 'Choisir une autre date',
              icon: Icons.calendar_month_outlined,
              tone: IconButtonTone.ghost,
              iconSize: AppDimens.medium + 4,
              button: chipHeight,
            ),
          ],
        ),
      ],
    );
  }

  static bool _isSameDay(DateTime a, DateTime? b) =>
      b != null && a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.55)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Container(
          height: OfferDateChoice.chipHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          // Trois lignes dans 64 px : les interlignes du thème débordaient
          // de 3 px. Elles sont donc resserrées ici, et seulement ici.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEE', 'fr_FR').format(day),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  height: 1.1,
                ),
              ),
              Text(
                '${day.day}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  color: selected ? scheme.primary : scheme.onSurface,
                ),
              ),
              Text(
                DateFormat('MMM', 'fr_FR').format(day),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// « Quantité », « Nombre de places » : un libellé et un compteur.
///
/// Le compteur vivait dans la barre du bas, collé au bouton de validation :
/// on ajustait sa commande à côté du geste qui l'envoie. Il est ici, dans la
/// page, avec ce qu'il compte.
class OfferCounterRow extends StatelessWidget {
  const OfferCounterRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.max,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  /// Bornage haut, quand une jauge de places existe : proposer d'en prendre
  /// plus qu'il n'en reste ne mène qu'à un refus au moment de valider.
  final int? max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final canAdd = max == null || value < max!;

    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Step(
                icon: Icons.remove_rounded,
                tooltip: 'Un de moins',
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _Step(
                icon: Icons.add_rounded,
                tooltip: 'Un de plus',
                onPressed: canAdd ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: AppDimens.medium),
      color: scheme.primary,
      disabledColor: scheme.outlineVariant,
      constraints: const BoxConstraints(
        minWidth: AppDimens.touchTarget - 8,
        minHeight: AppDimens.touchTarget - 8,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Un montant, écrit comme le reste de l'application.
String offerMoney(double amount) =>
    '${amount.toStringAsFixed(2).replaceAll('.', ',')} \$';
