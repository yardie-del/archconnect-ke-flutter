import 'package:flutter/material.dart';
import '../models/dispute.dart';
import '../widgets/wallet_helpers.dart';

enum _Ruling { releaseToArchitect, refundToClient }

/// Dart port of the Kotlin `AdminDisputeCenterScreen`. Lists open dispute
/// cases and lets an admin issue a ruling: release escrow to the
/// architect, or refund it to the client, with written admin notes.
class DisputeCenterScreen extends StatefulWidget {
  const DisputeCenterScreen({
    super.key,
    required this.disputes,
    this.onDisputesChanged,
  });

  final List<Dispute> disputes;
  final ValueChanged<List<Dispute>>? onDisputesChanged;

  @override
  State<DisputeCenterScreen> createState() => _DisputeCenterScreenState();
}

class _DisputeCenterScreenState extends State<DisputeCenterScreen> {
  late List<Dispute> _disputes = widget.disputes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispute Arbitration Center')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Impartial mediation covering drawing scope, timelines & escrow disbursement.',
            style: TextStyle(fontSize: 12, color: slateMuted),
          ),
          const SizedBox(height: 14),
          if (_disputes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No open disputes.', style: TextStyle(color: slateMuted)),
            )
          else
            ..._disputes.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DisputeCard(dispute: d, onArbitrate: () => _openRulingDialog(d)),
                )),
        ],
      ),
    );
  }

  Future<void> _openRulingDialog(Dispute dispute) async {
    final result = await showDialog<Dispute>(
      context: context,
      builder: (_) => _RulingDialog(dispute: dispute),
    );
    if (result == null) return;
    setState(() {
      _disputes = _disputes.map((d) => d.id == result.id ? result : d).toList();
    });
    widget.onDisputesChanged?.call(_disputes);
  }
}

class _DisputeCard extends StatelessWidget {
  const _DisputeCard({required this.dispute, required this.onArbitrate});
  final Dispute dispute;
  final VoidCallback onArbitrate;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: cardBorder)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: kenyaRed.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                  child: Text(dispute.issueType.label,
                      style: const TextStyle(color: kenyaRed, fontSize: 10.5, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: dispute.status.color.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                  child: Text(dispute.status.label,
                      style: TextStyle(color: dispute.status.color, fontSize: 10.5, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Case #${dispute.caseId} - ${dispute.projectTitle}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: slateDark)),
            Text('Client: ${dispute.clientName} vs Architect: ${dispute.architectName}',
                style: const TextStyle(fontSize: 11, color: slateMuted)),
            const SizedBox(height: 6),
            Text('"${dispute.description}"', style: const TextStyle(fontSize: 11.5, color: slateMedium, height: 1.25)),
            if (dispute.resolutionNotes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: mpesaGreenContainer.withOpacity(0.5), borderRadius: BorderRadius.circular(6)),
                child: Text('Arbitration Ruling: ${dispute.resolutionNotes}',
                    style: const TextStyle(fontSize: 11, color: kenyaGreenPrimary, fontWeight: FontWeight.w600)),
              ),
            ],
            if (dispute.status != DisputeStatus.resolved) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: FilledButton.icon(
                  onPressed: onArbitrate,
                  style: FilledButton.styleFrom(backgroundColor: kenyaRed),
                  icon: const Icon(Icons.gavel, size: 14),
                  label: const Text('Arbitrate & Issue Ruling', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RulingDialog extends StatefulWidget {
  const _RulingDialog({required this.dispute});
  final Dispute dispute;

  @override
  State<_RulingDialog> createState() => _RulingDialogState();
}

class _RulingDialogState extends State<_RulingDialog> {
  _Ruling _ruling = _Ruling.releaseToArchitect;
  final _notesController = TextEditingController(
    text: 'BORAQS technical review confirms completed drawings adhere to client requirements.',
  );

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dispute;
    return AlertDialog(
      title: const Text('Issue Dispute Arbitration Ruling', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Execute escrow distribution based on ArchConnect arbitration findings.',
                style: TextStyle(fontSize: 11, color: slateMuted)),
            const SizedBox(height: 10),
            Text('Escrow Held: ${formatKsh(d.escrowAmountKsh)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: slateDark)),
            const SizedBox(height: 10),
            RadioListTile<_Ruling>(
              value: _Ruling.releaseToArchitect,
              groupValue: _ruling,
              onChanged: (v) => setState(() => _ruling = v!),
              activeColor: mpesaGreen,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('Release ${formatKsh(d.escrowAmountKsh)} to ${d.architectName}', style: const TextStyle(fontSize: 12)),
            ),
            RadioListTile<_Ruling>(
              value: _Ruling.refundToClient,
              groupValue: _ruling,
              onChanged: (v) => setState(() => _ruling = v!),
              activeColor: kenyaRed,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('Refund ${formatKsh(d.escrowAmountKsh)} to ${d.clientName}', style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Admin Arbitration Notes'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: kenyaRed),
          onPressed: () {
            final rulingPrefix = _ruling == _Ruling.releaseToArchitect
                ? 'Released to architect'
                : 'Refunded to client';
            Navigator.of(context).pop(d.copyWith(
              status: DisputeStatus.resolved,
              resolutionNotes: '$rulingPrefix - ${_notesController.text.trim()}',
            ));
          },
          child: const Text('Confirm Ruling'),
        ),
      ],
    );
  }
}