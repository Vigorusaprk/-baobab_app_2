import 'package:baobabe_0_2/core/widgets/custom_divider.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// La section « FAQ & Aide » des paramètres : contacter l'équipe et partager
/// l'application.
class HelpSettingsSection extends StatelessWidget {
  const HelpSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailSection(
      sectionTitle: 'FAQ & Aide',
      children: [
        // « Centre d'aide » a été retiré : il n'ouvrait rien. Il reviendra
        // avec la page qu'il promet.
        InfoTile(
          subtitle: 'Contactez-nous',
          icon: Icons.mail_outline,
          onTap: _launchEmail,
        ),
        const CustomDivider(),
        InfoTile(
          subtitle: "Partager l'application",
          icon: Icons.share_outlined,
          onTap: _shareApp,
        ),
      ],
    );
  }

  static Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@baobabe.cd',
      query: 'subject=Support Baobabe&body=Bonjour,',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  static Future<void> _shareApp() async {
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
