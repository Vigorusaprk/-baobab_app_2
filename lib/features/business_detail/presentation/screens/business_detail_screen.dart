import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/business_detail/domain/usecases/get_business_detail.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_contact_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_hours_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_info_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_offers_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_specific_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_detail_skeleton.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/common/business_detail_app_bar.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/common/responsive_container.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/review.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
        )..add(LoadBusinessDetail(widget.businessId));
      },
      child: BlocBuilder<BusinessDetailBloc, BusinessDetailState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: _buildContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, BusinessDetailState state) {
    // 1. ÉTAT CHARGEMENT INITIAL OU INITIALISATION
    if (state.detailStatus == BusinessDetailStatus.loading ||
        state.detailStatus == BusinessDetailStatus.initial) {
      return const Skeletonizer(
        enabled: true,
        child: BusinessDetailSkeleton(),
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
                style: const TextStyle(color: AppColors.errorContent, fontSize: 16),
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

      return CustomScrollView(
        controller: _scrollController,
        slivers: [
          BusinessDetailAppBar(
            business: business,
            uiBusiness: uiBusiness,
            scrollController: _scrollController,
          ),
          SliverToBoxAdapter(
            child: ResponsiveContainer(
              // L'ordre suit les questions de l'utilisateur : qu'est-ce que
              // c'est, qu'est-ce qu'on y trouve, comment les joindre, quand
              // ils ouvrent, ce qu'on en dit.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  BusinessAboutSection(business: business),
                  const SizedBox(height: 24),
                  BusinessOffersSection(businessId: business.id),
                  const BusinessSectionTitle('Contact & Accès'),
                  BusinessContactSection(business: business),
                  const SizedBox(height: 24),
                  if (business.openingHours.isNotEmpty) ...[
                    const BusinessSectionTitle("Horaires d'ouverture"),
                    BusinessHoursSection(business: business),
                    const SizedBox(height: 24),
                  ],
                  BusinessSpecificSection(business: business),
                  const SizedBox(height: 24),
                  RestaurantReview(business: business),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
