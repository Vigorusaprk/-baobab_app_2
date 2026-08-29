import 'package:baobabe_0_2/core/constants/icon_link.dart';
import 'package:baobabe_0_2/core/services/is_apple.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/outlined_button_with_icon.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/auth_form.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/auth_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthWithGoogleSuccess || state is AuthWithAppleSuccess) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AuthHeader(),
                Padding(
                  padding: AppDimens.appPadding,
                  child: Column(
                    children: [
                      AppDimens.spacerLarge,
                      SocialButton(
                        label: 'Google',
                        icon: IconLink.google,
                        onPressed: () =>
                            context.read<AuthBloc>().add(AuthWithGoogleEvent()),
                      ),
                      if (isAppleDevice) ...[
                        AppDimens.spacerMedium,
                        SocialButton(
                          label: 'Apple',
                          icon: IconLink.apple,
                          onPressed: () => context.read<AuthBloc>().add(
                            AuthWithAppleEvent(),
                          ),
                        ),
                      ],
                      AppDimens.spacerMedium,
                      OutlinedButtonWithIcon(
                        label: 'Continuer avec Email',
                        icon: IconLink.email,
                        onPressed: () => showCustomBottomSheet(
                          context: context,
                          child: AuthForm(),
                        ),
                      ),
                      AppDimens.spacerLarge,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
