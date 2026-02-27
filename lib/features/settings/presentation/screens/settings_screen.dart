import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import '../bloc/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent,
        title: Text("Parmétre", style: AppFonts.headlineLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Genérale
          DetailSection(
            sectionTitle: "Genérale",
            children: [
              InfoTile(subtitle: "subtitle", icon: Icons.person),
              Divider(color: Colors.grey),
              InfoTile(subtitle: "subtitle", icon: Icons.money),
              Divider(color: Colors.grey),
              InfoTile(subtitle: "subtitle", icon: Icons.book),
              Divider(color: Colors.grey),
              InfoTile(subtitle: "subtitle", icon: Icons.link),
              Divider(color: Colors.grey),
            ],
          ),

          // Section Compte
          DetailSection(
            sectionTitle: "Compte",
            children: [

            ],
          ),

          // Section Aide
          DetailSection(
            sectionTitle: "FAQ & Aide",
            children: [

            ],
          ),

          // Section App
          DetailSection(
            sectionTitle: "Aplicaiton",
            children: [

            ],
          ),
        ],
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class InfoTile extends StatelessWidget {
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const InfoTile({
    super.key,
    required this.subtitle,
    required this.icon,
    this.accentColor = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          IconBadge(icon: icon, color: accentColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(subtitle, style: AppFonts.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


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
