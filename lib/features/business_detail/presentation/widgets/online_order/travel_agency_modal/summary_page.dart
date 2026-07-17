import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  final bool isSmallScreen;
  final double horizontalPadding;
  final String fullName;
  final String phone;
  final String? destination;
  final DateTime? departureDate;
  final int numberOfPassengers;
  final String notes;
  final double totalAmount;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  const SummaryPage({
    Key? key,
    required this.isSmallScreen,
    required this.horizontalPadding,
    required this.fullName,
    required this.phone,
    required this.destination,
    required this.departureDate,
    required this.numberOfPassengers,
    required this.notes,
    required this.totalAmount,
    required this.isLoading,
    required this.onBack,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif de votre billet', style: TextStyle(fontSize: isSmallScreen ? 18 : 20, fontWeight: FontWeight.bold)),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildInfoContainer(isSmallScreen, [
                    _buildSummaryRow("Nom", fullName, isSmallScreen),
                    _buildSummaryRow("Téléphone", phone, isSmallScreen),
                    _buildSummaryRow("Destination", destination ?? "", isSmallScreen),
                    _buildSummaryRow("Date de départ", departureDate != null ? "${departureDate!.day}/${departureDate!.month}/${departureDate!.year}" : "", isSmallScreen),
                    _buildSummaryRow("Passagers", "$numberOfPassengers", isSmallScreen),
                    if (notes.isNotEmpty) _buildSummaryRow("Notes", notes, isSmallScreen),
                  ]),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildInfoContainer(isSmallScreen, [
                    _buildPriceRow(context, "Total Billet(s)", "\$${totalAmount.toStringAsFixed(2)}", isSmallScreen, isTotal: true),
                  ]),
                ],
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildActionButtons(isSmallScreen),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(bool isSmallScreen, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4.0 : 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: isSmallScreen ? 12 : 14)),
          Expanded(child: Text(value, style: TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w500), textAlign: TextAlign.end, maxLines: 2, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value, bool isSmallScreen, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 3.0 : 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? (isSmallScreen ? 16 : 18) : (isSmallScreen ? 14 : 16), fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isTotal ? (isSmallScreen ? 16 : 18) : (isSmallScreen ? 14 : 16), fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Theme.of(context).colorScheme.primary : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    if (isSmallScreen) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onConfirm,
              style: ElevatedButton.styleFrom(backgroundColor: isLoading ? Colors.grey : Colors.green, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.white, size: 20), SizedBox(width: 8), Text("Confirmer le Voyage", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))]),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: isLoading ? null : onBack,
              child: Text("Modifier les informations", style: TextStyle(fontSize: 14, color: Colors.grey)),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: TextButton(onPressed: isLoading ? null : onBack, style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: Text("Modifier", style: TextStyle(fontSize: 16, color: Colors.grey)))),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : onConfirm,
              style: ElevatedButton.styleFrom(backgroundColor: isLoading ? Colors.grey : Colors.green, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.white, size: 20), SizedBox(width: 8), Text("Confirmer", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))]),
            ),
          ),
        ],
      );
    }
  }
}
