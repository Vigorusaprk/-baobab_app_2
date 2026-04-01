import 'package:baobabe_0_2/core/constants/injector.dart';
import 'package:baobabe_0_2/features/business_detail/domain/usecases/get_business_detail.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_actions_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_comments_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_hero_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_info_section.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_specific_section.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_colors.dart';
import '../bloc/business_detail_bloc.dart';
import '../widgets/common/business_detail_app_bar.dart';
import '../widgets/common/responsive_container.dart';
// ✅ Import du repository
import 'package:baobabe_0_2/features/home_page/domain/repositories/business_repository.dart';

class BusinessDetailScreen extends StatelessWidget {
  final String businessId;

  const BusinessDetailScreen({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BusinessDetailBloc(
        getBusinessDetail: Injector.get<GetBusinessDetail>(),
        repository: Injector.get<BusinessRepository>(), // ✅ Ajout
        businessId: businessId,
      )..add(LoadBusinessDetail(businessId)),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: BlocBuilder<BusinessDetailBloc, BusinessDetailState>(
          builder: (context, state) {
            return _buildContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BusinessDetailState state) {
    if (state is BusinessDetailLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BusinessDetailError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<BusinessDetailBloc>().add(LoadBusinessDetail(businessId));
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is BusinessDetailLoaded) {
      final uiBusiness = UIBusiness(state.business);

      return CustomScrollView(
        slivers: [
          BusinessDetailAppBar(business: state.business, uiBusiness: uiBusiness),
          SliverToBoxAdapter(
            child: ResponsiveContainer(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  BusinessHeroSection(uiBusiness: uiBusiness),
                  const SizedBox(height: 24),
                  BusinessInfoSection(business: state.business),
                  const SizedBox(height: 24),
                  BusinessSpecificSection(business: state.business),
                  const SizedBox(height: 24),
                  BusinessActionSection(business: state.business), // ✅ inchangé
                  const SizedBox(height: 24),
                  BusinessCommentsSection(business: state.business),
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