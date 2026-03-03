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

  static const double _viewportFraction = 0.82;
  static const double _cardHeight = 490;
  static const double _cardVerticalPadding = 20;
  static const double _cardHorizontalPadding = 10;
  static const double _baseScale = 0.9;
  static const double _scaleFactor = 0.1;
  static const double _baseOpacity = 0.5;
  static const double _opacityFactor = 0.5;
  static const double _verticalOffsetFactor = 20;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction)
      ..addListener(_onPageChanged);
  }

  void _onPageChanged() {
    setState(() {
      _pageOffset = _pageController.page!;
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // On écoute le CategoryBloc sans condition de rebuild (peu coûteux)
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        return BlocBuilder<BusinessBloc, BusinessState>(
          // Optimisation : on ne rebuild que si l'état du business change vraiment
          buildWhen: (previous, current) {
            if (previous.runtimeType != current.runtimeType) return true;
            if (current is BusinessLoaded && previous is BusinessLoaded) {
              return previous.businesses != current.businesses;
            }
            return false;
          },
          builder: (context, state) {
            if (state is BusinessLoading) {
              return const SizedBox(
                height: _cardHeight,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (state is BusinessLoaded) {
              final uiBusinesses = state.businesses
                  .map((business) => UIBusiness(business))
                  .toList();
              return _buildStylizedScroll(uiBusinesses);
            } else if (state is BusinessError) {
              return SizedBox(
                height: _cardHeight,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur : ${state.message}',
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<BusinessBloc>().add(
                          LoadBusinesses(),
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildStylizedScroll(List<UIBusiness> uiBusinesses) {
    if (uiBusinesses.isEmpty) {
      return SizedBox(
        height: _cardHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun établissement disponible',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: _cardHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: uiBusinesses.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final distance = (index - _pageOffset).abs().clamp(0.0, 1.0);
          final gauss = Curves.easeInOutCubic.transform(1 - distance);

          final verticalOffset = _verticalOffsetFactor * (1 - gauss);
          final scale = _baseScale + (gauss * _scaleFactor);
          final opacity = _baseOpacity + (gauss * _opacityFactor);

          return Transform.translate(
            offset: Offset(0, verticalOffset),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _cardHorizontalPadding,
                    vertical: _cardVerticalPadding,
                  ),
                  child: _buildPerspectiveCard(uiBusinesses[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerspectiveCard(UIBusiness uiBusiness) {
    return GestureDetector(
      onTap: () => _navigateToBusinessDetail(context, uiBusiness.business.id),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          // Ombre légère constante (peut être retirée si vous préférez)
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF254D32).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
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