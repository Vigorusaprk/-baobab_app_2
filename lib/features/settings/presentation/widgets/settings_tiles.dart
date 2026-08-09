import 'package:baobabe_0_2/core/animation/press_effect.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';

/// Petits blocs réutilisables de l'écran des paramètres (badge d'icône,
/// ligne d'information, section détaillée). Extraits de settings_screen.dart
/// pour garder ce fichier concis ; comportement identique.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const IconBadge({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
    return PressEffect(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              IconBadge(icon: icon, color: AppColors.secondary),
              const SizedBox(width: 16),
              Expanded(child: Text(subtitle, style: AppFonts.bodyMedium)),
              if (trailing != null) trailing!,
              if (onTap != null && trailing == null)
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte d'entête affichant un résumé du profil connecté (avatar, nom,
/// email) au-dessus des sections de réglages, avec navigation vers la
/// page profil au tap.
class ProfileSummaryCard extends StatelessWidget {
  final bool isLoggedIn;
  final String name;
  final String email;
  final VoidCallback onTap;

  const ProfileSummaryCard({
    super.key,
    required this.isLoggedIn,
    required this.name,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = isLoggedIn ? name : 'Se connecter';
    final subtitle = isLoggedIn
        ? email
        : 'Accédez à votre profil et vos réglages';

    return PressEffect(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimens.cardBorderRadiusAll,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppDimens.cardBorderRadiusAll,
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isLoggedIn
                    ? AppColors.secondaryLight
                    : AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  isLoggedIn ? Icons.person : Icons.login_rounded,
                  color: isLoggedIn ? AppColors.white : AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppFonts.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: AppFonts.regular,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton de déconnexion en pilule pleine largeur, séparé des sections de
/// réglages plutôt qu'imbriqué dans une liste.
class SettingsLogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const SettingsLogoutButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Text(
              'Déconnexion',
              style: AppFonts.button.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailSection extends StatelessWidget {
  final String sectionTitle;
  final List<Widget> children;

  const DetailSection({
    super.key,
    required this.sectionTitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sectionTitle, style: Theme.of(context).textTheme.titleSmall),
        AppDimens.spacerMini,
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppDimens.cardBorderRadiusAll,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
