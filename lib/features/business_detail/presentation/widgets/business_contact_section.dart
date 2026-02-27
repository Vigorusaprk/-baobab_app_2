import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class BusinessContactSection extends StatelessWidget {
  final Business business;

  const BusinessContactSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildContactTile(Icons.phone_rounded, "Téléphone", business.phone,
                  () => _launch('tel:${business.phone}')),
          if (business.email != null)
            _buildContactTile(Icons.email_rounded, "Email", business.email!,
                    () => _launch('mailto:${business.email}')),
          if (business.website != null)
            _buildContactTile(Icons.language_rounded, "Site Web", "Consulter le site",
                    () => _launch(business.website!)),
        ],
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String value, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFF254D32).withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF254D32), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}