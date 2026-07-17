import 'package:flutter/material.dart';

class TourismModalHeader extends StatelessWidget {
  final bool isSmallScreen;
  final double titleFontSize;
  final int currentPage;
  final String businessName;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const TourismModalHeader({
    Key? key,
    required this.isSmallScreen,
    required this.titleFontSize,
    required this.currentPage,
    required this.businessName,
    required this.onBack,
    required this.onClose,
  }) : super(key: key);

  static String pageTitle(int pageIndex) {
    switch (pageIndex) {
      case 0: return 'Choisir vos activités';
      case 1: return 'Informations';
      case 2: return 'Récapitulatif';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (currentPage > 0)
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).primaryColor, size: isSmallScreen ? 18 : 24),
                  onPressed: onBack,
                )
              else
                SizedBox(width: isSmallScreen ? 40 : 48),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      pageTitle(currentPage),
                      style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      businessName,
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Theme.of(context).primaryColor, size: isSmallScreen ? 18 : 24),
                onPressed: onClose,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [0, 1, 2].map((index) {
              return Container(
                width: isSmallScreen ? 6 : 8,
                height: isSmallScreen ? 6 : 8,
                margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentPage >= index ? Theme.of(context).colorScheme.primary : Colors.grey[300],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
