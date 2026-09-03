import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessContactSection extends StatelessWidget {
  final Business business;

  /// Le téléphone est devenu un bouton dans l'identité du commerce : la
  /// fiche le proposait donc deux fois. Cette carte ne porte plus que ce que
  /// le bouton ne couvre pas.
  final bool showPhone;

  const BusinessContactSection({
    super.key,
    required this.business,
    this.showPhone = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          if (showPhone)
            _buildContactTile(
              context,
              "assets/icons/phone.svg",
              "Téléphone",
              business.phone,
              () => _launch('tel:${business.phone}'),
            ),
          if (business.email != null)
            _buildContactTile(
              context,
              "assets/icons/email.svg",
              "Email",
              business.email!,
              () => _launch('mailto:${business.email}'),
            ),
          if (business.website != null)
            _buildContactTile(
              context,
              "assets/icons/website.svg",
              "Site Web",
              "Consulter le site",
              () => _launch(business.website!),
            ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    String icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          icon,
          width: 28,
          height: 28,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primary,
            BlendMode.srcIn,
          ),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
