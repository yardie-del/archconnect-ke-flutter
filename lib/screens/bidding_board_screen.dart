import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/architect_tier.dart';
import '../models/bid.dart';
import '../models/project_brief.dart';
import '../widgets/wallet_helpers.dart';

/// Dart port of the Kotlin `ArchitectDashboardScreen`'s open-projects list
/// plus its "Submit Proposal Bid" modal. Architects browse open briefs and
/// place a bid (price, timeline, cover note) on the one they want.
class BiddingBoardScreen extends StatefulWidget {
  const BiddingBoardScreen({
    super.key,
    required this.openProjects,
    required this.onBidSubmitted,
  });

  final List<OpenProject> openProjects;
  final ValueChanged<Bid> onBidSubmitted;

  @override
  State<BiddingBoardScreen> createState() => _BiddingBoardScreenState();
}

class _BiddingBoardScreenState extends State<BiddingBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open Project Briefs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${widget.openProjects.length} clients currently accepting bids in Kenya',
            style: const TextStyle(fontSize: 12, color: slateMuted),
          ),
          const SizedBox(height: 12),
          if (widget.openProjects.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No open briefs right now.', style: TextStyle(color: slateMuted)),
            )
          else
            ...widget.openProjects.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OpenProjectBidCard(
                    project: p,
                    onPlaceBid: () => _openBidDialog(p),
                  ),
                )),
        ],
      ),
    );
  }

  Future<void> _openBidDialog(OpenProject project) async {
    final bid = await showDialog<Bid>(
      context: context,
      builder: (_) => _SubmitBidDialog(project: project),
    );
    if (bid != null) widget.onBidSubmitted(bid);
  }
}

class _OpenProjectBidCard extends StatelessWidget {
  const _OpenProjectBidCard({required this.project, required this.onPlaceBid});

  final OpenProject project;
  final VoidCallback onPlaceBid;

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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: kenyaGreenPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(project.category.displayName,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kenyaGreenPrimary)),
                ),
                Text(project.location, style: const TextStyle(fontSize: 11, color: slateMuted)),
              ],
            ),
            const SizedBox(height: 6),
            Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: slateDark)),
            const SizedBox(height: 4),
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: slateMedium),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Client Budget Range', style: TextStyle(fontSize: 10, color: slateMuted)),
                    Text(
                      '${formatKsh(project.budgetMinKsh)} - ${formatKsh(project.budgetMaxKsh)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kenyaGreenPrimary),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: onPlaceBid,
                  style: FilledButton.styleFrom(backgroundColor: kenyaGreenPrimary),
                  icon: const Icon(Icons.send, size: 14),
                  label: const Text('Place Bid', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitBidDialog extends StatefulWidget {
  const _SubmitBidDialog({required this.project});
  final OpenProject project;

  @override
  State<_SubmitBidDialog> createState() => _SubmitBidDialogState();
}

class _SubmitBidDialogState extends State<_SubmitBidDialog> {
  late final TextEditingController _amountController;
  late final TextEditingController _deliveryDaysController;
  final _proposalController = TextEditingController();

  static const _defaultPitch =
      'Experienced architectural firm ready to deliver full schematic and '
      'county drawings within target schedule.';

  @override
  void initState() {
    super.initState();
    final midpoint = widget.project.budgetMinKsh +
        ((widget.project.budgetMaxKsh - widget.project.budgetMinKsh) ~/ 2);
    _amountController = TextEditingController(text: midpoint.toString());
    _deliveryDaysController = TextEditingController(text: widget.project.deadlineDays.toString());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _deliveryDaysController.dispose();
    _proposalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return AlertDialog(
      title: const Text('Submit Proposal Bid', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: kenyaGreenPrimary)),
            Text('Client Budget: ${formatKsh(p.budgetMinKsh)} - ${formatKsh(p.budgetMaxKsh)}',
                style: const TextStyle(fontSize: 11, color: slateMuted)),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Your Quoted Price (Ksh) *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _deliveryDaysController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Delivery Timeline (Days) *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _proposalController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Proposal Cover Note *',
                hintText: 'Highlight your architectural experience, software used '
                    '(Revit, Archicad, Lumion), and county approval track record...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: kenyaGreenPrimary),
          onPressed: () {
            final amount = int.tryParse(_amountController.text) ?? p.budgetMinKsh;
            final days = int.tryParse(_deliveryDaysController.text) ?? 14;
            final note = _proposalController.text.trim().isEmpty ? _defaultPitch : _proposalController.text.trim();
            // architectName/tier/verification would come from the logged-in
            // architect's profile once auth/backend is wired up.
            Navigator.of(context).pop(Bid(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              projectId: p.id,
              architectName: 'Current Architect',
              architectTier: ArchitectTier.gold,
              isBoraqsVerified: true,
              amountKsh: amount,
              deliveryDays: days,
              proposalNote: note,
            ));
          },
          child: const Text('Submit Bid'),
        ),
      ],
    );
  }
}