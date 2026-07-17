import 'package:baobabe_0_2/core/constants/supabase_client.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_service.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/category_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/search_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_by_category_use_case.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/main/presentation/bloc/main_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/routes/app_router.dart';
import 'core/services/sync_service.dart';
import 'features/home_page/presentation/bloc/search_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

/// Kept alive for the app lifetime so its connectivity listener keeps running.
late final SyncManager _syncManager;

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SupabaseClientWrapper.initialize();

  final reservationApiService = ReservationApiService(SupabaseClientWrapper.client);
  _syncManager = SyncManager(SyncService(reservationApiService), reservationApiService);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
        BlocProvider<CategoryBloc>(
          create: (_) => CategoryBloc(categoryRepository: CategoryRepositoryImpl()),
        ),
        BlocProvider<BusinessBloc>(
          create: (_) => BusinessBloc(
            getBusinesses: GetBusinesses(businessRepository),
            getBusinessesByCategory: GetBusinessesByCategory(businessRepository),
          ),
        ),
        BlocProvider<MainScreenBloc>(create: (_) => MainScreenBloc()),
        BlocProvider<SearchBloc>(
          create: (_) => SearchBloc(
            searchRepository: SearchRepositoryImpl(
              localDataSource: businessRemoteDataSource,
            ),
          ),
        ),
        BlocProvider<SettingsCubit>(create: (_) => SettingsCubit()),
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
