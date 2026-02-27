import 'package:baobabe_0_2/core/constants/injector.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/screens/auth_screen.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/main/presentation/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/main/presentation/bloc/main_screen_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialiser l'injector
    Injector.setup();
    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.primary,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 64,
                  ),
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
                    e.toString(),
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
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // CORRECTION : Ajouter CategoryBloc en premier
        BlocProvider<CategoryBloc>(
          create: (_) => Injector.get<CategoryBloc>(),
        ),
        // Initialiser AuthBloc avec AuthCheckStatusEvent
        BlocProvider<AuthBloc>(
          create: (_) => Injector.get<AuthBloc>(),
        ),
        // Ajouter d'autres Blocs si nécessaire (selon votre injector)
        BlocProvider<BusinessBloc>(
          create: (_) => Injector.get<BusinessBloc>(),
        ),
        BlocProvider<MainScreenBloc>(
          create: (_) => Injector.get<MainScreenBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          // La SplashScreen sera affichée en premier
          return const LoginPage();
        } else if (state is AuthUnAuthenticated || state is AuthError) {
          return  MainScreen();
        } else {
          // Par défaut, retourner MainScreen sans chargement
          return MainScreen();
        }
      },
    );
  }
}