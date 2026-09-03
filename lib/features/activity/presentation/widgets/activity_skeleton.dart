import 'dart:math' as math;

import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Le squelette du flux d'activité.
///
/// Il imitait deux cartes très ornées — encadré d'icône, pastilles, pied de
/// total — parce que l'écran affichait des cartes. Le flux étant fait de
/// lignes, le squelette est fait de lignes : même en-tête, mêmes repères de
/// temps, même filet de gauche, mêmes trois lignes de texte.
///
/// C'est la règle du projet : un squelette d'une autre forme que son contenu
/// fait sauter la page au moment où les données arrivent. La forme, c'est
/// aussi la quantité — quatre lignes en haut d'un écran vide laissaient un
/// grand blanc en dessous, qui se remplissait d'un coup à l'arrivée des
/// données. Le nombre de lignes est donc **déduit de la hauteur
/// disponible**, et dépasse volontairement d'une ligne : un flux qui
/// s'arrête pile au bas de l'écran a l'air fini, alors qu'il charge.
class ActivityFlowSkeleton extends StatelessWidget {
  const ActivityFlowSkeleton({super.key});

  /// Hauteur d'une ligne, mesurée sur une vraie : deux fois le padding
  /// vertical, trois lignes de texte, le filet.
  static const double _rowHeight = 78;

  /// Ce qu'un repère de temps occupe, son espacement compris.
  static const double _groupHeader = 34;

  /// Les largeurs des barres, en fractions. Égales, elles donneraient une
  /// grille trop régulière pour passer pour du texte.
  static const List<(double, double, double?)> _variants = [
    (0.66, 0.82, 0.44),
    (0.58, 0.76, 0.50),
    (0.71, 0.64, null),
    (0.62, 0.70, 0.38),
    (0.54, 0.66, null),
    (0.68, 0.79, 0.47),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Skeletonizer(
      enabled: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : _rowHeight * 5;
          final rows = math.max(
            4,
            ((height - _groupHeader) / _rowHeight).ceil() + 1,
          );

          final children = <Widget>[AppDimens.spacerSmall];
          var remaining = rows;
          var group = 0;
          while (remaining > 0) {
            children
              ..add(
                Bone.text(
                  width: group.isEven ? 74 : 96,
                  style: theme.textTheme.labelSmall!,
                ),
              )
              ..add(AppDimens.spacerSmall);
            // Le premier groupe est court — « Aujourd'hui » l'est presque
            // toujours — les suivants plus fournis.
            final count = math.min(remaining, group == 0 ? 2 : 3);
            for (var i = 0; i < count; i++) {
              final (name, summary, status) =
                  _variants[(group * 3 + i) % _variants.length];
              children.add(
                _Row(
                  nameWidth: name,
                  summaryWidth: summary,
                  statusWidth: status,
                ),
              );
            }
            children.add(AppDimens.spacerLarge);
            remaining -= count;
            group++;
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.appPaddingValue,
            ),
            // Le squelette dépasse d'une ligne : sans cela le dernier filet
            // s'arrêterait net au bas de l'écran.
            physics: const NeverScrollableScrollPhysics(),
            children: children,
          );
        },
      ),
    );
  }
}

/// Une ligne du squelette, aux proportions d'une vraie ligne.
class _Row extends StatelessWidget {
  const _Row({
    required this.nameWidth,
    required this.summaryWidth,
    this.statusWidth,
  });

  /// Fractions de la largeur disponible : en pixels fixes, les barres
  /// paraîtraient tassées sur un grand écran et déborderaient sur un petit.
  final double nameWidth;
  final double summaryWidth;
  final double? statusWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - AppDimens.medium - 2;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.small + 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 0.7,
              ),
            ),
          ),
          // Pas de `stretch` : le filet a sa hauteur, et une rangée qui
          // s'étire réclame à la liste une hauteur qu'elle ne borne pas.
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Bone(width: 2, height: 52),
              AppDimens.spacerMediumWidth,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(
                      width: width * nameWidth,
                      style: theme.textTheme.titleSmall!,
                    ),
                    AppDimens.spacerMini,
                    Bone.text(
                      width: width * summaryWidth,
                      style: theme.textTheme.bodySmall!,
                    ),
                    AppDimens.spacerMini,
                    if (statusWidth != null)
                      Bone.text(
                        width: width * statusWidth!,
                        style: theme.textTheme.labelSmall!,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
