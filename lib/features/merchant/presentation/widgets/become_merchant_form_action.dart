part of 'become_merchant_sheet.dart';

/// L'action du formulaire : soit envoyer la demande, soit poser le mot de
/// passe — selon que le commerçant en a déjà un.
class _MerchantAction extends StatefulWidget {
  const _MerchantAction({
    required this.name,
    required this.phone,
    required this.description,
    required this.categorySlug,
    required this.address,
    required this.passwordController,
    required this.confirmationController,
  });

  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController description;
  final String? categorySlug;
  final UserAddress address;
  final TextEditingController passwordController;
  final TextEditingController confirmationController;

  @override
  State<_MerchantAction> createState() => _MerchantActionState();
}
