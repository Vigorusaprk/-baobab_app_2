import 'package:baobabe_0_2/core/services/get_app_version.dart';
import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_session_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/general_settings_section.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/security_settings_section.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/help_settings_section.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/legal_settings_section.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/settings_tiles.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/profile_sheets.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_settings_tile.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'settings_screen_content.dart';

/// Body-only content for the Settings tab. The Scaffold and AppBar (title
/// "Paramètres") are owned by MainShell, which is the single Scaffold for
/// the app's main navigation.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // La session est **ecoutee**, pas lue une fois.
    //
    // Elle etait lue au moment du `build` : se connecter depuis cet ecran
    // fermait la feuille et laissait la page telle quelle — nom absent,
    // bouton « Se connecter » toujours la — jusqu'a ce qu'un autre evenement
    // provoque une reconstruction. `AuthSessionCubit` existait deja et etait
    // fourni pour toute l'application ; cet ecran ne s'en servait pas.
    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, session) {
        final isLoggedIn = session is AuthSessionAuthenticated;
        final user = isLoggedIn ? SessionService.instance.currentUser : null;
        return _Content(user: user, isLoggedIn: isLoggedIn);
      },
    );
  }
}
