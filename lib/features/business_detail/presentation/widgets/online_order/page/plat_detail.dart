import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

class PlatDetail extends StatefulWidget {
  final MenuItem menuItem;
  final String? restaurantId;
  final String? restaurantName;
  final BusinessType? restaurantType;
  final bool isOrderMode; // mode consultation ou commande

  const PlatDetail({
    super.key,
    required this.menuItem,
    this.restaurantId,
    this.restaurantName,
    this.restaurantType,
    this.isOrderMode = true,
  });

  @override
  State<PlatDetail> createState() => _PlatDetailState();
}

class _PlatDetailState extends State<PlatDetail> {
  int _quantity = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final menu = widget.menuItem;
    final totalPrice = menu.price * _quantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        title: Text(
          menu.itemName,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryLight,
            decoration: TextDecoration.none,
          ),
        ),
        foregroundColor: AppColors.white,
        leading: Container(
          margin: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 3, color: AppColors.secondary),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.secondary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                menu.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 200,
                  width: double.infinity,
                  color: AppColors.textSecondary,
                  child: const Icon(Icons.fastfood, size: 100),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nom
            Text(
              menu.itemName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Catégorie
            Text(
              menu.itemCategory,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            // Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(menu.description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 16),
            // Ingrédients
            if (menu.ingredients.isNotEmpty) ...[
              const Text(
                'Ingrédients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: menu.ingredients
                    .map((ing) => Chip(label: Text(ing)))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            // Quantité
            if (widget.isOrderMode) ...[
              const Text(
                'Quantité',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: AppColors.secondary,
                        ),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.secondary),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Total : ${totalPrice.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
      bottomNavigationBar: widget.isOrderMode
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.radius30),
                  topRight: Radius.circular(AppDimens.radius30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryLight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : Text(
                          'Passer commande',
                          style: TextStyle(color: AppColors.background),
                        ),
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _placeOrder() async {
    setState(() => _isLoading = true);

    try {
      OrderApiService();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande passée !'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context); // Retour à la page précédente
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
