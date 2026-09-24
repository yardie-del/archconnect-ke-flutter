import 'package:flutter/material.dart';
import 'wallet_helpers.dart';

/// Ported from the Kotlin `EscrowProtectionBanner` composable.
/// Reassures the client that funds are held safely until milestone approval.
class EscrowProtectionBanner extends StatelessWidget {
  const EscrowProtectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mpesaGreenContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: mpesaGreen.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield, color: mpesaGreen, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Escrow Protected',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: kenyaGreenPrimary)),
                SizedBox(height: 2),
                Text(
                  'Your payment is held securely and only released to the architect once you approve each milestone.',
                  style: TextStyle(fontSize: 11, color: slateMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}