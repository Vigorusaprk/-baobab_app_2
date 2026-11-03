part of 'become_merchant_sheet.dart';

class _BecomeMerchantFormState extends State<_BecomeMerchantForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  String? _categorySlug;
  UserAddress _address = const UserAddress();
  bool _showExplanation = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _description, _passwordController, _confirmationController]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MerchantExplanation(
            isOpen: _showExplanation,
            onToggle: () => setState(() => _showExplanation = !_showExplanation),
          ),
          _MerchantDetails(
            name: _name,
            phone: _phone,
            description: _description,
            categorySlug: _categorySlug,
            onCategoryChanged: (slug) => setState(() => _categorySlug = slug),
            address: _address,
            onAddressChanged: (address) => _address = address,
          ),
          AppDimens.spacerLarge,
          _MerchantAction(
            name: _name,
            phone: _phone,
            description: _description,
            categorySlug: _categorySlug,
            address: _address,
            passwordController: _passwordController,
            confirmationController: _confirmationController,
          ),
        ],
      ),
    );
  }
}
