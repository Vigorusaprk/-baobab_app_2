import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BoutiqueDetail extends StatelessWidget {
  final Business businessModel; // ou Business selon votre modèle

  const BoutiqueDetail({super.key, required this.businessModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          // AppBar avec image de couverture
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image de couverture (bgImg du business)
                  Image.asset(
                    businessModel.bgImg,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primary.withOpacity(0.3),
                      child: const Icon(Icons.store, size: 80, color: Colors.white),
                    ),
                  ),
                  // Gradient pour lisibilité du titre
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Contenu
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Nom et type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        businessModel.name,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(businessModel.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getCategoryName(businessModel.type),
                        style: TextStyle(
                          color: _getCategoryColor(businessModel.type),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Adresse
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        businessModel.address,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Actions (appeler, itinéraire, site)
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.phone,
                      label: 'Appeler',
                      onTap: () => _launchPhone(businessModel.phone),
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      icon: Icons.directions,
                      label: 'Itinéraire',
                      onTap: () => _launchMaps(businessModel.address),
                    ),
                    const SizedBox(width: 12),
                    if (businessModel.website != null)
                      _buildActionButton(
                        icon: Icons.language,
                        label: 'Site web',
                        onTap: () => _launchUrl(businessModel.website!),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description
                const Text(
                  'À propos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  businessModel.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 24),

                // Horaires d'ouverture
                const Text(
                  'Horaires',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...businessModel.openingHours.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text(entry.value),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),

                // Photos supplémentaires (si disponibles)
                if (businessModel.images.isNotEmpty) ...[
                  const Text(
                    'Photos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: businessModel.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              businessModel.images[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
          side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Color _getCategoryColor(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
      case BusinessType.fastFood:
        return Colors.orange;
      case BusinessType.shopping:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return 'Restaurant';
      case BusinessType.fastFood:
        return 'Fast Food';
      case BusinessType.shopping:
        return 'Boutique';
      default:
        return 'Commerce';
    }
  }

  void _launchPhone(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phone';
    }
  }

  void _launchMaps(String address) async {
    final query = Uri.encodeComponent(address);
    final Uri launchUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _launchUrl(String url) async {
    final Uri launchUri = Uri.parse(url);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}

