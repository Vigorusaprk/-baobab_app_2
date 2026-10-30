import 'dart:math';
import 'discover_entry.dart';
import 'discover_ad_scheduler.dart';
import 'home_feed.dart';

/// Varie les cartes d'une session et insère les campagnes reçues de get-home.
class DiscoverFeedComposer {
  DiscoverFeedComposer({Random? random}) : _random = random ?? Random.secure() {
    _adScheduler = DiscoverAdScheduler(random: _random);
  }

  final Random _random;
  late final DiscoverAdScheduler _adScheduler;
  final List<DiscoverEntry> _ordered = [];

  List<DiscoverEntry> compose(
    List<DiscoverEntry> incoming,
    List<FeaturedBusiness> campaigns, {
    Set<String> skippedIds = const {},
    bool previewAdvertisement = false,
  }) {
    final activeIds = incoming.map((item) => item.id).toSet();
    _ordered.removeWhere((item) => !activeIds.contains(item.id));
    final known = _ordered.map((item) => item.id).toSet();
    final fresh = incoming.where((item) => !known.contains(item.id)).toList();
    _ordered.addAll(_diversify(fresh, _recentIds));
    return _adScheduler.insert(
      _ordered,
      campaigns,
      skippedIds,
      previewAdvertisement: previewAdvertisement,
    );
  }

  List<String> get _recentIds => _ordered
      .skip(max(0, _ordered.length - 4))
      .map((item) => item.businessId)
      .toList();

  List<DiscoverEntry> _diversify(
    List<DiscoverEntry> items,
    List<String> recent,
  ) {
    final groups = <String, List<DiscoverEntry>>{};
    for (final item in items) {
      groups.putIfAbsent(item.businessId, () => []).add(item);
    }
    for (final group in groups.values) {
      group.shuffle(_random);
    }
    final groupOrder = groups.keys.toList()..shuffle(_random);
    final ordered = <DiscoverEntry>[];
    final history = [...recent];
    while (groups.values.any((group) => group.isNotEmpty)) {
      final previousLength = ordered.length;
      for (final id in groupOrder) {
        if (groups[id]!.isEmpty || history.contains(id)) continue;
        ordered.add(groups[id]!.removeLast());
        history.add(id);
        if (history.length > 4) history.removeAt(0);
      }
      if (ordered.length == previousLength) {
        final id = groupOrder.firstWhere((key) => groups[key]!.isNotEmpty);
        ordered.add(groups[id]!.removeLast());
        history.add(id);
        if (history.length > 4) history.removeAt(0);
      }
    }
    if (items.length > 1 && _sameOrder(items, ordered)) {
      ordered.add(ordered.removeAt(0));
    }
    return ordered;
  }

  bool _sameOrder(List<DiscoverEntry> a, List<DiscoverEntry> b) =>
      a.length == b.length &&
      List.generate(a.length, (i) => a[i].id == b[i].id).every((same) => same);
}
