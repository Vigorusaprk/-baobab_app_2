import 'package:baobabe_0_2/core/animation/press_effect.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/activity/domain/activity_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// L'en-tête du flux : un sur-titre, puis le compte en toutes lettres.
///
/// Il portait une icône, un titre et une pastille chiffrée. Le chiffre ne
/// disait pas de quoi il était le compte, et le titre répétait le nom de
/// l'onglet. Ici la première ligne situe, la seconde **dit l'état** : « 2 en
/// cours, 5 terminées » se lit d'un coup d'œil et répond à la seule question
/// qu'on se pose en ouvrant cet écran.
class ActivityHeader extends StatelessWidget {
  const ActivityHeader({
    super.key,
    required this.entries,
    this.loading = false,
  });

  final List<ActivityEntry> entries;

  /// Pendant le chargement la liste est vide, et l'en-tête annonçait donc
  /// « Aucune activité » — un compte faux, sur une seule ligne, qui sautait
  /// à deux lignes dès l'arrivée des données. Il porte un os à la place.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final running = entries.where((e) => !e.isSettled).length;
    final done = entries.length - running;

    // Le même gabarit que le compte réel : Skeletonizer transforme ce texte
    // en barre grise de la taille exacte qu'il occupera.
    final count = Text(
      loading ? '00 en cours,\n0 terminées' : _count(running, done),
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.15,
      ),
    );

    return Padding(
      // La barre d'état est à notre charge : cet onglet n'a pas d'app bar,
      // et sans cette réserve le sur-titre se peignait par-dessus l'heure du
      // système. Même blanc que l'en-tête de l'accueil.
      padding: EdgeInsets.fromLTRB(
        AppDimens.appPaddingValue,
        MediaQuery.paddingOf(context).top + AppDimens.headerTopGap,
        AppDimens.appPaddingValue,
        AppDimens.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VOS ACTIVITÉS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppDimens.spacerMini,
          if (loading) Skeletonizer(enabled: true, child: count) else count,
        ],
      ),
    );
  }

  static String _count(int running, int done) {
    if (running == 0 && done == 0) return 'Aucune activité';
    final parts = <String>[
      if (running > 0) '$running en cours',
      if (done > 0) '$done terminée${done > 1 ? 's' : ''}',
    ];
    // Sur deux lignes : la phrase est le titre de l'écran, et un titre qui
    // s'étale sur toute la largeur ne se lit plus comme un titre.
    return parts.join(',\n');
  }
}

/// Le flux : ce qui est en cours, puis l'historique par repère de temps.
class ActivityFlow extends StatelessWidget {
  const ActivityFlow({super.key, required this.entries, required this.onOpen});

  final List<ActivityEntry> entries;
  final ValueChanged<ActivityEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    final groups = ActivityGroup.from(entries);

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: AppDimens.appPaddingValue,
        right: AppDimens.appPaddingValue,
        // La barre de navigation flotte au-dessus du contenu : sans cette
        // réserve, la dernière ligne finit dessous.
        bottom: AppDimens.touchTarget + AppDimens.large * 2,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GroupLabel(
              label: group.label,
              isFirst: index == 0,
              // « En cours » n'est pas un repère de temps mais la raison
              // d'être de l'écran : il porte la couleur d'action.
              accent: group.label == ActivityGroup.ongoingLabel,
            ),
            for (final entry in group.entries)
              ActivityRow(entry: entry, onTap: () => onOpen(entry)),
          ],
        );
      },
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({
    required this.label,
    required this.isFirst,
    this.accent = false,
  });

  final String label;
  final bool isFirst;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? AppDimens.small : AppDimens.large,
        bottom: AppDimens.tiny,
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: accent ? scheme.primary : scheme.onSurfaceVariant,
          fontWeight: accent ? FontWeight.w700 : null,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Une ligne du flux.
///
/// Pas une carte : une **ligne**. Les cartes d'avant portaient chacune leur
/// ombre et leur cadre, si bien qu'une liste de six commandes donnait six
/// boîtes à lire séparément. Ici un filet vertical à gauche marque ce qui est
/// en cours, un filet horizontal en retrait sépare les lignes, et l'œil
/// descend sans obstacle.
class ActivityRow extends StatelessWidget {
  const ActivityRow({super.key, required this.entry, required this.onTap});

  final ActivityEntry entry;
  final VoidCallback onTap;

  /// L'épaisseur du filet de gauche. Volontairement fin : il signale, il ne
  /// décore pas.
  static const double _railWidth = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final railColor = entry.isSettled
        ? scheme.onSurface.withValues(alpha: 0.16)
        : scheme.primary;
    final statusColor = entry.isCancelled
        ? scheme.error
        : entry.isSettled
        ? scheme.onSurfaceVariant
        : scheme.primary;

    return PressEffect(
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          // Une activité close reste consultable, mais elle recule.
          opacity: entry.isSettled ? 0.72 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.small + 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: scheme.outlineVariant, width: 0.7),
              ),
            ),
            // `IntrinsicHeight` parce que le filet de gauche doit courir sur
            // toute la hauteur du texte : `stretch` seul demande à la rangée
            // une hauteur qu'une liste défilante ne borne pas, et Flutter
            // refuse — « BoxConstraints forces an infinite height ».
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: _railWidth,
                    decoration: BoxDecoration(
                      color: railColor,
                      borderRadius: BorderRadius.circular(_railWidth),
                    ),
                  ),
                  AppDimens.spacerMediumWidth,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                entry.businessName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            AppDimens.spacerSmallWidth,
                            Text(
                              _stamp(entry.happenedAt),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        AppDimens.spacerMini,
                        Text(
                          entry.summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        AppDimens.spacerMini,
                        _StatusLine(entry: entry, color: statusColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// L'heure pour aujourd'hui, le jour au-delà : c'est ce qui distingue deux
  /// lignes voisines, et rien de plus n'est utile.
  static String _stamp(DateTime moment) {
    final now = DateTime.now();
    final sameDay =
        moment.year == now.year &&
        moment.month == now.month &&
        moment.day == now.day;
    if (sameDay) return DateFormat('HH:mm').format(moment);
    if (now.difference(moment).inDays < 2) return 'hier';
    return DateFormat('d MMM', 'fr_FR').format(moment);
  }
}

/// La troisième ligne : l'état, et la progression quand elle a un sens.
class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.entry, required this.color});

  final ActivityEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // La note **ou** la jauge, jamais les deux : à elles deux elles ne
    // tiennent pas sur la ligne, et le libellé se faisait tronquer en
    // « En attente — Le comm… ». Une attente se dit en mots, une progression
    // se montre — chacune à son tour.
    final note = entry.statusNote;
    final showProgress = note == null && !entry.isSettled && entry.step > 0;

    return Row(
      children: [
        Icon(entry.statusIcon, size: 14, color: color),
        AppDimens.spacerMiniWidth,
        Flexible(
          child: Text(
            note == null ? entry.statusLabel : '${entry.statusLabel} — $note',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (showProgress) ...[
          AppDimens.spacerSmallWidth,
          Expanded(
            child: _Progress(value: entry.step / entry.stepCount, color: color),
          ),
        ],
      ],
    );
  }
}

/// Une jauge de deux pixels : elle dit « ça avance » sans occuper de place.
class _Progress extends StatelessWidget {
  const _Progress({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final rest = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.12);

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Row(
        children: [
          Expanded(
            flex: (value * 100).round().clamp(1, 99),
            child: ColoredBox(color: color, child: const SizedBox(height: 2)),
          ),
          Expanded(
            flex: 100 - (value * 100).round().clamp(1, 99),
            child: ColoredBox(color: rest, child: const SizedBox(height: 2)),
          ),
        ],
      ),
    );
  }
}
