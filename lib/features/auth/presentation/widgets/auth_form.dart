import 'package:baobabe_0_2/core/animation/fade_swap.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/core/widgets/otp_code_field.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/auth_success.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/email_form.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/otp_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Les trois temps de la connexion par courriel.
enum _Step { email, code, done }

/// Connexion par e-mail et code, dans la feuille partagée.
///
/// Le titre et la flèche de retour ne sont pas dessinés ici : ils sont
/// poussés dans l'en-tête de la feuille par [SheetHeaderScope], qui les
/// affiche au-dessus de la poignée. Chaque étape n'a donc à s'occuper que de
/// son contenu.
class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _Step _step = _Step.email;
  OtpStatus _otpStatus = OtpStatus.editing;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    // Après la première trame : poser l'en-tête pendant le `build` de la
    // feuille reviendrait à la reconstruire pendant qu'elle se construit.
    WidgetsBinding.instance.addPostFrameCallback((_) => _pushHeader());
    _otp.addListener(_clearRejection);
  }

  /// Retoucher un code refusé le rend neutre : garder les cases rouges
  /// pendant qu'on corrige donnerait un verdict sur un code qui n'existe
  /// plus.
  void _clearRejection() {
    if (_otpStatus != OtpStatus.invalid) return;
    setState(() => _otpStatus = OtpStatus.editing);
  }

  @override
  void dispose() {
    _otp.removeListener(_clearRejection);
    _email.dispose();
    _otp.dispose();
    super.dispose();
  }

  /// Donne à la feuille le titre de l'étape en cours, et le retour quand il
  /// y a quelque chose derrière.
  void _pushHeader() {
    if (!mounted) return;
    SheetHeaderScope.of(context)?.value = switch (_step) {
      _Step.email => const SheetHeader(title: 'Adresse e-mail'),
      _Step.code => SheetHeader(
        title: 'Code de confirmation',
        onBack: _backToEmail,
      ),
      // Rien derrière : la connexion est faite, on ne la refait pas.
      _Step.done => const SheetHeader(title: 'Terminé'),
    };
  }

  void _goTo(_Step step) {
    setState(() => _step = step);
    _pushHeader();
  }

  void _backToEmail() {
    _otp.clear();
    setState(() => _otpStatus = OtpStatus.editing);
    _goTo(_Step.email);
  }

  void _submitEmail() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _emailError = null);
    context.read<AuthBloc>().add(
      RequestEmailOtpEvent(email: _email.text.trim()),
    );
  }

  void _submitOtp() {
    // Une fois le code accepté, le même bouton fait passer à la
    // confirmation : c'est l'enchaînement des maquettes, code vert puis
    // « Suivant ». Le revérifier le brûlerait pour rien.
    if (_otpStatus == OtpStatus.verified) {
      _goTo(_Step.done);
      return;
    }
    context.read<AuthBloc>().add(
      VerifyEmailOtpEvent(email: _email.text.trim(), code: _otp.text),
    );
  }

  /// Referme la feuille, puis rend la main à l'écran d'où l'on venait.
  void _finish() {
    Navigator.of(context).pop();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case RequestEmailOtpSuccess():
            _goTo(_Step.code);
          case RequestEmailOtpFailure(:final error):
            // Sous le champ, et non dans une notification en bas d'écran :
            // celle-ci passerait derrière la feuille.
            setState(() => _emailError = error);
          case VerifyEmailOtpFailure():
            setState(() => _otpStatus = OtpStatus.invalid);
          case VerifyEmailOtpSuccess():
            // On reste sur l'étape du code, en vert : la confirmation
            // vient à l'appui suivant.
            setState(() => _otpStatus = OtpStatus.verified);
          default:
            break;
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: FadeSwap(child: _body(state)),
        );
      },
    );
  }

  Widget _body(AuthState state) => switch (_step) {
    _Step.email => EmailForm(
      key: const ValueKey('email'),
      email: _email,
      submit: _submitEmail,
      isLoading: state is RequestEmailOtpLoading,
      error: _emailError,
    ),
    _Step.code => OtpForm(
      key: const ValueKey('code'),
      submit: _submitOtp,
      otp: _otp,
      email: _email.text.trim(),
      isLoading: state is VerifyEmailOtpLoading,
      status: _otpStatus,
    ),
    _Step.done => AuthSuccess(key: const ValueKey('done'), onContinue: _finish),
  };
}
