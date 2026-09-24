import 'package:flutter/material.dart';
import '../models/bid.dart';
import '../models/escrow_transaction.dart';
import '../widgets/escrow_funding_dialog.dart';
import '../widgets/tier_badge.dart';
import '../widgets/wallet_helpers.dart';
import 'escrow_status_screen.dart';

/// Dart port of the Kotlin `BidItemView`, wrapped in a screen listing every
/// bid a client has received on their posted project. Accepting a bid opens
/// [EscrowFundingDialog] (bank transfer) and, on confirmation, pushes
/// [EscrowStatusScreen] to track the held funds through to release.
class BidReviewScreen extends StatelessWidget {
  const BidReviewScreen({
    super.key,
    required this.projectId,
    required this.projectTitle,
    required this.clientId,
    required this.clientName,
    required this.bids,
    this.onAcceptBid,
  });

  final String projectId;
  final String projectTitle;
  final String clientId;
  final String clientName;
  final List<Bid> bids;

  /// Optional extra hook, called after the escrow is funded (e.g. to
  /// update a parent's state). Navigation to the status screen happens
  /// regardless.
  final ValueChanged<EscrowTransaction>? onAcceptBid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bids on "$projectTitle"')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${bids.length} architects have bid on this project',
              style: const TextStyle(fontSize: 12, color: slateMuted)),
          const SizedBox(height: 12),
          if (bids.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No bids yet. Check back soon.', style: TextStyle(color: slateMuted)),
            )
          else
            ...bids.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BidCard(bid: b, onAcceptAndPay: () => _acceptBid(context, b)),
                )),
        ],
      ),
    );
  }

  Future<void> _acceptBid(BuildContext context, Bid bid) async {
    final tx = await showDialog<EscrowTransaction>(
      context: context,
      builder: (_) => EscrowFundingDialog(
        projectId: projectId,
        projectTitle: projectTitle,
        clientId: clientId,
        clientName: clientName,
        architectId: bid.projectId, // placeholder until real architect id is wired up
        bid: bid,
      ),
    );
    if (tx == null || !context.mounted) return;
    onAcceptBid?.call(tx);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => EscrowStatusScreen(transaction: tx)));
  }
}

class _BidCard extends StatelessWidget {
  const _BidCard({required this.bid, required this.onAcceptAndPay});
  final Bid bid;
  final VoidCallback onAcceptAndPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: slateSurfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cardBorder),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bid.architectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: slateDark)),
                    const SizedBox(height: 4),
                    TierBadge(tier: bid.architectTier, isBoraqsVerified: bid.isBoraqsVerified),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatKsh(bid.amountKsh),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kenyaGreenPrimary)),
                  Text('Delivery in ${bid.deliveryDays} days', style: const TextStyle(fontSize: 10, color: slateMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('"${bid.proposalNote}"', style: const TextStyle(fontSize: 11, color: slateMedium, height: 1.25)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: FilledButton.icon(
              onPressed: onAcceptAndPay,
              style: FilledButton.styleFrom(backgroundColor: mpesaGreen),
              icon: const Icon(Icons.lock, size: 14),
              label: Text('Accept & Pay Escrow (${formatKsh(bid.amountKsh)})',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}