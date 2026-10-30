import 'dart:async';
import 'package:baobabe_0_2/core/services/metrics_service.dart';
import 'package:flutter/material.dart';

/// Compte une vue commerce ou offre après une seconde d'exposition.
class DiscoverViewTracker extends StatefulWidget {
  const DiscoverViewTracker({
    super.key,
    required this.trackingId,
    required this.offerId,
    required this.businessId,
    required this.visible,
    this.onImpression,
  });

  final String trackingId;
  final String? offerId;
  final String? businessId;
  final bool visible;
  final VoidCallback? onImpression;

  static final Set<String> _seenThisSession = {};

  @override
  State<DiscoverViewTracker> createState() => _DiscoverViewTrackerState();
}

class _DiscoverViewTrackerState extends State<DiscoverViewTracker> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant DiscoverViewTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackingId != widget.trackingId ||
        oldWidget.offerId != widget.offerId ||
        oldWidget.visible != widget.visible) {
      _timer?.cancel();
      _schedule();
    }
  }

  void _schedule() {
    final id = widget.trackingId;
    if (!widget.visible ||
        widget.businessId == null ||
        widget.businessId!.isEmpty ||
        DiscoverViewTracker._seenThisSession.contains(id)) {
      return;
    }
    _timer = Timer(const Duration(seconds: 1), () {
      if (!mounted ||
          !widget.visible ||
          DiscoverViewTracker._seenThisSession.contains(id)) {
        return;
      }
      final businessId = widget.businessId;
      if (businessId == null || businessId.isEmpty) return;
      if (!DiscoverViewTracker._seenThisSession.add(id)) return;
      final impression = widget.onImpression;
      if (impression != null) {
        impression();
      } else {
        MetricsService.instance.view(
          businessId: businessId,
          offerId: widget.offerId,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
