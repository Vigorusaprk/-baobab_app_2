part of 'become_merchant_sheet.dart';

class _MerchantActionState extends State<_MerchantAction> {
  bool _isSending = false;
  bool _showPasswordStep = false;

  Future<void> _submit() async {
    final form = Form.of(context);
    if (!form.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final hasPassword = await context.read<AuthBloc>().executeHasPassword();
    if (!mounted) return;
    if (!hasPassword) {
      setState(() => _showPasswordStep = true);
      return;
    }
    if (widget.categorySlug == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Choisissez une catégorie')),
      );
      return;
    }
    if (widget.address.commune == null || widget.address.avenue == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Indiquez au moins votre commune et votre avenue.'),
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    final error = await context.read<MerchantCubit>().apply(
      businessName: widget.name.text.trim(),
      categorySlug: widget.categorySlug!,
      address: widget.address,
      phone: widget.phone.text.trim(),
      description: widget.description.text.trim().isEmpty
          ? null
          : widget.description.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSending = false);

    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Connectez-vous à Baobab Business avec ${context.read<ProfileCubit>().state.profile.email} et votre mot de passe.',
        ),
      ),
    );

    await NotificationPrompt.maybeAsk(
      context,
      NotificationReason.merchantJoined,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _onPasswordValidated(String password) async {
    final error = await context.read<AuthBloc>().executeSetPassword(password);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _showPasswordStep = false);
    await _submit();
  }

  @override
  Widget build(BuildContext context) {
    if (_showPasswordStep) {
      return _MerchantPasswordStep(
        passwordController: widget.passwordController,
        confirmationController: widget.confirmationController,
        onValidated: _onPasswordValidated,
      );
    }
    return CustomButton(
      text: 'Envoyer ma demande',
      isLoading: _isSending,
      onPressed: _submit,
    );
  }
}
