import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/email_form.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/otp_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpControllr = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isOtpForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitEmail() {
    if (_formKey.currentState?.validate() ?? false) {}
    context.read<AuthBloc>().add(
      RequestEmailOtpEvent(email: _emailController.text),
    );
  }

  void _submitOTP() {
    context.read<AuthBloc>().add(
      VerifyEmailOtpEvent(
        email: _emailController.text,
        code: _otpControllr.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is RequestEmailOtpSuccess) {
          setState(() {
            isOtpForm = true;
          });
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: !isOtpForm
              ? EmailForm(email: _emailController, submit: _submitEmail)
              : OtpForm(
                  submit: _submitOTP,
                  otp: _otpControllr,
                  email: _emailController.text,
                ),
        );
      },
    );
  }
}
