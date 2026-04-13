import 'package:baobabe_0_2/core/constants/injector.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/main/presentation/bloc/main_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/routes/app_router.dart';
import 'features/home_page/presentation/bloc/search_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
  Injector.setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoryBloc>(create: (_) => Injector.get<CategoryBloc>()),
        BlocProvider<AuthBloc>(create: (_) => Injector.get<AuthBloc>()),
        BlocProvider<BusinessBloc>(create: (_) => Injector.get<BusinessBloc>()),
        BlocProvider<MainScreenBloc>(create: (_) => Injector.get<MainScreenBloc>()),
        BlocProvider<SearchBloc>(create: (_) => Injector.get<SearchBloc>()),
        BlocProvider<SettingsCubit>(create: (_) => Injector.get<SettingsCubit>()),
      ],
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AuthBloc>().add(AuthCheckStatusEvent());
          });
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated || state is AuthUnAuthenticated) {
                FlutterNativeSplash.remove();
              }
            },
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,
              theme: ThemeData(fontFamily: 'Poppins'),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US'), Locale('ln', 'CD')],
            ),
          );
        },
      ),
    );
  }
}