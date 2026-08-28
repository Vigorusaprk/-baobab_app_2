import 'package:baobabe_0_2/core/bloc/settings_bloc.dart';
import 'package:baobabe_0_2/core/constants/supabase_client.dart';
import 'package:baobabe_0_2/core/routes/app_router.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_session_cubit.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/category_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/search_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_offers_page.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_home_feed.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_bloc.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/bloc/settings_bloc.dart'
    as theme_settings;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    // The Supabase session is already resolved synchronously by the time
    // runApp() is called, so the splash screen can be released right away.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final businessRemoteDataSource = BusinessRemoteDataSourceImpl(
      supabase: SupabaseClientWrapper.client,
    );
    final businessRepository = BusinessRepositoryImpl(
      remoteDataSource: businessRemoteDataSource,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            authRepository: AuthRepositoryImpl(
              AuthRemoteDataSourceImpl(SupabaseClientWrapper.client),
            ),
          ),
        ),
        BlocProvider<AuthSessionCubit>(create: (_) => AuthSessionCubit()),
        BlocProvider<CategoryBloc>(
          create: (_) =>
              CategoryBloc(categoryRepository: CategoryRepositoryImpl()),
        ),
        BlocProvider<BusinessBloc>(
          create: (_) => BusinessBloc(
            getHomeFeed: GetHomeFeed(businessRepository),
            getOffersPage: GetOffersPage(businessRepository),
          ),
        ),
        BlocProvider<SearchBloc>(
          create: (_) => SearchBloc(
            searchRepository: SearchRepositoryImpl(
              localDataSource: businessRemoteDataSource,
            ),
          ),
        ),
        // Au niveau de l'application : la réponse « cet utilisateur est-il
        // commerçant ? » conditionne l'écran d'ouverture et le contenu des
        // paramètres, qui ne peuvent pas chacun refaire l'appel.
        BlocProvider<MerchantCubit>(create: (_) => MerchantCubit()),
        BlocProvider<SettingsCubit>(create: (_) => SettingsCubit()),
        BlocProvider<theme_settings.SettingsCubit>(
          create: (_) => theme_settings.SettingsCubit(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: AppTheme.silvaTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
          Locale('ln', 'CD'),
        ],
      ),
    );
  }
}
