import 'package:baobabe_0_2/features/main/presentation/widgets/app_background.dart';
import 'package:baobabe_0_2/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/language_picker_dialog.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/settings_tiles.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/theme_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return authBackground(
          child: Scaffold(
            backgroundColor: AppColors.transparent,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text("Paramètres", style: AppFonts.headlineLarge),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Section Générale
                DetailSection(
                  sectionTitle: "Générale",
                  children: [
                    InfoTile(
                      subtitle: "Profil",
                      icon: Icons.person_outline,
                      onTap: () {
                        context.pushNamed('profil-page');
                      },
                    ),
                    const Divider(color: Colors.grey),
                    InfoTile(
                      subtitle: "Notifications",
                      icon: Icons.notifications_none_outlined,
                      onTap: () {},
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                      ),
                    ),
                    const Divider(color: Colors.grey),
                    InfoTile(
                      subtitle: "Langue",
                      icon: Icons.language_outlined,
                      onTap: () => showLanguagePickerDialog(context),
                      trailing: Text(
                        _getLanguageName(settingsState.locale.languageCode),
                        style: AppFonts.bodySmall?.copyWith(color: AppColors.secondaryLight),
                      ),
                    ),
                    const Divider(color: Colors.grey),
                    InfoTile(
                      subtitle: "Thème",
                      icon: Icons.brightness_6_outlined,
                      onTap: () => showThemePickerDialog(context),
                      trailing: Text(
                        _getThemeName(settingsState.themeMode),
                        style: AppFonts.bodySmall?.copyWith(color: AppColors.secondaryLight),
                      ),
                    ),
                  ],
                ),
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
                    const Divider(color: Colors.grey),
                    InfoTile(
                      subtitle: "Sécurité",
                      icon: Icons.lock_outline,
                      onTap: () {
                        context.pushNamed('change-password');
                      },
                    ),
                    const Divider(color: Colors.grey),
                    InfoTile(
                      subtitle: "Déconnexion",
                      icon: Icons.logout,
                      accentColor: AppColors.error,
                      onTap: () => showLogoutConfirmationDialog(context),
                    ),
                  ],
                ),
                // Section Aide
                DetailSection(
                  sectionTitle: "FAQ & Aide",
                  children: [
                    InfoTile(
                      subtitle: "Centre d'aide",
                      icon: Icons.help_outline,
                      onTap: () {},
                    ),
                    const Divider(color: Colors.grey),
                    InfoTile(
                      subtitle: "Contactez-nous",
                      icon: Icons.mail_outline,
                      onTap: () => _launchEmail(),
                    ),
                    const Divider(color: Colors.grey),
                    InfoTile(
                      subtitle: "Partager l'application",
                      icon: Icons.share_outlined,
                      onTap: () => _shareApp(),
                    ),
                  ],
                ),
                // Section Application
                DetailSection(
                  sectionTitle: "Application",
                  children: [
                    InfoTile(
                      subtitle: "Version 1.0.0",
                      icon: Icons.info_outline,
                      onTap: () {},
                    ),
                    const Divider(color: Colors.grey),
                    InfoTile(
                      subtitle: "Confidentialité",
                      icon: Icons.privacy_tip_outlined,
                      onTap: () {},
                    ),
                    const Divider(color: Colors.grey),
                    InfoTile(
                      subtitle: "Conditions d'utilisation",
                      icon: Icons.description_outlined,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 95),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'fr': return 'Français';
      case 'en': return 'English';
      case 'ln': return 'Lingala';
      default: return 'Français';
    }
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'Clair';
      case ThemeMode.dark: return 'Sombre';
      case ThemeMode.system: return 'Système';
      default: return 'Clair';
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
