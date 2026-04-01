import 'package:baobabe_0_2/features/auth/data/data_sources/remote_datasource/auth_remote_datasource.dart';
import 'package:baobabe_0_2/features/auth/data/repositories/auth_repository_impl.dart'; // ✅ bon chemin
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/check_auth_status_use_case.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/login_usecase.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/logout_usecase.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/signup_usecase.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/auth_interceptor.dart';
import 'package:baobabe_0_2/features/business_detail/domain/usecases/get_business_detail.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/home_page/data/data_sources/remote_datasource/business_remote_datasource.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/category_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/search_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/business_repository.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/category_repository.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/search_repository.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_by_category_use_case.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/toggle_favorite.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_bloc.dart';
import 'package:baobabe_0_2/features/main/presentation/bloc/main_screen_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class Injector {
  static void setup() {
    _registerDataSources();
    _registerRepositories();
    _registerUseCases();
    _registerBlocs();
  }

  static void _registerDataSources() {
    // Dio doit être enregistré en premier
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    dio.interceptors.add(AuthInterceptor());
    getIt.registerLazySingleton<Dio>(() => dio);
    // Ensuite les autres data sources
    getIt.registerLazySingleton<BusinessRemoteDataSource>(
          () => BusinessRemoteDataSourceImpl(),
    );
    getIt.registerLazySingleton<AuthRemoteDataSource>(
          () => AuthRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }

  static void _registerRepositories() {
    // Auth Repository – **CORRECTION** : fournir remoteDataSource
    getIt.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
      ),
    );

    // Business Repository
    getIt.registerLazySingleton<BusinessRepository>(
          () => BusinessRepositoryImpl(
        remoteDataSource: getIt<BusinessRemoteDataSource>(),
      ),
    );

    // Category Repository
    getIt.registerLazySingleton<CategoryRepository>(
          () => CategoryRepositoryImpl(),
    );

    // Search Repository
    getIt.registerLazySingleton<SearchRepository>(
          () => SearchRepositoryImpl(localDataSource: getIt()),
    );
  }

  static void _registerUseCases() {
    // Auth Use Cases
    getIt.registerLazySingleton<LoginUseCase>(
          () => LoginUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<SignUpUseCase>(
          () => SignUpUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<LogoutUseCase>(
          () => LogoutUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<CheckAuthStatusUseCase>(
          () => CheckAuthStatusUseCase(getIt<AuthRepository>()),
    );

    // Business Use Cases
    getIt.registerLazySingleton<GetBusinesses>(
          () => GetBusinesses(getIt<BusinessRepository>()),
    );
    getIt.registerLazySingleton<GetBusinessesByCategory>(
          () => GetBusinessesByCategory(getIt<BusinessRepository>()),
    );
    getIt.registerLazySingleton<GetBusinessDetail>(
          () => GetBusinessDetail(getIt<BusinessRepository>()),
    );
    getIt.registerLazySingleton<ToggleFavorite>(
          () => ToggleFavorite(getIt<BusinessRepository>()),
    );
  }

  static void _registerBlocs() {
    // Auth Bloc
    getIt.registerFactory<AuthBloc>(
          () => AuthBloc(
        authRepository: getIt<AuthRepository>(),
      ),
    );

    // Business Bloc
    getIt.registerFactory<BusinessBloc>(
          () => BusinessBloc(
        getBusinesses: getIt<GetBusinesses>(),
        getBusinessesByCategory: getIt<GetBusinessesByCategory>(),
      ),
    );

    // Category Bloc
    getIt.registerFactory<CategoryBloc>(
          () => CategoryBloc(
        categoryRepository: getIt<CategoryRepository>(),
      ),
    );

    // Search Bloc
    getIt.registerFactory<SearchBloc>(
          () => SearchBloc(
        searchRepository: getIt<SearchRepository>(),
      ),
    );

    // Business Detail Bloc
    getIt.registerFactory(
          () => BusinessDetailBloc(
        getBusinessDetail: getIt<GetBusinessDetail>(),
        repository: getIt<BusinessRepository>(),
        businessId: '', // sera remplacé lors de l'utilisation
      ),
    );

    // Main Screen Bloc
    getIt.registerFactory<MainScreenBloc>(
          () => MainScreenBloc(),
    );
  }

  static T get<T extends Object>() {
    return getIt<T>();
  }
}