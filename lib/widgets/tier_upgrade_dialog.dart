import 'package:flutter/material.dart';
import '../models/architect_tier.dart';
import 'wallet_helpers.dart';

/// Ported from the Kotlin tier-upgrade `AlertDialog` in
/// ArchitectPublicProfileScreen. Lets a non-client user request an upgrade
/// to a higher tier, submitting BORAQS/college verification details.
class TierUpgradeDialog extends StatefulWidget {
  const TierUpgradeDialog({super.key});

  @override
  State<TierUpgradeDialog> createState() => _TierUpgradeDialogState();
}

class TierUpgradeRequest {
  TierUpgradeRequest(this.tier, this.boraqsNumber, this.documentName);
  final ArchitectTier tier;
  final String boraqsNumber;
  final String documentName;
}

class _TierUpgradeDialogState extends State<TierUpgradeDialog> {
  ArchitectTier _requestedTier = ArchitectTier.gold;
  final _boraqsController = TextEditingController(text: 'BORAQS #A-');
  final _docController =
      TextEditingController(text: 'BORAQS_Practicing_Certificate_2026.pdf');

  @override
  void dispose() {
    _boraqsController.dispose();
    _docController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request Tier Upgrade', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit verification documents to unlock higher bid limits and reduced commission rates.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text('Select Target Tier:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ...ArchitectTier.values.map((t) => RadioListTile<ArchitectTier>(
                  value: t,
                  groupValue: _requestedTier,
                  onChanged: (v) => setState(() => _requestedTier = v!),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('${t.title} (${formatKsh(t.subscriptionFeeKsh)}/yr)',
                      style: const TextStyle(fontSize: 12)),
                )),
            const SizedBox(height: 8),
            TextField(
              controller: _boraqsController,
              decoration: const InputDecoration(labelText: 'BORAQS Number / College ID'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _docController,
              decoration: const InputDecoration(labelText: 'Document Attached'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            TierUpgradeRequest(_requestedTier, _boraqsController.text, _docController.text),
          ),
          child: const Text('Submit for Admin Verification'),
        ),
      ],
    );
  }
}