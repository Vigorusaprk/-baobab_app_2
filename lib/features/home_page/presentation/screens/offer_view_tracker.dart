import 'dart:async';
import 'package:baobabe_0_2/core/services/metrics_service.dart';
import 'package:flutter/material.dart';

/// Compte une vue après une seconde d'exposition, une fois par session.
class OfferViewTracker extends StatefulWidget {
  const OfferViewTracker({
    super.key,
    required this.offerId,
    required this.businessId,
    required this.visible,
    this.onImpression,
  });

  final String offerId;
  final String? businessId;
  final bool visible;
  final VoidCallback? onImpression;

  static final Set<String> _seenThisSession = {};

  @override
  State<OfferViewTracker> createState() => _OfferViewTrackerState();
}

class _OfferViewTrackerState extends State<OfferViewTracker> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant OfferViewTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offerId != widget.offerId ||
        oldWidget.visible != widget.visible) {
      _timer?.cancel();
      _schedule();
    }
  }

  void _schedule() {
    final id = widget.offerId;
    if (!widget.visible ||
        widget.businessId == null ||
        widget.businessId!.isEmpty ||
        OfferViewTracker._seenThisSession.contains(id)) {
      return;
    }
    _timer = Timer(const Duration(seconds: 1), () {
      if (!mounted ||
          !widget.visible ||
          OfferViewTracker._seenThisSession.contains(id)) {
        return;
      }
      final businessId = widget.businessId;
      if (businessId == null || businessId.isEmpty) return;
      if (!OfferViewTracker._seenThisSession.add(id)) return;
      final impression = widget.onImpression;
      if (impression != null) {
        impression();
      } else {
        MetricsService.instance.view(businessId: businessId, offerId: id);
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
