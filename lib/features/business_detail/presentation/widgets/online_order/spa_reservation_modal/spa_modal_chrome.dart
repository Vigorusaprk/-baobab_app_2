import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SpaModalHeader extends StatelessWidget {
  final bool isSmallScreen;
  final double titleFontSize;
  final String title;
  final String businessName;
  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const SpaModalHeader({
    Key? key,
    required this.isSmallScreen,
    required this.titleFontSize,
    required this.title,
    required this.businessName,
    required this.showBack,
    required this.onBack,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: isSmallScreen ? 18 : 24),
              onPressed: onBack,
            )
          else
            SizedBox(width: isSmallScreen ? 40 : 48),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
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
            icon: Icon(Icons.close, color: AppColors.primary, size: isSmallScreen ? 18 : 24),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class SpaModalProgressIndicator extends StatelessWidget {
  final bool isSmallScreen;
  final int currentPage;

  const SpaModalProgressIndicator({Key? key, required this.isSmallScreen, required this.currentPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
