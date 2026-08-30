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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Body-only content for the Settings tab. The Scaffold and AppBar (title
/// "Paramètres") are owned by MainShell, which is the single Scaffold for
/// the app's main navigation.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SessionService.instance.currentUser;
    final isLoggedIn = user != null;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return ListView(
          padding: AppDimens.appPadding,
          children: [
            ProfileSummaryCard(
              isLoggedIn: isLoggedIn,
              name: user?.name ?? '',
              email: user?.email ?? '',
              onTap: () => isLoggedIn
                  ? context.pushNamed('profil-page')
                  : context.push('/login'),
            ),
            AppDimens.spacerMedium,
            // Section Générale
            DetailSection(
              sectionTitle: "Générale",
              children: [
                InfoTile(
                  subtitle: "Notifications",
                  icon: Icons.notifications_none_outlined,
                  onTap: () {
                    if (!isLoggedIn) _requireLogin(context);
                  },
                  trailing: Switch(
                    value: isLoggedIn,
                    onChanged: (value) {
                      if (!isLoggedIn) _requireLogin(context);
                    },
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
