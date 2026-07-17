import 'package:flutter/material.dart';

class ReservationModalHeader extends StatelessWidget {
  final String title;
  final String businessName;
  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const ReservationModalHeader({
    Key? key,
    required this.title,
    required this.businessName,
    required this.showBack,
    required this.onBack,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: onBack,
            ),
          if (!showBack) const SizedBox(width: 48),

          Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                businessName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
