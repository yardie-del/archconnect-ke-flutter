import 'package:flutter/material.dart';
import '../models/bid.dart';
import '../models/escrow_transaction.dart';
import 'wallet_helpers.dart';

/// Shown when a client taps "Accept & Pay Escrow" on a bid. Simulates
/// paying the quoted amount into escrow via bank transfer (replacing the
/// original M-Pesa STK-push simulation). No real money moves — this is a
/// mocked confirmation for the educational build.
class EscrowFundingDialog extends StatelessWidget {
  const EscrowFundingDialog({
    super.key,
    required this.projectId,
    required this.projectTitle,
    required this.clientId,
    required this.clientName,
    required this.architectId,
    required this.bid,
  });

  final String projectId;
  final String projectTitle;
  final String clientId;
  final String clientName;
  final String architectId;
  final Bid bid;

  @override
  Widget build(BuildContext context) {
    final rate = bid.architectTier.defaultCommissionRate;
    final commission = (bid.amountKsh * rate).toInt();
    const fee = 25;
    final net = bid.amountKsh - commission - fee;

    return AlertDialog(
      title: const Text('Fund Escrow via Bank Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This amount will be held securely in escrow and released to the '
            'architect only once you approve each project milestone.',
            style: TextStyle(fontSize: 11, color: slateMuted),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount to Transfer', style: TextStyle(fontSize: 12, color: slateMedium)),
              Text(formatKsh(bid.amountKsh), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'A simulated bank transfer confirmation would appear here. '
            'Tap confirm to simulate a successful transfer.',
            style: TextStyle(fontSize: 10.5, color: slateMuted, fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: mpesaGreen),
          onPressed: () {
            final tx = EscrowTransaction(
              projectId: projectId,
              projectTitle: projectTitle,
              clientId: clientId,
              clientName: clientName,
              architectId: architectId,
              architectName: bid.architectName,
              amountKsh: bid.amountKsh,
              bankRef: 'BNK-${DateTime.now().millisecondsSinceEpoch}',
              tierCommissionRate: rate,
              commissionAmountKsh: commission,
              bankTransferFeeKsh: fee,
              netPayoutKsh: net,
            );
            Navigator.of(context).pop(tx);
          },
          child: const Text('Confirm Bank Transfer'),
        ),
      ],
    );
  }
}