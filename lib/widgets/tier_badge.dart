import 'package:flutter/material.dart';
import '../models/architect_tier.dart';
import 'wallet_helpers.dart';

/// Small colored badge showing an architect's tier, with a verified
/// checkmark if BORAQS-verified. Ported from the Kotlin `TierBadge`
/// composable, used on both the profile screen and bid cards.
class TierBadge extends StatelessWidget {
  const TierBadge({super.key, required this.tier, required this.isBoraqsVerified});

  final ArchitectTier tier;
  final bool isBoraqsVerified;

  Color get _tierColor => switch (tier) {
        ArchitectTier.diamond => const Color(0xFF0EA5E9),
        ArchitectTier.gold => safariGold,
        ArchitectTier.silver => const Color(0xFF94A3B8),
        ArchitectTier.bronze => const Color(0xFFB45309),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _tierColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tier.title, style: TextStyle(color: _tierColor, fontWeight: FontWeight.bold, fontSize: 11)),
          if (isBoraqsVerified) ...[
            const SizedBox(width: 3),
            Icon(Icons.verified, size: 12, color: _tierColor),
          ],
        ],
      ),
    );
  }
}