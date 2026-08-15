import 'package:flutter/material.dart';

/// Affiché quand le filtre actif ne renvoie aucun élément.
class FeedEmptyState extends StatelessWidget {
  const FeedEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.inbox_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Rien à afficher pour le moment', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
