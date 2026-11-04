import 'dart:async';

import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_app_bar.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/set_password_form.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/security_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'security_screen_body.dart';

/// La page « Sécurité » des paramètres : le mot de passe du compte.
///
/// C'est lui qui sert à Baobab Business, l'application des commerçants :
/// un utilisateur sans mot de passe ne peut pas y ouvrir de session, même si
/// sa demande de devenir commerçant est déjà acceptée.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Le libellé dépend d'une clé posée côté serveur : on la relit à
    // chaque entrée dans la page.
    unawaited(context.read<SecurityCubit>().load());
  }

  Future<void> _onSubmit(String password) async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final hadPassword = context.read<SecurityCubit>().state.hasPassword;
    final error = await context.read<AuthBloc>().executeSetPassword(password);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (error != null) {
      // Le message affiché est déjà en français, produit par le datasource :
      // c'est lui qui connaît le code serveur (ré-authentification, etc.).
      setState(() => _error = error);
      return;
    }
    // La tuile des paramètres et cette page disent vrai dès le retour.
    await context.read<SecurityCubit>().load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hadPassword ? 'Mot de passe modifié.' : 'Mot de passe défini.',
        ),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomOtherAppBar(title: 'Sécurité'),
      body: SafeArea(
        top: false,
        child: _SecurityBody(
          isSubmitting: _isSubmitting,
          error: _error,
          onSubmit: _onSubmit,
        ),
      ),
    );
  }
}
