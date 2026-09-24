import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/payout.dart';

/// Withdrawal dialog letting the architect choose M-Pesa or Bank Transfer.
///
/// Dart equivalent of the Kotlin `AlertDialog` in ArchitectScreens.kt
/// (the "Withdraw to M-Pesa (B2C)" modal), extended to support both
/// payout methods instead of M-Pesa only.
///
/// Call it like:
/// ```dart
/// final payout = await showDialog<Payout>(
///   context: context,
///   builder: (_) => WithdrawDialog(
///     architectId: architectId,
///     architectName: architectName,
///   ),
/// );
/// if (payout != null) {
///   // send `payout` to your repository/viewmodel layer
/// }
/// ```
class WithdrawDialog extends StatefulWidget {
  const WithdrawDialog({
    super.key,
    required this.architectId,
    required this.architectName,
  });

  final String architectId;
  final String architectName;

  @override
  State<WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<WithdrawDialog> {
  PayoutMethod _method = PayoutMethod.mpesa;

  final _amountController = TextEditingController(text: '35000');
  final _phoneController = TextEditingController(text: '+254 720 889 900');
  final _bankNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankAccountNameController = TextEditingController();

  static const int _feeKsh = 25;

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankAccountNameController.dispose();
    super.dispose();
  }

  Payout _buildPayout() {
    final amount = int.tryParse(_amountController.text) ?? 0;
    return Payout(
      architectId: widget.architectId,
      architectName: widget.architectName,
      amountKsh: amount,
      method: _method,
      recipientPhone: _method == PayoutMethod.mpesa ? _phoneController.text : '',
      bankName: _method == PayoutMethod.bank ? _bankNameController.text : '',
      bankAccountNumber:
          _method == PayoutMethod.bank ? _bankAccountNumberController.text : '',
      bankAccountName:
          _method == PayoutMethod.bank ? _bankAccountNameController.text : '',
      feeKsh: _feeKsh,
      netReceivedKsh: amount - _feeKsh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final payout = _buildPayout();

    return AlertDialog(
      title: const Text('Withdraw Funds', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Method toggle
            SegmentedButton<PayoutMethod>(
              segments: PayoutMethod.values
                  .map((m) => ButtonSegment(value: m, label: Text(m.label)))
                  .toList(),
              selected: {_method},
              onSelectionChanged: (selection) {
                setState(() => _method = selection.first);
              },
            ),
            const SizedBox(height: 12),
            Text(
              _method == PayoutMethod.mpesa
                  ? 'Instant Safaricom Daraja B2C payout to your registered M-Pesa number.'
                  : 'Transfer to your registered bank account. May take 1-2 business days.',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Withdrawal Amount (Ksh) *'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            if (_method == PayoutMethod.mpesa) ...[
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Recipient Phone Number *'),
                onChanged: (_) => setState(() {}),
              ),
            ] else ...[
              TextField(
                controller: _bankNameController,
                decoration: const InputDecoration(labelText: 'Bank Name *'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bankAccountNumberController,
                decoration: const InputDecoration(labelText: 'Account Number *'),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bankAccountNameController,
                decoration: const InputDecoration(labelText: 'Account Name *'),
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              _method == PayoutMethod.mpesa
                  ? 'Safaricom B2C Transaction Fee: Ksh $_feeKsh'
                  : 'Bank Transfer Fee: Ksh $_feeKsh',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: payout.isValid
              ? () => Navigator.of(context).pop(payout)
              : null,
          child: const Text('Confirm Payout'),
        ),
      ],
    );
  }
}
