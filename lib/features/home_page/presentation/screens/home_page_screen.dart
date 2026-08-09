import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_page.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/Category_Icons.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_cards_widget.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_promo_carousel.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_search_bar.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_skeleton.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/popular_businesses_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Body-only content for the Home tab. The Scaffold and AppBar (HomeAppBar)
/// are owned by MainShell, which is the single Scaffold for the app's main
/// navigation.
class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final repository = BusinessRepositoryImpl(
              remoteDataSource: BusinessRemoteDataSourceImpl(),
            );
            return BusinessBloc(
              getBusinessesPage: GetBusinessesPage(repository),
            )..add(LoadBusinesses());
          },
        ),
      ],
      child: BlocBuilder<BusinessBloc, BusinessState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        builder: (context, state) {
          final isLoading = state is BusinessInitial || state is BusinessLoading;

          return Skeletonizer(
            enabled: isLoading,
            child: SingleChildScrollView(
              physics: isLoading
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              child: isLoading
                  ? const HomeSkeleton()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppDimens.spacerSmall,
                        HomeSearchBar(),
                        AppDimens.spacerSmall,
                        const CategoryIcons(),
                        AppDimens.spacerSmall,
                        const BusinessPromoCarousel(),
                        AppDimens.spacerSmall,
                        const PopularBusinessesSection(
                          maxItems: 5,
                          // onSeeAllTap: () => context.push('/popular'),
                        ),
                        AppDimens.spacerSmall,
                        const BusinessCardsWidget(),
                        const SizedBox(height: 100),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
