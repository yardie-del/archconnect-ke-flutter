import 'package:flutter/material.dart';
import 'models/architect_tier.dart';
import 'models/payout.dart';
import 'screens/wallet_screen.dart';

void main() => runApp(const ArchConnectApp());

class ArchConnectApp extends StatelessWidget {
  const ArchConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArchConnect KE',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: _buildDemoWallet(),
    );
  }

  Widget _buildDemoWallet() {
    // Sample data standing in for what will come from Firestore once the
    // backend is wired up. Swap this for a real architect profile + payout
    // history stream later.
    final samplePayouts = [
      Payout(
        architectId: 'demo-architect-id',
        architectName: 'Jane Mwangi',
        projectTitle: 'Karen Residence - Phase 2',
        amountKsh: 87000,
        method: PayoutMethod.mpesa,
        mpesaB2cRef: 'QGT7X9K2L1',
        recipientPhone: '+254720889900',
        netReceivedKsh: 86975,
      ),
      Payout(
        architectId: 'demo-architect-id',
        architectName: 'Jane Mwangi',
        projectTitle: 'Kisumu Office Fit-Out',
        amountKsh: 45000,
        method: PayoutMethod.bank,
        bankName: 'Equity Bank',
        bankAccountNumber: '0123456789',
        bankAccountName: 'Jane Mwangi',
        netReceivedKsh: 44975,
      ),
    ];

    return ArchitectWalletScreen(
      architectId: 'demo-architect-id',
      architectName: 'Jane Mwangi',
      tier: ArchitectTier.gold,
      totalRevenueKsh: 245000,
      payouts: samplePayouts,
      onPayoutConfirmed: (payout) {
        // TODO: send to repository/backend once that layer is built.
        debugPrint('Confirmed payout: ${payout.toJson()}');
      },
    );
  }
}
