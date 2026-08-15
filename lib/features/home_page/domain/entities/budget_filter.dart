import 'package:baobabe_0_2/features/home_page/presentation/widgets/price_tier.dart';

/// Filtre budget. L'utilisateur peut choisir une tranche ([tier]) OU
/// affiner avec un montant précis ([minAmount]/[maxAmount]) — les deux
/// se combinent : si les deux sont renseignés, l'intersection s'applique.
class BudgetFilter {
  final PriceTier? tier;
  final double? minAmount;
  final double? maxAmount;

  const BudgetFilter({this.tier, this.minAmount, this.maxAmount});

  /// Filtre "vide" = pas de contrainte budget.
  const BudgetFilter.none() : tier = null, minAmount = null, maxAmount = null;

  bool get isActive => tier != null || minAmount != null || maxAmount != null;

  /// Vérifie si un prix moyen donné correspond au filtre actif.
  /// [averagePrice] peut être null (business sans menu_items/rooms encore
  /// renseignés) — dans ce cas on ne l'exclut pas si aucun filtre n'est
  /// actif, mais on ne peut pas confirmer le match si un filtre l'est.
  bool matches(double? averagePrice) {
    if (!isActive) return true;
    if (averagePrice == null) return false;

    if (tier != null) {
      if (averagePrice < tier!.minAmount || averagePrice > tier!.maxAmount) {
        return false;
      }
    }
    if (minAmount != null && averagePrice < minAmount!) return false;
    if (maxAmount != null && averagePrice > maxAmount!) return false;
    return true;
  }

  BudgetFilter copyWith({
    PriceTier? tier,
    bool clearTier = false,
    double? minAmount,
    double? maxAmount,
  }) {
    return BudgetFilter(
      tier: clearTier ? null : (tier ?? this.tier),
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
    );
  }
}