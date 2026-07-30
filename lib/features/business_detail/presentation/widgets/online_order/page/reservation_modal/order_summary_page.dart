import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class OrderSummaryPage extends StatelessWidget {
  final String businessName;
  final String fullName;
  final String phone;
  final DateTime? date;
  final TimeOfDay? time;
  final String peopleText;
  final String? selectedTable;
  final String selectedFloor;
  final String notes;
  final double subtotal;
  final double tax;
  final double grandTotal;
  final bool isLoading;
  final VoidCallback onConfirm;
  final VoidCallback onEditInfo;

  const OrderSummaryPage({
    Key? key,
    required this.businessName,
    required this.fullName,
    required this.phone,
    required this.date,
    required this.time,
    required this.peopleText,
    required this.selectedTable,
    required this.selectedFloor,
    required this.notes,
    required this.subtotal,
    required this.tax,
    required this.grandTotal,
    required this.isLoading,
    required this.onConfirm,
    required this.onEditInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Récapitulatif de votre réservation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'Chez $businessName',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textSecondary),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  "Nom",
                  fullName.isNotEmpty ? fullName : "Non renseigné",
                ),
                _buildSummaryRow(
                  "Téléphone",
                  phone.isNotEmpty ? phone : "Non renseigné",
                ),
                _buildSummaryRow(
                  "Date",
                  date != null
                      ? "${date!.day}/${date!.month}/${date!.year}"
                      : "Non renseignée",
                ),
                _buildSummaryRow(
                  "Heure",
                  time != null ? time!.format(context) : "Non renseignée",
                ),
                _buildSummaryRow(
                  "Nombre de personnes",
                  peopleText.isNotEmpty ? peopleText : "Non renseigné",
                ),
                _buildSummaryRow(
                  "Table",
                  selectedTable?.toString() ?? "Non sélectionnée",
                ),
                _buildSummaryRow("Étage", selectedFloor),
                if (notes.isNotEmpty) _buildSummaryRow("Notes", notes),
              ],
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textSecondary),
            ),
            child: Column(
              children: [
                _buildPriceRow(
                  "Sous-total",
                  "\$${subtotal.toStringAsFixed(2)}",
                ),
                _buildPriceRow("Taxe", "\$${tax.toStringAsFixed(2)}"),
                const SizedBox(height: 10),
                const Divider(),
                _buildPriceRow(
                  "Total",
                  "\$${grandTotal.toStringAsFixed(2)}",
                  isTotal: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoading
                    ? AppColors.textSecondary
                    : AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.white),
                        SizedBox(width: 8),
                        Text(
                          "Payer et Réserver",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: isLoading ? null : onEditInfo,
              child: const Text(
                "Modifier les informations",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.secondary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
