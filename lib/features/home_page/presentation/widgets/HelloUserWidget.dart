import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class HelloUserWidget extends StatelessWidget {
  const HelloUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppSessionUser?>(
      initialData: SessionService.instance.currentUser,
      stream: SessionService.instance.userChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final userName = user?.name ?? 'Utilisateur';

        return Padding(
          padding: const EdgeInsets.only(
            left: AppDimens.PADDING_20,
            right: AppDimens.PADDING_20,
            top: AppDimens.PADDING_16,
          ),
          child: Container(
            decoration: BoxDecoration(
              color:  AppColors.accent700,
              borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            padding: EdgeInsets.symmetric(horizontal: AppDimens.BORDER_RADIUS_15, vertical: AppDimens.BORDER_RADIUS_20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(user, userName, context),
                    const SizedBox(width: AppDimens.PADDING_10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Salut 👋,",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.scaffoldBackground,
                          ),
                        ),
                        Text(
                          "$userName",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.scaffoldBackground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.PADDING_4),
                Text(
                  "Découvrez des nouveaux endroits !",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.scaffoldBackground,
                  ),
                ),
                const SizedBox(height: AppDimens.PADDING_16),
                _buildSearchField(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Row(
      children: [
        Expanded(
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
                color: AppColors.canvasBackground,
                borderRadius: BorderRadius.circular(
                  AppDimens.BORDER_RADIUS_12,
                ),
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
                  SvgPicture.asset(
                    'assets/icons/search-normal.svg',
                    height: 25,
                    width: 25,
                    colorFilter: const ColorFilter.mode(
                      AppColors.accent700,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: AppDimens.PADDING_12),
                  const Expanded(
                    child: Text(
                      "Où voulez-vous aller ?",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: AppDimens.PADDING_12),

        GestureDetector(
          onTap: () {
            // TODO : ouvrir les filtres
          },
          child: Container(
            padding: const EdgeInsets.all(
              AppDimens.PADDING_12,
            ),
            decoration: BoxDecoration(
              color: AppColors.canvasBackground,
              borderRadius: BorderRadius.circular(
                AppDimens.BORDER_RADIUS_12,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/icons/filter.svg',
              height: 20,
              width: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.accent700,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildAvatar(AppSessionUser? user, String userName, BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/profile'),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color:  AppColors.accent100,
            width: 2.5
          ),
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