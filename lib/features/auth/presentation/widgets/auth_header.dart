import 'dart:math' as math;

import 'package:baobabe_0_2/core/constants/icon_link.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

const List<String> _kBackdropAssets = [
  'assets/icons/cooking-pot-duotone.svg',
  'assets/icons/car-svgrepo-com.svg',
  'assets/icons/bedroom-8-svgrepo-com.svg',
  'assets/icons/spa-svgrepo-com.svg',
  'assets/icons/movie-svgrepo-com.svg',
  'assets/icons/shop-svgrepo-com.svg',
  'assets/icons/olive-svgrepo-com.svg',
  'assets/icons/menu-food-svgrepo-com.svg',
];

/// One small glyph scattered inside the backdrop disc.
class _BackdropGlyph {
  _BackdropGlyph({
    required this.asset,
    required this.dx,
    required this.dy,
    required this.size,
    required this.phase,
  });

  final String asset;
  final double dx;
  final double dy;
  final double size;
  final double phase;
}

/// Fills an annulus (ring) around the centered logo with many small glyphs,
/// using a sunflower/phyllotaxis distribution so they spread out evenly
/// instead of clustering — that's what gives the "field of icons" look
/// without literally instantiating an unreasonable number of widgets.
List<_BackdropGlyph> _buildBackdrop({
  required double discRadius,
  required double innerRadius,
  required int count,
}) {
  const goldenAngle = 2.399963; // radians
  final glyphs = <_BackdropGlyph>[];
  for (var i = 0; i < count; i++) {
    final t = i / count;
    final radius = innerRadius + (discRadius - innerRadius) * math.sqrt(t);
    final angle = i * goldenAngle;
    final dx = math.cos(angle) * radius;
    final dy = math.sin(angle) * radius;
    final asset = _kBackdropAssets[i % _kBackdropAssets.length];
    final size = 12.0 + (i % 5) * 2.5;
    glyphs.add(
      _BackdropGlyph(
        asset: asset,
        dx: dx,
        dy: dy,
        size: size,
        phase: i * 0.6,
      ),
    );
  }
  return glyphs;
}

class AuthHeader extends StatefulWidget {
  const AuthHeader({super.key});

  @override
  State<AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<AuthHeader>
    with SingleTickerProviderStateMixin {
  static const double _discRadius = 140;
  static const double _innerRadius = 58;

  late final AnimationController _controller;
  late final List<_BackdropGlyph> _glyphs;

  @override
  void initState() {
    super.initState();
    _glyphs = _buildBackdrop(
      discRadius: _discRadius,
      innerRadius: _innerRadius,
      count: 56,
    );
    // repeat(reverse: true) is the "loop back and forth": once the
    // animation reaches the end it plays itself backwards to the start
    // instead of jumping, so the motion never has a hard cut.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: _discRadius * 2,
          height: _discRadius * 2,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_controller.value);
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (final glyph in _glyphs)
                    Transform.translate(
                      offset: Offset(glyph.dx, glyph.dy),
                      child: Opacity(
                        opacity:
                            0.08 + 0.08 * math.sin(t * math.pi + glyph.phase).abs(),
                        child: Transform.rotate(
                          angle: math.sin(t * math.pi + glyph.phase) * 0.3,
                          child: SvgPicture.asset(
                            glyph.asset,
                            width: glyph.size,
                            height: glyph.size,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Transform.scale(
                    scale: 1 + (t * 0.04),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A0F2E20),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        IconLink.appIcon,
                        height: 48,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bienvenue',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        const Text(
          'Heureux de vous revoir !',
          style: TextStyle(fontSize: 16, color: AppColors.secondary),
        ),
      ],
    );
  }
}
