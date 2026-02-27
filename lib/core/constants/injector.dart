// File: core/constants/injector.dart
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:baobabe_0_2/features/business_detail/domain/usecases/get_business_detail.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/category_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/business_repository.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/category_repository.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_by_category_use_case.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/toggle_favorite.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:get_it/get_it.dart';

// Domain - Entities


// Domain - Repositories Interfaces
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';


// Domain - Use Cases
import 'package:baobabe_0_2/features/auth/domain/usecases/login_usecase.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/signup_usecase.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/logout_usecase.dart';
import 'package:baobabe_0_2/features/auth/domain/usecases/check_auth_status_use_case.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses.dart';

// Data - Repository Implementations

// Data - Data Sources
import 'package:baobabe_0_2/features/home_page/data/data_sources/local_datasource/local_business_data.dart';
import 'package:baobabe_0_2/features/home_page/data/data_sources/remote_datasource/business_remote_datasource.dart';

// Presentation - Blocs
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:baobabe_0_2/features/main/presentation/bloc/main_screen_bloc.dart';

final getIt = GetIt.instance;

class Injector {
  static void setup() {
    _registerDataSources();
    _registerRepositories();
    _registerUseCases();
    _registerBlocs();
  }

  static void _registerDataSources() {
    // Business Data Sources
    getIt.registerLazySingleton<BusinessLocalDataSource>(
          () => BusinessLocalDataSourceImpl(),
    );

    // Supprimer la ligne commentée et la remplacer par :
    getIt.registerLazySingleton<BusinessRemoteDataSource>(
          () => BusinessRemoteDataSourceImpl(),
    );
  }

  static void _registerRepositories() {
    // Auth Repository
    getIt.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(),
    );

    // Business Repository
    getIt.registerLazySingleton<BusinessRepository>(
          () => BusinessRepositoryImpl(
        localDataSource: getIt<BusinessLocalDataSource>(),
        remoteDataSource: getIt<BusinessRemoteDataSource>(),
      ),
    );

    // Category Repository
    getIt.registerLazySingleton<CategoryRepository>(
          () => CategoryRepositoryImpl(),
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
    // Auth Bloc - CORRECTION : utiliser uniquement authRepository comme paramètre
    getIt.registerFactory<AuthBloc>(
          () => AuthBloc(
        authRepository: getIt<AuthRepository>(), // Correction ici
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

    // Business Detail Bloc
    getIt.registerFactoryParam<BusinessDetailBloc, String, void>(
          (businessId, _) => BusinessDetailBloc(
        getBusinessDetail: getIt<GetBusinessDetail>(),
        businessId: businessId,
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