import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LocationAndProfile extends StatelessWidget {
  const LocationAndProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppDimens.PADDING_20, right: AppDimens.PADDING_20, top: AppDimens.PADDING_20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.accent700,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildLocationIcon(),
                  const SizedBox(width: 12),
                  _buildLocationText(),
                ],
              ),
            ),
            _buildHeaderNotification()
          ],
        ),
      ),
    );
  }

  Widget _buildLocationIcon() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:  AppColors.canvasBackground,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        'assets/icons/location-svgrepo-com (1).svg',
        height: 20,
        width: 20,
        colorFilter: const ColorFilter.mode(
          AppColors.accent700,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildLocationText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Current Location",
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textOnSecondary,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        Text(
          "Miami Beach, FL 331..",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textOnSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderNotification() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.canvasBackground,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        'assets/icons/notifications.svg',
        height: 25,
        width: 25,
        colorFilter: const ColorFilter.mode(
          AppColors.accent700,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}