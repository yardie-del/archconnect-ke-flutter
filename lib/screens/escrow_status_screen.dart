import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/escrow_transaction.dart';
import '../widgets/wallet_helpers.dart';

/// Shows a funded escrow transaction and lets the client release it to the
/// architect (simulating milestone/project sign-off). Bank-rail equivalent
/// of the Kotlin escrow release flow, which used M-Pesa B2C.
class EscrowStatusScreen extends StatefulWidget {
  const EscrowStatusScreen({
    super.key,
    required this.transaction,
    this.onReleased,
  });

  final EscrowTransaction transaction;
  final ValueChanged<EscrowTransaction>? onReleased;

  @override
  State<EscrowStatusScreen> createState() => _EscrowStatusScreenState();
}

class _EscrowStatusScreenState extends State<EscrowStatusScreen> {
  late EscrowTransaction _tx = widget.transaction;

  @override
  Widget build(BuildContext context) {
    final isHeld = _tx.status == EscrowStatus.heldInEscrow;
    final isReleased = _tx.status == EscrowStatus.releasedToArchitect;

    return Scaffold(
      appBar: AppBar(title: const Text('Escrow Status')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: isReleased ? mpesaGreenContainer : const Color(0xFFFEF3C7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(isReleased ? Icons.check_circle : Icons.lock_clock,
                          color: isReleased ? mpesaGreen : const Color(0xFFB45309)),
                      const SizedBox(width: 8),
                      Text(_tx.status.label,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_tx.projectTitle, style: const TextStyle(fontSize: 12, color: slateMedium)),
                  const SizedBox(height: 4),
                  Text('Bank Ref: ${_tx.bankRef}', style: const TextStyle(fontSize: 10, color: slateMuted)),
                  Text('Funded: ${DateFormat('dd MMM yyyy, HH:mm').format(_tx.fundedAt)}',
                      style: const TextStyle(fontSize: 10, color: slateMuted)),
                  if (_tx.releasedAt != null)
                    Text('Released: ${DateFormat('dd MMM yyyy, HH:mm').format(_tx.releasedAt!)}',
                        style: const TextStyle(fontSize: 10, color: slateMuted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: cardBorder)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payout Breakdown', style: TextStyle(fontWeight: FontWeight.bold, color: slateDark)),
                  const SizedBox(height: 10),
                  _row('Total Held in Escrow', formatKsh(_tx.amountKsh), slateDark),
                  _row('Commission (${(_tx.tierCommissionRate * 100).toInt()}%)',
                      '-${formatKsh(_tx.commissionAmountKsh)}', kenyaRed),
                  _row('Bank Transfer Fee', '-${formatKsh(_tx.bankTransferFeeKsh)}', slateMuted),
                  const Divider(height: 20),
                  _row('Net to Architect (${_tx.architectName})', formatKsh(_tx.netPayoutKsh), mpesaGreen, bold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (isHeld)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: mpesaGreen),
                onPressed: _releaseToArchitect,
                icon: const Icon(Icons.lock_open),
                label: const Text('Approve Milestone & Release to Architect',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          else if (isReleased)
            const Center(
              child: Text('Funds have been released to the architect\'s bank account.',
                  style: TextStyle(color: slateMuted, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color, {bool bold = false}) {
    final style = TextStyle(color: color, fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 13 : 12);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }

  void _releaseToArchitect() {
    final updated = _tx.copyWith(status: EscrowStatus.releasedToArchitect, releasedAt: DateTime.now());
    setState(() => _tx = updated);
    widget.onReleased?.call(updated);
  }
}