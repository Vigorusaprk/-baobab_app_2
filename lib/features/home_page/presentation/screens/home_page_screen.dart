import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_by_category_use_case.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_cards_widget.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_promo_carousel.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_app_bar.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_search_bar.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/popular_businesses_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
              getBusinesses: GetBusinesses(repository),
              getBusinessesByCategory: GetBusinessesByCategory(repository),
            )..add(LoadBusinesses());
          },
        ),
      ],
      child: Scaffold(
        appBar: HomeAppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDimens.spacerSmall,
              HomeSearchBar(),
              AppDimens.spacerSmall,
              //const CategoryIcons(),
              //AppDimens.spacerSmall,
              const BusinessPromoCarousel(),
              AppDimens.spacerSmall,
              const PopularBusinessesSection(
                maxItems: 5,
                // onSeeAllTap: () => context.push('/popular'),
              ),
              AppDimens.spacerSmall,
              const BusinessCardsWidget(),
              AppDimens.spacerSmall,
            ],
          ),
        ),
      ),
    );
  }
}
