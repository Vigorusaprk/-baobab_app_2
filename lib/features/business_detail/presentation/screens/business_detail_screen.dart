import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_contact_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_cover.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_detail_skeleton.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_hours_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_identity.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_info_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_offer_board.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_specific_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/common/responsive_container.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/review.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// La fiche d'un commerce.
///
/// **La photo, qui c'est, ce qu'on peut en faire.** C'était : une barre
/// pliante de 350 px qui remplaçait la photo par un dégradé, puis « À
/// propos », puis le catalogue en carrousels, puis contact, horaires,
/// commodités, avis. Le catalogue — la seule raison d'être de la page —
/// arrivait en troisième, caché dans des carrousels qui coupent ce qui
/// dépasse.
///
/// Il arrive maintenant juste après l'identité, en colonne, filtré par ce
/// qu'on peut en faire : commander, réserver, ou passer le prendre. Le reste
/// — la présentation, les horaires, les commodités, les avis — suit, parce
/// qu'on le lit après avoir vu ce qui est proposé, jamais avant.
class BusinessDetailScreen extends StatefulWidget {
  final String businessId;

  const BusinessDetailScreen({super.key, required this.businessId});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<BusinessDetailBloc>(
      create: (_) =>
          BusinessDetailBloc()..add(LoadBusinessDetail(widget.businessId)),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<BusinessDetailBloc, BusinessDetailState>(
          builder: (context, state) => _content(context, state),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, BusinessDetailState state) {
    switch (state.detailStatus) {
      case BusinessDetailStatus.initial:
      case BusinessDetailStatus.loading:
        return const Skeletonizer(
          enabled: true,
          child: BusinessDetailSkeleton(),
        );
      case BusinessDetailStatus.error:
        return _Failure(
          message:
              state.detailErrorMessage ?? 'Impossible de charger les détails.',
          onRetry: () => context.read<BusinessDetailBloc>().add(
            LoadBusinessDetail(widget.businessId),
          ),
        );
      case BusinessDetailStatus.loaded:
        break;
    }

    final business = state.business;
    if (business == null) return const SizedBox.shrink();
    final uiBusiness = UIBusiness(business);
    final rated = state.offers.where((o) => o.reviewCount > 0).length;

    return CustomRefresh(
      onRefresh: () {
        final bloc = context.read<BusinessDetailBloc>();
        bloc.add(LoadBusinessDetail(widget.businessId));
        return awaitSettled<BusinessDetailState>(
          bloc.stream,
          (s) => s.detailStatus != BusinessDetailStatus.loading,
        );
      },
      child: CustomScrollView(
        slivers: [
          // Rend une barre épinglée : la photo défile, mais le bandeau reste
          // pour que le contenu ne se peigne pas sous l'heure du système.
          BusinessCover(business: business, uiBusiness: uiBusiness),
          SliverToBoxAdapter(
            child: BusinessIdentity(
              business: business,
              uiBusiness: uiBusiness,
              ratedOffers: rated,
            ),
          ),
          // Rend un sliver : c'est ce qui épingle son filtre.
          BusinessOfferBoard(offers: state.offers),
          SliverToBoxAdapter(
            child: ResponsiveContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppDimens.spacerLarge,
                  BusinessAboutSection(business: business),
                  if (business.openingHours.isNotEmpty) ...[
                    AppDimens.spacerLarge,
                    const BusinessSectionTitle("Horaires d'ouverture"),
                    BusinessHoursSection(business: business),
                  ],
                  // Le téléphone est déjà un bouton là-haut : cette carte ne
                  // porte plus que ce qu'il ne couvre pas.
                  if (business.email != null || business.website != null) ...[
                    AppDimens.spacerLarge,
                    const BusinessSectionTitle('Contact'),
                    BusinessContactSection(
                      business: business,
                      showPhone: false,
                    ),
                  ],
                  AppDimens.spacerLarge,
                  BusinessSpecificSection(business: business),
                  AppDimens.spacerLarge,
                  RestaurantReview(business: business),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            AppDimens.spacerMedium,
            CustomActionButton(
              label: 'Réessayer',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
