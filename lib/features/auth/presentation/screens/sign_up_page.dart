import 'dart:ui';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_event.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/password_field.dart';
import 'package:baobabe_0_2/features/main/presentation/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); // ✅ Lié à la colonne phone du schéma SQL
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignUpSubmittedEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          context.go('/home');
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: authBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration:  BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 15),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 40,
                                    spreadRadius: -10,
                                    offset: const Offset(-10, -10),
                                  ),
                                ],
                                border: Border.all(
                                  width: 1.5,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _nameController,
                                    label: 'Nom complet',
                                    iconPath: "assets/icons/user.svg",
                                    validator: (value) => value == null || value.isEmpty ? 'Entrez votre nom' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    iconPath: "assets/icons/mail-svgrepo-com.svg",
                                    validator: (value) => value == null || value.isEmpty ? 'Entrez votre email' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _phoneController,
                                    label: 'Téléphone (Optionnel)',
                                    iconPath: "assets/icons/phone.svg",
                                    validator: (value) => null, // Optionnel
                                  ),
                                  const SizedBox(height: 16),
                                  PasswordField(
                                    controller: _passwordController,
                                    label: 'Mot de passe',
                                    validator: (value) => value == null || value.length < 6 ? 'Minimum 6 caractères' : null,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildSignUpButton(),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Déjà inscrit ? ", style: TextStyle(color: AppColors.secondary)),
                                      TextButton(
                                        onPressed: () => context.go('/login'),
                                        child: const Text(
                                          'Se connecter',
                                          style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SvgPicture.asset(
          "assets/icons/olive-svgrepo-com.svg",
          height: 48,
          colorFilter: const ColorFilter.mode(AppColors.secondary, BlendMode.srcIn),
        ),
        const SizedBox(height: 16),
        const Text(
          'Inscription',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.secondary),
        ),
        const Text(
          'Créez votre compte en quelques instants !',
          style: TextStyle(fontSize: 16, color: AppColors.secondary),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String iconPath,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF1F3F4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: state is AuthLoadingState ? null : _signup,
            child: state is AuthLoadingState
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('S\'inscrire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        );
      },
    );
  }
}