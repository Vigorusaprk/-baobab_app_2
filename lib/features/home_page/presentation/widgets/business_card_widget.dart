import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/data/review_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui';

class BusinessCardWidget extends StatelessWidget {
  final UIBusiness uiBusiness;

  const BusinessCardWidget({super.key, required this.uiBusiness});

  @override
  Widget build(BuildContext context) {
    final reviewService = ReviewApiService();
    return FutureBuilder<List<Review>>(
      future: reviewService.getReviews(uiBusiness.business.id),
      builder: (context, snapshot) {
        // Calcul de la note moyenne réelle
        double rating;
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final reviews = snapshot.data!;
          rating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
        } else {
          rating = uiBusiness.business.rating; // fallback
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: uiBusiness.categoryColor, width: 2.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned.fill(child: _buildBackgroundImage()),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildCategoryBadge(),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildInfoOverlay(rating),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundImage() {
    final hasImage = uiBusiness.business.bgImg != null && uiBusiness.business.bgImg!.isNotEmpty;
    final Color color = uiBusiness.categoryColor;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: hasImage ? null : color,
      ),
      child: hasImage
          ? ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          uiBusiness.business.bgImg!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialsContainer(color);
          },
        ),
      )
          : _buildInitialsContainer(color),
    );
  }

  Widget _buildInitialsContainer(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      width: double.infinity,
      height: 200,
      child: Center(
        child: Icon(
          uiBusiness.categoryIcon,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final businessData = uiBusiness.business;

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(color: uiBusiness.categoryColor.withOpacity(0.7), width: 5.5),
          ),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: businessData.profilImg != null && businessData.profilImg!.isNotEmpty
                ? Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(businessData.profilImg!),
                    fit: BoxFit.cover,
                  )
              ),
            )
                : Icon(uiBusiness.categoryIcon, size: 45, color: uiBusiness.categoryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoOverlay(double rating) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(child: _buildBackgroundOrbes()),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            uiBusiness.business.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        _buildRatingBadge(rating),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/location-svgrepo-com (1).svg",
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            uiBusiness.business.address,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbes() {
    return Container(
      padding: EdgeInsets.all(0.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: 40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryLight.withOpacity(0.25),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withOpacity(0.4),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryDark.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}