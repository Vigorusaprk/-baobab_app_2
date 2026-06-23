import 'dart:ui';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_event.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/password_field.dart';
import 'package:baobabe_0_2/features/main/presentation/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginSubmittedEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
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
                        const SizedBox(height: 40),
                        // --- Carte vitrée (sans effet 3D) ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 25),
                              decoration: BoxDecoration(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    iconPath:
                                    "assets/icons/mail-svgrepo-com.svg",
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Veuillez entrer votre email';
                                      if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value))
                                        return 'Email invalide';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  PasswordField(
                                    controller: _passwordController,
                                    label: 'Mot de passe',
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Veuillez entrer votre mot de passe';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildForgotPasswordAndRememberMe(),
                                  const SizedBox(height: 24),
                                  _buildLoginButton(),
                                  const SizedBox(height: 16),
                                  _buildDivider(),
                                  const SizedBox(height: 16),
                                  _buildSocialButton(
                                      label: 'Google',
                                      icon: 'assets/icons/google.svg'),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Nouveau ici ? ",
                                        style: TextStyle(
                                            color: AppColors.secondary),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            context.go('/register'),
                                        child: const Text(
                                          'Inscrivez-vous',
                                          style: TextStyle(
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.bold,
                                          ),
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

  // --- Méthodes de construction (inchangées) ---
  Widget _buildHeader() {
    return Column(
      children: [
        SvgPicture.asset(
          "assets/icons/olive-svgrepo-com.svg",
          height: 48,
          colorFilter: const ColorFilter.mode(
              AppColors.secondary, BlendMode.srcIn),
        ),
        const SizedBox(height: 16),
        const Text(
          'Bienvenue',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: AppColors.secondary,
          ),
        ),
        const Text(
          'Heureux de vous revoir !',
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
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            iconPath,
            colorFilter:
            const ColorFilter.mode(AppColors.secondary, BlendMode.srcIn),
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildForgotPasswordAndRememberMe() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              activeColor: AppColors.secondary,
              onChanged: (value) =>
                  setState(() => _rememberMe = value ?? false),
            ),
            SizedBox(height: 20,),
            const Text('Se souvenir',
                style: TextStyle(color: AppColors.secondaryDark)),
          ],
        ),
        TextButton(
          onPressed: () => context.go('/forgot-password'),
          child: const Text(
            'Mot de passe oublié ?',
            style: TextStyle(
                color: AppColors.secondaryDark, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: state is AuthLoadingState ? null : _login,
            child: state is AuthLoadingState
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              'Se connecter',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.secondary)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("OU", style: TextStyle(color: AppColors.secondary)),
        ),
        Expanded(child: Divider(color: AppColors.secondary)),
      ],
    );
  }

  Widget _buildSocialButton({required String label, required String icon}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          backgroundColor: AppColors.secondary,
        ),
        icon: SvgPicture.asset(icon, height: 30),
        label: Text(
          'Continuer avec $label',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500),
        ),
        onPressed: () {},
      ),
    );
  }
}