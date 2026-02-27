import 'package:baobabe_0_2/features/business_detail/presentation/screens/business_detail_screen.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './business_card_widget.dart';

class BusinessCardsWidget extends StatefulWidget {
  const BusinessCardsWidget({super.key});

  @override
  State<BusinessCardsWidget> createState() => _BusinessCardsWidgetState();
}

class _BusinessCardsWidgetState extends State<BusinessCardsWidget> {
  late PageController _pageController;
  double _pageOffset = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82)
      ..addListener(() {
        setState(() {
          _pageOffset = _pageController.page!;
        });
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        return BlocBuilder<BusinessBloc, BusinessState>(
          builder: (context, state) {
            if (state is BusinessLoading) {
              return const SizedBox(
                  height: 350,
                  child: Center(child: CircularProgressIndicator())
              );
            } else if (state is BusinessLoaded) {
              final uiBusinesses = state.businesses
                  .map((business) => UIBusiness(business))
                  .toList();
              return _buildStylizedScroll(uiBusinesses);
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildStylizedScroll(List<UIBusiness> uiBusinesses) {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: _pageController,
        itemCount: uiBusinesses.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          double gauss = Curves.easeInOutCubic.transform(
            (1 - (index - _pageOffset).abs().clamp(0.0, 1.0)),
          );

          return Transform.translate(
            offset: Offset(0, 20 * (1 - gauss)),
            child: Transform.scale(
              scale: 0.9 + (gauss * 0.1),
              child: Opacity(
                opacity: 0.5 + (gauss * 0.5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: _buildPerspectiveCard(uiBusinesses[index], gauss),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerspectiveCard(UIBusiness uiBusiness, double gauss) {
    return GestureDetector(
      onTap: () => _navigateToBusinessDetail(context, uiBusiness.business.id),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF254D32).withOpacity(0.2 * gauss),
              blurRadius: 25 * gauss,
              offset: Offset(0, 15 * gauss),
            ),
          ],
        ),
        child: BusinessCardWidget(uiBusiness: uiBusiness),
      ),
    );
  }

  void _navigateToBusinessDetail(BuildContext context, String businessId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BusinessDetailScreen(businessId: businessId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }
}