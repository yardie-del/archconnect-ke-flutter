import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/architect_tier.dart';
import '../models/payout.dart';
import '../widgets/withdraw_dialog.dart';
import '../widgets/wallet_helpers.dart';

const _mpesaGreen = mpesaGreen;
const _mpesaGreenContainer = mpesaGreenContainer;
const _kenyaRed = kenyaRed;
const _slateDark = slateDark;
const _slateMuted = slateMuted;
const _cardBorder = cardBorder;

/// Dart port of the Kotlin `ArchitectWalletScreen`.
///
/// Shows the wallet balance, a breakdown of how the tier commission is
/// applied to a project fee, and recent payout history. Tapping
/// "Withdraw Funds" opens [WithdrawDialog], which now supports both
/// M-Pesa and Bank Transfer (extended from the original M-Pesa-only flow).
class ArchitectWalletScreen extends StatefulWidget {
  const ArchitectWalletScreen({
    super.key,
    required this.architectId,
    required this.architectName,
    required this.tier,
    required this.totalRevenueKsh,
    required this.payouts,
    this.onPayoutConfirmed,
  });

  final String architectId;
  final String architectName;
  final ArchitectTier tier;
  final int totalRevenueKsh;
  final List<Payout> payouts;

  /// Called when the user confirms a withdrawal in the dialog. Wire this
  /// to your repository/backend call once that layer exists.
  final ValueChanged<Payout>? onPayoutConfirmed;

  @override
  State<ArchitectWalletScreen> createState() => _ArchitectWalletScreenState();
}

class _ArchitectWalletScreenState extends State<ArchitectWalletScreen> {
  static const _sampleProjectFeeKsh = 100000;

  @override
  Widget build(BuildContext context) {
    final rate = widget.tier.defaultCommissionRate;
    final commissionKsh = (_sampleProjectFeeKsh * rate).toInt();
    const feeKsh = 25;
    final netKsh = _sampleProjectFeeKsh - commissionKsh - feeKsh;

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBalanceCard(context),
          const SizedBox(height: 14),
          _buildBreakdownCard(rate, commissionKsh, feeKsh, netKsh),
          const SizedBox(height: 14),
          const Text(
            'Recent Payout Transactions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _slateDark),
          ),
          const SizedBox(height: 8),
          if (widget.payouts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No payouts yet.', style: TextStyle(color: _slateMuted)),
            )
          else
            ...widget.payouts.map(_buildPayoutRow),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Card(
      color: _mpesaGreen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'WALLET BALANCE',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Instant Payout',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatKsh(widget.totalRevenueKsh),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openWithdrawDialog,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _mpesaGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.account_balance_wallet, size: 16),
                label: const Text('Withdraw Funds', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownCard(double rate, int commissionKsh, int feeKsh, int netKsh) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Tier Payout Breakdown (${widget.tier.title})',
              style: const TextStyle(fontWeight: FontWeight.bold, color: _slateDark),
            ),
            const Text(
              'Calculated automatically upon client milestone sign-off.',
              style: TextStyle(fontSize: 12, color: _slateMuted),
            ),
            const SizedBox(height: 10),
            _breakdownRow('Gross Project Fee', '100.0%', formatKsh(_sampleProjectFeeKsh), _slateDark),
            _breakdownRow(
              '${widget.tier.title} Tier Commission',
              '-${(rate * 100).toInt()}%',
              '-${formatKsh(commissionKsh)}',
              _kenyaRed,
            ),
            _breakdownRow('Platform Escrow Custody', 'Included', 'Ksh 0', _mpesaGreen),
            _breakdownRow('Payout Processing Fee', 'Fixed', '-Ksh $feeKsh', _slateMuted),
            const Divider(height: 20),
            _breakdownRow(
              'Net Disbursed to Architect',
              '${(100 - rate * 100).toInt()}%',
              formatKsh(netKsh),
              _mpesaGreen,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, String pct, String amount, Color color, {bool isBold = false}) {
    final style = TextStyle(
      color: color,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: isBold ? 13 : 12,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Row(children: [Text(pct, style: style), const SizedBox(width: 10), Text(amount, style: style)]),
        ],
      ),
    );
  }

  Widget _buildPayoutRow(Payout payout) {
    final dateStr = DateFormat('dd MMM yyyy').format(payout.date);
    final ref = payout.method == PayoutMethod.mpesa ? payout.mpesaB2cRef : payout.bankAccountNumber;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _mpesaGreenContainer,
                  child: const Icon(Icons.arrow_outward, color: _mpesaGreen, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payout.projectTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(
                      '${payout.method.label} • Ref: $ref • $dateStr',
                      style: const TextStyle(fontSize: 10, color: _slateMuted),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('+${formatKsh(payout.netReceivedKsh)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _mpesaGreen)),
                Text('Fee: Ksh ${payout.feeKsh}', style: const TextStyle(fontSize: 9.5, color: _slateMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWithdrawDialog() async {
    final result = await showDialog<Payout>(
      context: context,
      builder: (_) => WithdrawDialog(
        architectId: widget.architectId,
        architectName: widget.architectName,
      ),
    );
    if (result != null) {
      widget.onPayoutConfirmed?.call(result);
    }
  }
}