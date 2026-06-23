import 'package:baobabe_0_2/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_event.dart';
import 'package:baobabe_0_2/features/main/presentation/widgets/main_background.dart';


// Classes internes (définies avant utilisation)
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const IconBadge({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const InfoTile({
    super.key,
    required this.subtitle,
    required this.icon,
    this.accentColor = AppColors.primary,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            IconBadge(icon: icon, color: AppColors.secondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(subtitle, style: AppFonts.bodyMedium),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class DetailSection extends StatelessWidget {
  final String sectionTitle;
  final List<Widget> children;

  const DetailSection({super.key, required this.sectionTitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Text(sectionTitle, style: AppFonts.bodySmall),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return MainBackground(
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
                      onTap: () => _showLanguageDialog(context),
                      trailing: Text(
                        _getLanguageName(settingsState.locale.languageCode),
                        style: AppFonts.bodySmall?.copyWith(color: AppColors.secondaryLight),
                      ),
                    ),
                    const Divider(color: Colors.grey),
                    InfoTile(
                      subtitle: "Thème",
                      icon: Icons.brightness_6_outlined,
                      onTap: () => _showThemeDialog(context),
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
                      onTap: () => _showLogoutDialog(context),
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

  void _showLanguageDialog(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.scaffoldBackground,
        title: Text("Choisir la langue", style: AppFonts.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Français"),
              trailing: cubit.state.locale.languageCode == 'fr'
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                cubit.setLocale(const Locale('fr', 'FR'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("English"),
              trailing: cubit.state.locale.languageCode == 'en'
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                cubit.setLocale(const Locale('en', 'US'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Lingala"),
              trailing: cubit.state.locale.languageCode == 'ln'
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                cubit.setLocale(const Locale('ln', 'CD'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    showDialog(

      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.scaffoldBackground,

        title: Text("Choisir le thème", style: AppFonts.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Clair"),
              trailing: cubit.state.themeMode == ThemeMode.light
                  ? Icon(Icons.check, color: AppColors.secondaryLight)
                  : null,
              onTap: () {
                cubit.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Sombre"),
              trailing: cubit.state.themeMode == ThemeMode.dark
                  ? Icon(Icons.check, color: AppColors.secondaryLight)
                  : null,
              onTap: () {
                cubit.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Système"),
              trailing: cubit.state.themeMode == ThemeMode.system
                  ? Icon(Icons.check, color: AppColors.secondaryLight)
                  : null,
              onTap: () {
                cubit.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Déconnexion", style: AppFonts.titleMedium),
        content: Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequestedEvent());
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text("Se déconnecter"),
          ),
        ],
      ),
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