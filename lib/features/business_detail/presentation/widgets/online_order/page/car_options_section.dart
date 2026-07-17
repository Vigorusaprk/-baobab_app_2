import 'package:flutter/material.dart';

class CarOptionsSection extends StatelessWidget {
  final bool withDriver;
  final bool includeInsurance;
  final bool needDelivery;
  final ValueChanged<bool?> onWithDriverChanged;
  final ValueChanged<bool?> onIncludeInsuranceChanged;
  final ValueChanged<bool?> onNeedDeliveryChanged;

  const CarOptionsSection({
    super.key,
    required this.withDriver,
    required this.includeInsurance,
    required this.needDelivery,
    required this.onWithDriverChanged,
    required this.onIncludeInsuranceChanged,
    required this.onNeedDeliveryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options supplémentaires',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Avec chauffeur'),
          subtitle: const Text('+50€/jour'),
          value: withDriver,
          onChanged: onWithDriverChanged,
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Assurance complète'),
          subtitle: const Text('+30€/jour'),
          value: includeInsurance,
          onChanged: onIncludeInsuranceChanged,
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Livraison'),
          subtitle: const Text('+100€ une fois'),
          value: needDelivery,
          onChanged: onNeedDeliveryChanged,
        ),
      ],
    );
  }
}
