import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: AppColors.scaffoldBackground,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.15, horizontal: MediaQuery.of(context).size.width * 0.05,),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Avatar (photo de profil)
                      Center(
                        child: Transform.translate(
                          offset: const Offset(0, -60),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: user.imgUrl != null && user.imgUrl!.isNotEmpty
                                  ? Image.network(
                                user.imgUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildInitialsAvatar(user.name),
                              )
                                  : _buildInitialsAvatar(user.name),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Nom et email
                      Center(
                        child: Column(
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Sections
                      _buildSection(
                        title: 'Activité',
                        children: [
                          _buildActionTile(
                            icon: Icons.edit,
                            label: 'Modifier le profil',
                            onTap: () => context.pushNamed('edit-profile'),
                          ),
                          _buildActionTile(
                            icon: Icons.shopping_bag_outlined,
                            label: 'Mes commandes',
                            onTap: () => context.go('/orders'),
                          ),
                          _buildActionTile(
                            icon: Icons.calendar_today_outlined,
                            label: 'Mes réservations',
                            onTap: () => context.go('/favorites'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildSection(
                        title: 'Compte',
                        children: [
                          _buildActionTile(
                            icon: Icons.person_outline,
                            label: 'Informations personnelles',
                            onTap: () {
                              // Aller à la page d'édition
                            },
                          ),
                          _buildActionTile(
                            icon: Icons.lock_outline,
                            label: 'Sécurité',
                            onTap: () {
                              // Changer mot de passe
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildSection(
                        title: 'Application',
                        children: [
                          _buildActionTile(
                            icon: Icons.help_outline,
                            label: 'Aide',
                            onTap: () {},
                          ),
                          _buildActionTile(
                            icon: Icons.info_outline,
                            label: 'À propos',
                            onTap: () {},
                          ),
                          _buildActionTile(
                            icon: Icons.logout,
                            label: 'Déconnexion',
                            onTap: () {
                              context.read<AuthBloc>().add(AuthLogoutEvent());
                              context.go('/login');
                            },
                            color: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    final initials = _getInitials(name);
    return Container(
      color: _getAvatarColor(name),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final List<Color> colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
    ];
    final index = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;
    return colors[index];
  }
}