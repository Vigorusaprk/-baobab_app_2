import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/offer_detail_cubit.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_detail_sections.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_purchase_bar.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/review_list_item.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offers_carousel_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// La fiche d'une offre.
///
/// C'est désormais la destination d'un clic sur une offre, où qu'elle
/// apparaisse : sur l'accueil, dans la recherche, ou dans le catalogue d'un
/// commerçant. On y décide, et on y commande ou réserve — la fiche du
/// commerçant, elle, ne porte plus de bouton d'action.
class OfferDetailScreen extends StatelessWidget {
  final String offerId;

  const OfferDetailScreen({super.key, required this.offerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OfferDetailCubit(offerId: offerId)..load(),
      child: const _OfferDetailView(),
    );
  }
}

class _OfferDetailView extends StatelessWidget {
  const _OfferDetailView();

  Future<void> _pickDate(BuildContext context) async {
    final cubit = context.read<OfferDetailCubit>();
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (!context.mounted) return;

    cubit.setDate(
      DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 12,
        time?.minute ?? 0,
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final cubit = context.read<OfferDetailCubit>();
    final state = cubit.state;
    if (state is! OfferDetailLoaded) return;

    if (state.isDateMissing) {
      _notify(context, 'Choisissez d\'abord une date.');
      return;
    }

    final error = await cubit.submit();
    if (!context.mounted) return;

    if (error == 'Connectez-vous pour continuer.') {
      showAuthRequiredCard(
        context,
        message: 'Connectez-vous pour finaliser votre demande.',
      );
      return;
    }

    _notify(
      context,
      error ??
          (state.detail.offer.isOrderable
              ? 'Commande envoyée. Suivez-la dans Mes activités.'
              : 'Demande envoyée. Le commerçant doit la confirmer.'),
      isError: error != null,
    );
  }

  void _notify(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Détail de l\'offre'),
      ),
      body: BlocBuilder<OfferDetailCubit, OfferDetailState>(
        builder: (context, state) {
          if (state is OfferDetailError) {
            return _Failure(message: state.message);
          }
          if (state is! OfferDetailLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return _Content(state: state);
        },
      ),
      bottomNavigationBar: BlocBuilder<OfferDetailCubit, OfferDetailState>(
        builder: (context, state) {
          if (state is! OfferDetailLoaded) return const SizedBox.shrink();
          return OfferPurchaseBar(
            state: state,
            onQuantityChanged: context.read<OfferDetailCubit>().setQuantity,
            onPickDate: () => _pickDate(context),
            onSubmit: () => _submit(context),
          );
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final OfferDetailLoaded state;

  const _Content({required this.state});

  @override
  Widget build(BuildContext context) {
    final detail = state.detail;
    final offer = detail.offer;
    final merchant = detail.merchant;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        OfferDetailHeader(offer: offer),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.appPaddingValue,
            AppDimens.appPaddingValue,
            AppDimens.appPaddingValue,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(offer.name, style: Theme.of(context).textTheme.titleMedium),
              AppDimens.spacerSmall,
              Row(
                children: [
                  Text(
                    offer.isFree
                        ? 'Sur demande'
                        : '${offer.price.toStringAsFixed(2)} \$',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  if (offer.reviewCount > 0) ...[
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Colors.amber,
                    ),
                    Text(
                      '${offer.rating.toStringAsFixed(1)} '
                      '(${offer.reviewCount})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              if (offer.description.isNotEmpty) ...[
                AppDimens.spacerMedium,
                Text(
                  offer.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
              AppDimens.spacerMedium,
              OfferFacts(detail: detail),
              if (merchant != null) ...[
                AppDimens.spacerSmall,
                Text(
                  'Proposé par',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppDimens.spacerSmall,
                OfferMerchantCard(merchant: merchant),
              ],
              if (detail.reviews.isNotEmpty) ...[
                AppDimens.spacerLarge,
                Text('Avis', style: Theme.of(context).textTheme.titleMedium),
                AppDimens.spacerSmall,
                for (final review in detail.reviews)
                  ReviewListItem(review: review),
              ],
            ],
          ),
        ),
        if (detail.otherOffers.isNotEmpty) ...[
          AppDimens.spacerLarge,
          OffersCarouselSection(
            title: 'Chez le même commerçant',
            offers: detail.otherOffers,
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Failure extends StatelessWidget {
  final String message;

  const _Failure({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
            AppDimens.spacerMedium,
            ElevatedButton(
              onPressed: () => context.read<OfferDetailCubit>().load(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
