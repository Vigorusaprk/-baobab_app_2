/// Tranche de prix affichée à l'utilisateur (façon € / €€ / €€€).
/// [maxAmount] sert de borne haute approximative pour matcher les
/// établissements qui n'ont qu'un prix moyen indicatif, pas de tranche.
enum PriceTier {
  low('€', 0, 15000), // Ajuste les bornes selon ta devise (ex: FC)
  medium('€€', 15000, 40000),
  high('€€€', 40000, double.infinity);

  final String label;
  final double minAmount;
  final double maxAmount;

  const PriceTier(this.label, this.minAmount, this.maxAmount);
}
