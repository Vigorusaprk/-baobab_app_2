import 'dart:math' as math;

import 'package:baobabe_0_2/core/constants/icon_link.dart';
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

/// One small glyph scattered inside the backdrop disc. Everything here is
/// fixed at construction time — nothing about a glyph's own look changes
/// frame to frame, only the whole field's rotation does (see
/// [_AuthHeaderState]), which is what keeps the animation cheap.
class _BackdropGlyph {
  _BackdropGlyph({
    required this.asset,
    required this.dx,
    required this.dy,
    required this.size,
    required this.opacity,
  });

  final String asset;
  final double dx;
  final double dy;
  final double size;
  final double opacity;
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
        opacity: 0.09 + (i % 4) * 0.02,
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
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The 56 glyphs never change how they look, so they're built once as a
    // plain static widget and handed to AnimatedBuilder's `child` — that
    // subtree is never rebuilt by the animation. Wrapped in a
    // RepaintBoundary, Flutter rasterizes it to a single cached layer, so
    // every animation frame is just re-compositing that one bitmap with a
    // new rotation matrix — cheap and GPU-driven — instead of re-painting
    // 56 vector icons at 60fps, which is what was causing the stutter.
    final glyphField = RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final glyph in _glyphs)
            Transform.translate(
              offset: Offset(glyph.dx, glyph.dy),
              child: Opacity(
                opacity: glyph.opacity,
                child: SvgPicture.asset(
                  glyph.asset,
                  width: glyph.size,
                  height: glyph.size,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final logo = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SvgPicture.asset(
        IconLink.appIcon,
        height: 48,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
    );

    return Column(
      children: [
        SizedBox(
          width: _discRadius * 2,
          height: _discRadius * 2,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              // Eased 0..1 that ping-pongs (repeat(reverse:true));
              // easeInOut gives it zero velocity at both ends, so the
              // reversal never reads as a jump.
              final t = Curves.easeInOut.transform(_controller.value);
              final fieldAngle = (t - 0.5) * 0.22; // ~ -6.3° to +6.3°
              final logoScale = 1 + (t * 0.04);

              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(angle: fieldAngle, child: glyphField),
                  Transform.scale(scale: logoScale, child: logo),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bienvenue',
          style: Theme.of(context).textTheme.displayLarge!.copyWith(
            letterSpacing: -0.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          'Heureux de vous revoir !',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
