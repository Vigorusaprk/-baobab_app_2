import 'package:baobabe_0_2/core/constants/injector.dart';
import 'package:baobabe_0_2/core/constants/supabase_client.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_event.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/business_detail_bloc.dart';
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

void main() async {
  // Initialisation unique et propre des liaisons Flutter
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialisation asynchrone des configurations globales[cite: 4]
  await SupabaseClientWrapper.initialize();
  Injector.setup();

  // Démarrer le SyncManager pour écouter la connectivité
  Injector.get<SyncManager>();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ⚡ Déclenchement synchrone immédiat du check d'authentification Supabase[cite: 4]
        BlocProvider<AuthBloc>(
          create: (_) => Injector.get<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<CategoryBloc>(create: (_) => Injector.get<CategoryBloc>()),
        BlocProvider<BusinessBloc>(create: (_) => Injector.get<BusinessBloc>()),
        BlocProvider<MainScreenBloc>(create: (_) => Injector.get<MainScreenBloc>()),
        BlocProvider<SearchBloc>(create: (_) => Injector.get<SearchBloc>()),
        BlocProvider<SettingsCubit>(create: (_) => Injector.get<SettingsCubit>()),

        // 🛒 Chargement automatique du panier au démarrage[cite: 4]
        BlocProvider<BusinessDetailBloc>(
          create: (_) => Injector.get<BusinessDetailBloc>()..add(LoadCart()),
        )
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // 🔓 Libération absolue de l'écran natif dès que l'état d'authentification est déterminé[cite: 4]
          if (state is AuthenticatedState ||
              state is UnauthenticatedState ||
              state is AuthFailureState) {
            FlutterNativeSplash.remove();
          }
        },
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
      ),
    );
  }
}