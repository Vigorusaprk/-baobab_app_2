import 'package:baobabe_0_2/core/constants/injector.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/Category_Icons.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/HelloUserWidget.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/Location_and_Profile.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_cards_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => Injector.get<BusinessBloc>()..add(LoadBusinesses()),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.silvaTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header section (Location, Profile, Greeting, Categories)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.PADDING_16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LocationAndProfile(),
                      const SizedBox(height: AppDimens.PADDING_20),
                      const HelloUserWidget(),
                      const SizedBox(height: AppDimens.PADDING_20),
                      const CategoryIcons(),
                      const SizedBox(height: AppDimens.PADDING_30),
                    ],
                  ),
                ),
              ),

              // Business cards section
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    left: AppDimens.PADDING_16,
                    right: AppDimens.PADDING_16,
                    bottom: AppDimens.PADDING_20,
                  ),
                  child: const BusinessCardsWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}