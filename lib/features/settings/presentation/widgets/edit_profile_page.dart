import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = (context.read<AuthBloc>().state as AuthenticatedState).user;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.scaffoldBackground,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        title: Text(
            'Modifier le profil',
            style: TextStyle(
              fontFamily: AppFonts.primaryFontFamily,
              fontSize: 24,
              fontWeight: AppFonts.bold,
              color: AppColors.scaffoldBackground,
            ),
        )
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDimens.BORDER_RADIUS_30),
            topRight: Radius.circular(AppDimens.BORDER_RADIUS_30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration:  InputDecoration(
                  labelText: 'Nom complet',
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primary, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primary, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),

                GestureDetector(
                  onTap: () {
                    // Appeler l'API de mise à jour du profil
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil mis à jour (à implémenter)')),
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.all(
                          Radius.circular(25)
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text('Enregistrer', style: TextStyle(color: AppColors.scaffoldBackground, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}