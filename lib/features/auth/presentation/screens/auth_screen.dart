import 'dart:ui';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/password_field.dart';
import 'package:baobabe_0_2/features/main/presentation/screens/main_screen.dart';
import 'package:baobabe_0_2/features/main/presentation/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;  // ✅ Ajout

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthLoginEvent(
        email: email,
        password: password,
        rememberMe: _rememberMe,  // ✅ Ajout
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: authBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(width: 2.5, color: AppColors.primary),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              iconPath: "assets/icons/mail-svgrepo-com.svg",
                            ),
                            const SizedBox(height: 20),
                            PasswordField(
                              controller: _passwordController,
                              label: 'Mot de passe',
                            ),
                            // ✅ Case "Se souvenir de moi"
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                                const Text(
                                  'Se souvenir de moi',
                                  style: TextStyle(color: Color(0xFF254D32), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  context.go('/forgot-password');
                                },
                                child: const Text(
                                  'Mot de passe oublié ?',
                                  style: TextStyle(color: Color(0xFF254D32), fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildLoginButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildSocialButton(label: 'Google', icon: "assets/icons/google.svg"),
                  const SizedBox(height: 12),
                  _buildSocialButton(label: 'Facebook', icon: "assets/icons/facebook.svg"),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Pas de compte ?", style: TextStyle(color: AppColors.primary)),
                      TextButton(
                        onPressed: () {
                          context.go('/register');
                        },
                        child: const Text(
                          'Inscrivez-vous',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets de composants pour la clarté ---

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.scaffoldBackground,
          ),
          child: SvgPicture.asset(
            "assets/icons/olive-svgrepo-com.svg",
            height: 48,
            colorFilter: const ColorFilter.mode(Color(0xFF254D32), BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Bienvenue',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: AppColors.scaffoldBackground),
        ),
        Text(
          'Heureux de vous revoir !',
          style: TextStyle(fontSize: 16, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String iconPath,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(iconPath, colorFilter: const ColorFilter.mode( AppColors.primary, BlendMode.srcIn)),
        ),
        filled: true,
        fillColor: const Color(0xFFF1F3F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: state is AuthLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF254D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: state is AuthLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              'Se connecter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialButton({required String label, required String icon}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          backgroundColor: AppColors.scaffoldBackground,
        ),
        icon: SvgPicture.asset(icon, height: 30, colorFilter: const ColorFilter.mode( AppColors.primary, BlendMode.srcIn)),
        label: Text(
          'Continuer avec $label',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.primary)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("OU", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        Expanded(child: Divider(color: AppColors.primary)),
      ],
    );
  }
}