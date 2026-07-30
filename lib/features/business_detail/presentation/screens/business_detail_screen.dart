import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/business_detail/domain/usecases/get_business_detail.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_actions_section.dart';
// removed unused import: business_hero_section
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_info_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_specific_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/common/business_detail_app_bar.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/common/responsive_container.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/review.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BusinessDetailScreen extends StatefulWidget {
  final String businessId;

  const BusinessDetailScreen({super.key, required this.businessId});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BusinessDetailBloc>(
      create: (context) {
        final repository = BusinessRepositoryImpl(
          remoteDataSource: BusinessRemoteDataSourceImpl(),
        );
        return BusinessDetailBloc(
          getBusinessDetail: GetBusinessDetail(repository),
          repository: repository,
          businessId: widget.businessId,
        )..add(LoadBusinessDetail(widget.businessId));
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<BusinessDetailBloc, BusinessDetailState>(
          listener: (context, state) {
            // Gestion des retours visuels (Toasts / SnackBars) pour les réservations
            if (state.reservationStatus == ReservationStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Réservation effectuée avec succès ! 🎉'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state.reservationStatus == ReservationStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.reservationErrorMessage ?? 'Échec de la réservation.',
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return _buildContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BusinessDetailState state) {
    // 1. ÉTAT CHARGEMENT INITIAL OU INITIALISATION
    if (state.detailStatus == BusinessDetailStatus.loading ||
        state.detailStatus == BusinessDetailStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // 2. ÉTAT ERREUR DE CHARGEMENT DES DÉTAILS
    if (state.detailStatus == BusinessDetailStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.detailErrorMessage ??
                    "Impossible de charger les détails.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<BusinessDetailBloc>().add(
                    LoadBusinessDetail(widget.businessId),
                  );
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. ÉTAT CHARGÉ (Détails du commerce disponibles)
    if (state.detailStatus == BusinessDetailStatus.loaded &&
        state.business != null) {
      final business = state.business!;
      final uiBusiness = UIBusiness(business);

      return Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              BusinessDetailAppBar(
                business: business,
                uiBusiness: uiBusiness,
                scrollController: _scrollController,
              ),
              SliverToBoxAdapter(
                child: ResponsiveContainer(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      BusinessInfoSection(business: business),
                      const SizedBox(height: 24),
                      BusinessSpecificSection(business: business),
                      const SizedBox(height: 24),
                      BusinessActionSection(business: business),
                      const SizedBox(height: 24),
                      RestaurantReview(business: business),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Indicateur de chargement en surimpression (Overlay) pendant qu'une réservation est envoyée
          if (state.reservationStatus == ReservationStatus.loading)
            Container(
              color: AppColors.textPrimary.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
