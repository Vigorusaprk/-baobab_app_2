import 'package:baobabe_0_2/core/constants/injector.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HelloUserWidget extends StatelessWidget {
  const HelloUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'Utilisateur';
        UserEntity? user;

        if (state is AuthAuthenticated) {
          user = state.user;
          userName = user.name;
        }

        return Padding(
          padding: const EdgeInsets.only(left: AppDimens.PADDING_20, right: AppDimens.PADDING_20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF254D32),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF254D32).withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bonjour,",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.pushNamed('profil-page');
                      },
                        child: _buildProfileImage(user),
                    ), // ← passe l'utilisateur
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getCurrentDate(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSearchField(context), // devient un bouton
              ],
            ),
          ),
        );
      },
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  Widget _buildSearchField(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('search');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Color(0xFF254D32), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Où voulez-vous aller ?",
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF254D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune_rounded, color: Color(0xFF254D32), size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // Construction de la photo de profil (image ou initiales)
  Widget _buildProfileImage(UserEntity? user) {
    if (user == null) {
      return const SizedBox.shrink();
    }

    final hasProfile = user.imgUrl != null && user.imgUrl!.isNotEmpty;
    final avatarColor = _getAvatarColor(user.name);
    final initials = _getInitials(user.name);

    return Container(
      height: 65,
      width: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: hasProfile
            ? Image.network(
          user.imgUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialsAvatar(avatarColor, initials);
          },
        )
            : _buildInitialsAvatar(avatarColor, initials),
      ),
    );
  }

  // Widget pour les initiales dans le cercle
  Widget _buildInitialsAvatar(Color color, String initials) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Extrait les initiales du nom (ex: "Jean Dupont" -> "JD")
  String _getInitials(String name) {
    if (name.isEmpty || name.trim().isEmpty) return "?";
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return "?";
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return (parts[0][0] + parts.last[0]).toUpperCase();
    }
  }

  // Obtient une couleur cohérente à partir du nom
  Color _getAvatarColor(String name) {
    if (name.isEmpty) return Colors.blue;

    // Utilisation d'une liste de couleurs prédéfinies
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
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    int index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}