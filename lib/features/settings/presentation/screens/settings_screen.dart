import 'package:baobabe_0_2/core/services/get_app_version.dart';
import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/core/widgets/custom_divider.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_settings_tile.dart';
import 'package:baobabe_0_2/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/language_picker_dialog.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/settings_tiles.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/profile_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:baobabe_0_2/features/notification/presentation/widgets/notification_setting_tile.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_session_cubit.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';

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

class _Content extends StatelessWidget {
  const _Content({required this.user, required this.isLoggedIn});

  final AppSessionUser? user;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return CustomRefresh(
          onRefresh: () async {
            // Deux sources se relisent ici : la fiche de profil et l'espace
            // commercant. La session, elle, est ecoutee et n'a rien a
            // recharger.
            await Future.wait([
              context.read<ProfileCubit>().load(force: true),
              context.read<MerchantCubit>().refresh(),
            ]);
          },
          child: ListView(
            padding: AppDimens.appPadding,
            children: [
              ProfileSummaryCard(
                isLoggedIn: isLoggedIn,
                name: user?.name ?? '',
                email: user?.email ?? '',
                onTap: () => isLoggedIn
                    ? showProfileDetailsSheet(context)
                    : context.push('/login'),
              ),
              AppDimens.spacerMedium,
              // Section Générale
              DetailSection(
                sectionTitle: "Générale",
                children: [
                  // Le commutateur était décoratif : sa valeur suivait
                  // « suis-je connecté ? » et son `onChanged` ne faisait rien.
                  // Il dit maintenant l'état réel de la permission, et sert de
                  // porte de sortie à qui l'a refusée.
                  NotificationSettingTile(
                    isLoggedIn: isLoggedIn,
                    onRequireLogin: () => _requireLogin(context),
                    builder: (context, trailing, onTap) => InfoTile(
                      subtitle: "Notifications",
                      icon: Icons.notifications_none_outlined,
                      onTap: onTap,
                      trailing: trailing,
                    ),
                  ),
                  const CustomDivider(),
                  InfoTile(
                    subtitle: "Langue",
                    icon: Icons.language_outlined,
                    onTap: () => showLanguagePickerDialog(context),
                    trailing: Text(
                      _getLanguageName(settingsState.locale.languageCode),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              AppDimens.spacerMedium,
              // Section Commerce : la porte d'entrée vers l'espace
              // commerçant, ou vers la demande pour en ouvrir un.
              MerchantSettingsSection(isLoggedIn: isLoggedIn),
              AppDimens.spacerMedium,
              // Section Aide
              DetailSection(
                sectionTitle: "FAQ & Aide",
                children: [
                  // « Centre d'aide » a été retiré : il n'ouvrait rien.
                  // Il reviendra avec la page qu'il promet.
                  InfoTile(
                    subtitle: "Contactez-nous",
                    icon: Icons.mail_outline,
                    onTap: () => _launchEmail(),
                  ),
                  const CustomDivider(),
                  InfoTile(
                    subtitle: "Partager l'application",
                    icon: Icons.share_outlined,
                    onTap: () => _shareApp(),
                  ),
                ],
              ),
              // La section « Application » (Confidentialité, Conditions
              // d'utilisation) a été retirée : les deux pages n'existent pas,
              // et PRODUCT.md note que le cadre juridique n'est pas arrêté.
              // Une entrée qui n'ouvre rien vaut moins qu'une entrée absente ;
              // elles reviendront avec leur contenu.
              if (isLoggedIn) ...[
                AppDimens.spacerLarge,
                SettingsLogoutButton(
                  onTap: () => showLogoutConfirmationDialog(context),
                ),
              ],
              AppDimens.spacerMini,
              const VersionText(),
            ],
          ),
        );
      },
    );
  }

  void _requireLogin(BuildContext context) {
    showAuthRequiredCard(
      context,
      message: 'Connectez-vous pour activer les notifications.',
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'ln':
        return 'Lingala';
      default:
        return 'Français';
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@baobabe.cd',
      query: 'subject=Support Baobabe&body=Bonjour,',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _shareApp() async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            "Découvrez Baobabe, l'application qui vous connecte aux meilleurs "
            'services !\nTéléchargez-la sur : https://baobabe.cd',
        subject: 'Baobabe',
      ),
    );
  }
}
