import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/features/order/presentation/screens/order_screen.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

class PlatDetail extends StatefulWidget {
  final MenuItem menuItem;
  final String? restaurantId;
  final String? restaurantName;
  final BusinessType? restaurantType; // Type de l'établissement
  final bool isOrderMode;

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
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    menu.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
                      );
                    },
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        menu.itemName,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        menu.itemCategory,
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (menu.rating > 0) ...[
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text('${menu.rating}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 16),
                    ],
                    Text(
                      '${menu.price.toStringAsFixed(2)} \$',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  menu.description,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
                ),
                const SizedBox(height: 20),
                if (menu.ingredients.isNotEmpty) ...[
                  const Text('Ingrédients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: menu.ingredients.map((ingredient) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(ingredient, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                const Text('Quantité', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                            color: _quantity > 1 ? AppColors.primary : Colors.grey,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => setState(() => _quantity++),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total: ${totalPrice.toStringAsFixed(2)} \$',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isOrderMode
          ? _isLoading
          ? null
          : Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Passer commande'),
                ),
              ),
            ],
          ),
        ),
      )
          : null, // pas de bouton en mode consultation
    );
  }

  Future<void> _placeOrder() async {
    setState(() => _isLoading = true);

    final String tempId = '${widget.menuItem.itemName}_${widget.menuItem.price}';

    final orderItem = OrderItem(
      menuItemId: tempId,
      name: widget.menuItem.itemName,
      price: widget.menuItem.price,
      quantity: _quantity,
    );

    final subtotal = widget.menuItem.price * _quantity;
    const tax = 0.0;
    final total = subtotal + tax;

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      establishmentId: widget.restaurantId ?? 'restaurant_inconnu',
      establishmentName: widget.restaurantName ?? 'Restaurant',
      establishmentType: widget.restaurantType,
      orderDate: DateTime.now(),
      items: [orderItem],
      subtotal: subtotal,
      tax: tax,
      totalAmount: total,
      status: OrderStatus.pending,
      notes: null,
    );

    try {
      await OrderService.saveOrder(order);

      if (!mounted) return;

      // Message de confirmation uniquement
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande passée avec succès !'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Remettre la quantité à 1 (optionnel)
      setState(() {
        _quantity = 1;
      });

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
