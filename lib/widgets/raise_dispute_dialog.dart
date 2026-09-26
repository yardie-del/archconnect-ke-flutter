import 'package:flutter/material.dart';
import '../models/dispute.dart';
import 'wallet_helpers.dart';

/// Dart port of the Kotlin `RaiseDisputeDialog`. Lets a client (or
/// architect) open a dispute case on a milestone/project, selecting an
/// issue type and describing it. Escrow funds stay held until an admin
/// arbitrates.
class RaiseDisputeDialog extends StatefulWidget {
  const RaiseDisputeDialog({super.key});

  @override
  State<RaiseDisputeDialog> createState() => _RaiseDisputeDialogState();
}

class DisputeSubmission {
  DisputeSubmission(this.issueType, this.description);
  final DisputeIssueType issueType;
  final String description;
}

class _RaiseDisputeDialogState extends State<RaiseDisputeDialog> {
  DisputeIssueType _selectedIssue = DisputeIssueType.quality;
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _descriptionController.text.trim().isNotEmpty;
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.shield, color: kenyaRed, size: 22),
          SizedBox(width: 8),
          Text('Raise Dispute Case', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escrow funds will remain safely held until an ArchConnect admin mediates.',
              style: TextStyle(fontSize: 12, color: slateMuted),
            ),
            const SizedBox(height: 12),
            const Text('Issue Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ...DisputeIssueType.values.map((issue) => RadioListTile<DisputeIssueType>(
                  value: issue,
                  groupValue: _selectedIssue,
                  onChanged: (v) => setState(() => _selectedIssue = v!),
                  activeColor: kenyaRed,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(issue.label, style: const TextStyle(fontSize: 12)),
                )),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Describe the issue in detail',
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kenyaRed)),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel', style: TextStyle(color: slateMuted))),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: kenyaRed),
          onPressed: canSubmit
              ? () => Navigator.of(context)
                  .pop(DisputeSubmission(_selectedIssue, _descriptionController.text.trim()))
              : null,
          child: const Text('Open Dispute'),
        ),
      ],
    );
  }
}