// File: core/constants/injector.dart

import 'package:baobabe_0_2/core/constants/supabase_client.dart';
import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource.dart';
import 'package:baobabe_0_2/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/check_auth_status_use_case.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/login_usecase.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/logout_usecase.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/signup_usecase.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/home_page/data/data_sources/remote_datasource/business_remote_datasource.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/category_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/search_repository_impl.dart';
import 'package:baobabe_0_2/features/favorites_page/data/models/reservation_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/business_repository.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/category_repository.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/search_repository.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_by_category_use_case.dart';
import 'package:baobabe_0_2/features/main/presentation/bloc/main_screen_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_bloc.dart';
import 'package:baobabe_0_2/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

final getIt = GetIt.instance;

class Injector {
  static void setup() {
    _registerDataSources();
    _registerRepositories();
    _registerUseCases();
    _registerBlocs();
  }

  static void _registerDataSources() {
    final supabase = SupabaseClientWrapper.client;
    getIt.registerLazySingleton<SupabaseClient>(() => supabase);

    getIt.registerLazySingleton<AuthRemoteDataSource>(
          () => AuthRemoteDataSourceImpl(supabase: getIt<SupabaseClient>()),
    );

    getIt.registerLazySingleton<BusinessRemoteDataSource>(
          () => BusinessRemoteDataSourceImpl(supabase: getIt<SupabaseClient>()),
    );

    getIt.registerLazySingleton<ReservationApiService>(
          () => ReservationApiService(getIt<SupabaseClient>()),
    );
  }

  static void _registerRepositories() {
    getIt.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>(),),
    );

    getIt.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl());

    getIt.registerLazySingleton<BusinessRepository>(
          () => BusinessRepositoryImpl(remoteDataSource: getIt<BusinessRemoteDataSource>()),
    );

    getIt.registerLazySingleton<SearchRepository>(
          () => SearchRepositoryImpl(localDataSource: getIt<BusinessRemoteDataSource>()),
    );
  }

  static void _registerUseCases() {
    getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => SignUpUseCase(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => CheckAuthStatusUseCase(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));

    getIt.registerLazySingleton(() => GetBusinesses(getIt<BusinessRepository>()));
    getIt.registerLazySingleton(() => GetBusinessesByCategory(getIt<BusinessRepository>()));
  }

  static void _registerBlocs() {
    getIt.registerFactory(() => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      signUpUseCase: getIt<SignUpUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      checkAuthStatusUseCase: getIt<CheckAuthStatusUseCase>(),
    ));
    getIt.registerFactory<MainScreenBloc>(() => MainScreenBloc());
    getIt.registerFactory<SettingsCubit>(() => SettingsCubit());

    getIt.registerFactory<CategoryBloc>(() => CategoryBloc(categoryRepository: getIt<CategoryRepository>()));

    getIt.registerFactory<BusinessBloc>(
          () => BusinessBloc(
        getBusinesses: getIt<GetBusinesses>(),
        getBusinessesByCategory: getIt<GetBusinessesByCategory>(),
      ),
    );

    getIt.registerFactory<SearchBloc>(() => SearchBloc(searchRepository: getIt<SearchRepository>()));
  }

  static T get<T extends Object>() {
    return getIt<T>();
  }
}