import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/auth/domain/entities/user.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';
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

        // 🛠️ FIX : Utilisation du bon nom d'état 'AuthenticatedState'
        if (state is AuthenticatedState) {
          final authenticatedUser = state.user;
          if (authenticatedUser != null) {
            user = authenticatedUser;
            userName = authenticatedUser.name;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(
            left: AppDimens.PADDING_20,
            right: AppDimens.PADDING_20,
            top: AppDimens.PADDING_16,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.secondaryLight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Salut, $userName 👋",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimens.PADDING_4),
                const Text(
                  "Découvrez de nouveaux endroits !",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: AppDimens.PADDING_16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSearchField(context),
                    const SizedBox(width: AppDimens.PADDING_16),
                    _buildAvatar(user, userName, context),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          final searchBloc = context.read<SearchBloc>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: searchBloc,
                child: const SearchPage(),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.PADDING_12,
            vertical: AppDimens.PADDING_8,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: AppColors.grey,
                size: 22,
              ),
              const SizedBox(width: AppDimens.PADDING_12),
              const Expanded(
                child: Text(
                  "Où voulez-vous aller ?",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppDimens.PADDING_8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_12),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(UserEntity? user, String userName, BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/profile'),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: _buildInitialsAvatar(userName),
        ),
      ),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

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

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return Colors.blue;
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
    ];
    final int hash = name.hashCode;
    final int index = hash.abs() % colors.length;
    return colors[index];
  }
}