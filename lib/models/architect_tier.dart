/// Ported from the Kotlin `ArchitectTier` enum. Drives subscription fee,
/// commission rate, and display title across the app.
enum ArchitectTier {
  diamond('Diamond', 4999, 0.20),
  gold('Gold', 3999, 0.25),
  silver('Silver', 1999, 0.30),
  bronze('Bronze', 499, 0.35);

  const ArchitectTier(this.title, this.subscriptionFeeKsh, this.defaultCommissionRate);

  final String title;
  final int subscriptionFeeKsh;

  /// Kept as originally set (tiered), per project decision — not flattened
  /// to a single rate.
  final double defaultCommissionRate;
}