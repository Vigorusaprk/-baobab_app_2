import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_divider.dart';
import 'package:baobabe_0_2/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/language_picker_dialog.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';

/// Body-only content for the Settings tab. The Scaffold and AppBar (title
/// "Paramètres") are owned by MainShell, which is the single Scaffold for
/// the app's main navigation.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SessionService.instance.currentUser;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileSummaryCard(
              name: user?.name ?? 'Utilisateur',
              email: user?.email ?? '',
              onTap: () => context.pushNamed('profil-page'),
            ),
            AppDimens.spacerMedium,
            // Section Générale
            DetailSection(
              sectionTitle: "Générale",
              children: [
                InfoTile(
                  subtitle: "Notifications",
                  icon: Icons.notifications_none_outlined,
                  onTap: () {},
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),
                const CustomDivider(),
                InfoTile(
                  subtitle: "Langue",
                  icon: Icons.language_outlined,
                  onTap: () => showLanguagePickerDialog(context),
                  trailing: Text(
                    _getLanguageName(settingsState.locale.languageCode),
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.secondaryLight,
                    ),
                  ),
                ),
              ],
            ),
            AppDimens.spacerMedium,
            // Section Compte
            DetailSection(
              sectionTitle: "Compte",
              children: [
                InfoTile(
                  subtitle: "Informations personnelles",
                  icon: Icons.account_circle_outlined,
                  onTap: () {
                    context.pushNamed('edit-profile');
                  },
                ),
                const CustomDivider(),
                InfoTile(
                  subtitle: "Sécurité",
                  icon: Icons.lock_outline,
                  onTap: () {
                    context.pushNamed('change-password');
                  },
                ),
              ],
            ),
            AppDimens.spacerMedium,
            // Section Aide
            DetailSection(
              sectionTitle: "FAQ & Aide",
              children: [
                InfoTile(
                  subtitle: "Centre d'aide",
                  icon: Icons.help_outline,
                  onTap: () {},
                ),
                const CustomDivider(),
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
            AppDimens.spacerMedium,
            // Section Application
            DetailSection(
              sectionTitle: "Application",
              children: [
                InfoTile(
                  subtitle: "Version 1.0.0",
                  icon: Icons.info_outline,
                  onTap: () {},
                ),
                const CustomDivider(),
                InfoTile(
                  subtitle: "Confidentialité",
                  icon: Icons.privacy_tip_outlined,
                  onTap: () {},
                ),
                const CustomDivider(),
                InfoTile(
                  subtitle: "Conditions d'utilisation",
                  icon: Icons.description_outlined,
                  onTap: () {},
                ),
              ],
            ),
            AppDimens.spacerLarge,
            SettingsLogoutButton(
              onTap: () => showLogoutConfirmationDialog(context),
            ),
            AppDimens.spacerLarge,
          ],
        );
      },
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
    await Share.share(
      'Découvrez Baobabe, l\'application qui vous connecte aux meilleurs services !\nTéléchargez-la sur : https://baobabe.cd',
      subject: 'Baobabe App',
    );
  }
}
