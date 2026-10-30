import 'discover_entry.dart';

/// Une page du flux d'offres Découvrir renvoyée par `get-home`.
class DiscoverPage {
  const DiscoverPage({this.items = const [], this.hasMore = false});

  final List<DiscoverEntry> items;
  final bool hasMore;
}
