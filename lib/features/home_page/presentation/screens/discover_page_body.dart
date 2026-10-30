import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/discover_cubit.dart';
import 'discover_page_controller.dart';

/// Point d'entrée public de la page Découvrir.
class DiscoverPageBody extends StatelessWidget {
  const DiscoverPageBody({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DiscoverCubit()..start(),
    child: const DiscoverPageController(),
  );
}
