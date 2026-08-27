import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Marges partagées entre la liste d'offres et son squelette, pour qu'ils
/// se superposent exactement au moment du basculement.
const EdgeInsets offerListPadding = EdgeInsets.fromLTRB(
  AppDimens.large,
  AppDimens.medium,
  AppDimens.large,
  120,
);

/// Squelette du catalogue pendant son chargement.
class OfferCatalogueSkeleton extends StatelessWidget {
  const OfferCatalogueSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: offerListPadding,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, _) => const OfferTileSkeleton(),
      ),
    );
  }
}

/// État plein écran du catalogue : vide, ou en erreur avec une reprise.
class OfferCatalogueMessage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const OfferCatalogueMessage({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppDimens.appPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: color),
            AppDimens.spacerMedium,
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            if (actionLabel != null) ...[
              AppDimens.spacerMedium,
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Choix de la date et de l'heure, affiché uniquement quand aucune offre
/// sélectionnée n'impose la sienne (une séance ou un concert ont déjà la
/// leur ; une table, une chambre ou un soin non).
class OfferDatePicker extends StatelessWidget {
  final DateTime? date;
  final ValueChanged<DateTime> onPicked;

  const OfferDatePicker({super.key, required this.date, required this.onPicked});

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (day == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
    );
    if (!context.mounted) return;

    onPicked(
      DateTime(day.year, day.month, day.day, time?.hour ?? 12, time?.minute ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimens.allPadding12,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppDimens.cardBorderRadiusAll,
      ),
      child: Row(
        children: [
          const Icon(Icons.event_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              date == null
                  ? "Choisir la date et l'heure"
                  : DateFormat('dd/MM/yyyy à HH:mm').format(date!),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () => _pick(context),
            child: Text(date == null ? 'Choisir' : 'Modifier'),
          ),
        ],
      ),
    );
  }
}
