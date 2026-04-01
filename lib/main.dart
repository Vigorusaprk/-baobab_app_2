import 'package:baobabe_0_2/core/constants/injector.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/main/presentation/bloc/main_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routes/app_router.dart';
import 'features/home_page/presentation/bloc/search_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    Injector.setup();
    runApp(const MyApp());
  } catch (e) {
    runApp(ErrorApp(error: e));
  }
}

class ErrorApp extends StatelessWidget {
  final dynamic error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 64),
                const SizedBox(height: 20),
                Text(
                  'Erreur lors du démarrage',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  error.toString(),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoryBloc>(
          create: (_) => Injector.get<CategoryBloc>(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => Injector.get<AuthBloc>(),
        ),
        BlocProvider<BusinessBloc>(
          create: (_) => Injector.get<BusinessBloc>(),
        ),
        BlocProvider<MainScreenBloc>(
          create: (_) => Injector.get<MainScreenBloc>(),
        ),
        BlocProvider<SearchBloc>(
          create: (_) => Injector.get<SearchBloc>(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: ThemeData(
          fontFamily: 'Poppins',
        ),
        builder: (context, child) {
          // Vérifier le statut de la session au premier build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            BlocProvider(create: (_) => Injector.get<AuthBloc>());
          });
          return child!;
        },
      ),
    );
  }
}