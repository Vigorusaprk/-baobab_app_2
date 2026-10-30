import 'dart:math';
import 'discover_entry.dart';
import 'home_feed.dart';

/// Place les campagnes actives à cadence fixe sans répéter un voisin.
class DiscoverAdScheduler {
  DiscoverAdScheduler({required Random random}) : _random = random;

  final Random _random;
  List<FeaturedBusiness> _campaignOrder = [];

  List<DiscoverEntry> insert(
    List<DiscoverEntry> organic,
    List<FeaturedBusiness> campaigns,
    Set<String> skippedIds, {
    bool previewAdvertisement = false,
  }) {
    _setCampaignOrder(campaigns);
    if ((_campaignOrder.isEmpty && !previewAdvertisement) ||
        organic.length < 6) {
      return organic;
    }
    final result = <DiscoverEntry>[];
    String? lastCampaignId;
    var previewPending = previewAdvertisement && _campaignOrder.isEmpty;
    for (var index = 0; index < organic.length; index++) {
      result.add(organic[index]);
      final slot = index + 1;
      if (slot % 5 != 0 || slot == organic.length) continue;
      final ad = previewPending && !skippedIds.contains('ad-preview')
          ? const DiscoverEntry.previewAdvertisement()
          : _nextCampaign(skippedIds, result, lastCampaignId);
      if (ad != null) {
        result.add(ad);
        lastCampaignId = ad.campaign?.campaignId;
        if (ad.isPreviewAdvertisement) previewPending = false;
      }
    }
    return result;
  }

  void _setCampaignOrder(List<FeaturedBusiness> campaigns) {
    final active = {for (final item in campaigns) item.campaignId: item};
    if (_campaignOrder.length == active.length &&
        active.keys.toSet().containsAll(
          _campaignOrder.map((c) => c.campaignId),
        )) {
      _campaignOrder = _campaignOrder
          .map((item) => active[item.campaignId]!)
          .toList();
      return;
    }
    _campaignOrder = active.values.toList()..shuffle(_random);
  }

  DiscoverEntry? _nextCampaign(
    Set<String> skippedIds,
    List<DiscoverEntry> recent,
    String? lastCampaignId,
  ) {
    final recentIds = recent
        .skip(max(0, recent.length - 4))
        .map((e) => e.businessId)
        .toSet();
    for (final campaign in _campaignOrder) {
      final ad = DiscoverEntry.advertisement(campaign);
      if (!skippedIds.contains(ad.id) &&
          !recentIds.contains(ad.businessId) &&
          campaign.campaignId != lastCampaignId) {
        return ad;
      }
    }
    for (final campaign in _campaignOrder) {
      final ad = DiscoverEntry.advertisement(campaign);
      if (!skippedIds.contains(ad.id) &&
          campaign.campaignId != lastCampaignId) {
        return ad;
      }
    }
    for (final campaign in _campaignOrder) {
      final ad = DiscoverEntry.advertisement(campaign);
      if (!skippedIds.contains(ad.id)) return ad;
    }
    return null;
  }
}
