import 'package:flutter/material.dart';
import 'models/payout.dart';
import 'widgets/withdraw_dialog.dart';

void main() => runApp(const ArchConnectApp());

class ArchConnectApp extends StatelessWidget {
  const ArchConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArchConnect KE',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const _WalletDemoScreen(),
    );
  }
}

/// Placeholder screen just to exercise the withdraw dialog.
/// This is a stand-in for the future ArchitectWalletScreen port.
class _WalletDemoScreen extends StatefulWidget {
  const _WalletDemoScreen();

  @override
  State<_WalletDemoScreen> createState() => _WalletDemoScreenState();
}

class _WalletDemoScreenState extends State<_WalletDemoScreen> {
  Payout? _lastPayout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_lastPayout != null)
              Text(
                'Last payout: Ksh ${_lastPayout!.amountKsh} '
                'via ${_lastPayout!.method.label}',
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final result = await showDialog<Payout>(
                  context: context,
                  builder: (_) => const WithdrawDialog(
                    architectId: 'demo-architect-id',
                    architectName: 'Jane Mwangi',
                  ),
                );
                if (result != null) {
                  setState(() => _lastPayout = result);
                }
              },
              child: const Text('Withdraw Funds'),
            ),
          ],
        ),
      ),
    );
  }
}
