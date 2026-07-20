import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_by_category_use_case.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/Category_Icons.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/HelloUserWidget.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/Location_and_Profile.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_cards_widget.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_promo_carousel.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/popular_businesses_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../main/presentation/widgets/app_background.dart';

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
        backgroundColor: AppColors.scaffoldBackground,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header section (Location, Profile, Greeting, Categories)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.PADDING_40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimens.PADDING_20),
                    const HelloUserWidget(),
                    const SizedBox(height: AppDimens.PADDING_20),
                    //const CategoryIcons(),
                    const SizedBox(height: AppDimens.PADDING_30),
                    const BusinessPromoCarousel(),
                    const SizedBox(height: AppDimens.PADDING_30),
                    const PopularBusinessesSection(
                      maxItems: 5,
                      // onSeeAllTap: () => context.push('/popular'),
                    ),
                    const SizedBox(height: AppDimens.PADDING_30),
                    const BusinessCardsWidget(),
                    const SizedBox(height: AppDimens.PADDING_40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}