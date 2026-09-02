import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:flutter/material.dart';

/// La coche de réussite : un disque qui surgit, un halo qui se dilate, et une
/// coche **qui se trace**.
///
/// Une icône qui apparaît d'un coup dit « voilà une icône ». Une coche dont
/// on voit le trait se faire dit « c'est validé, à l'instant » — c'est la
/// différence entre décorer un écran et confirmer une action.
///
/// Trois temps qui se chevauchent, sur [AppMotion.calm] × 3 :
///
/// | part de l'animation | ce qui bouge |
/// |---|---|
/// | 0 → 45 % | le disque grandit, avec un léger dépassement |
/// | 25 → 70 % | la coche se trace |
/// | 20 → 100 % | le halo se dilate et s'efface |
///
/// [onFinished] est appelé à la fin. Il sert à enchaîner — refermer une
/// feuille, par exemple — sans qu'un appelant ait à deviner la durée.
///
/// Mouvement réduit : la coche est simplement là, et [onFinished] part tout
/// de suite. Le réglage existe pour les personnes que le mouvement gêne ; il
/// ne doit pas leur coûter une attente.
class SuccessCheck extends StatefulWidget {
  const SuccessCheck({
    super.key,
    this.size = 72,
    this.color,
    this.onColor,
    this.onFinished,
  });

  /// Diamètre du disque. Le halo déborde de moitié en plus.
  final double size;

  /// Par défaut la couleur d'action du thème.
  final Color? color;

  /// Couleur du trait. Par défaut celle qui se lit sur [color].
  final Color? onColor;

  final VoidCallback? onFinished;

  @override
  State<SuccessCheck> createState() => _SuccessCheckState();
}

class _SuccessCheckState extends State<SuccessCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.calm * 3,
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (AppMotion.reduced(context)) {
      _controller.value = 1;
      widget.onFinished?.call();
      return;
    }
    _controller.forward().then((_) {
      if (mounted) widget.onFinished?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Ramène une sous-partie de l'animation sur 0 → 1.
  double _slice(double from, double to, Curve curve) {
    final raw = ((_controller.value - from) / (to - from)).clamp(0.0, 1.0);
    return curve.transform(raw);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.color ?? scheme.primary;
    final onColor = widget.onColor ?? scheme.onPrimary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final disc = _slice(0, 0.45, Curves.elasticOut);
        final stroke = _slice(0.25, 0.70, AppMotion.standard);
        final halo = _slice(0.20, 1, AppMotion.exit);

        return SizedBox(
          width: widget.size * 1.6,
          height: widget.size * 1.6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Le halo : il part du bord du disque et s'efface en
              // s'écartant. C'est ce qui donne l'impression d'un « clic »
              // plutôt que d'une image qui s'affiche.
              Opacity(
                opacity: (1 - halo) * 0.28,
                child: Container(
                  width: widget.size * (1 + halo * 0.6),
                  height: widget.size * (1 + halo * 0.6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Transform.scale(
                scale: disc,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                  child: CustomPaint(
                    painter: _CheckPainter(progress: stroke, color: onColor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Trace la coche, du premier au dernier point, selon [progress].
class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    // Coordonnées relatives : la coche suit la taille du disque.
    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.68)
      ..lineTo(size.width * 0.73, size.height * 0.36);

    // `PathMetric.extractPath` donne le début du tracé : c'est ce qui fait
    // que le trait se **dessine** au lieu d'apparaître.
    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);

    canvas.drawPath(
      drawn,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) =>
      old.progress != progress || old.color != color;
}
