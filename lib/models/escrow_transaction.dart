/// Ported from the Kotlin `EscrowStatus` enum.
enum EscrowStatus {
  none('Not Funded'),
  heldInEscrow('Funds Held in Safe Escrow'),
  releasedToArchitect('Released to Architect'),
  refundedToClient('Refunded to Client'),
  disputed('Held Pending Dispute Decision');

  const EscrowStatus(this.label);
  final String label;
}

/// Ported from the Kotlin `EscrowTransactionEntity`, with the payment rail
/// switched from M-Pesa to Bank, per the project decision to simulate
/// escrow via bank transfer instead of M-Pesa B2C.
///
/// This is a simulation only, matching the original concept doc's note
/// that real escrow / real-money transactions are out of scope for this
/// educational build — `bankRef` is a fake reference string, not a real
/// bank transaction.
class EscrowTransaction {
  EscrowTransaction({
    String? id,
    required this.projectId,
    required this.projectTitle,
    required this.clientId,
    required this.clientName,
    required this.architectId,
    required this.architectName,
    required this.amountKsh,
    required this.bankRef,
    this.status = EscrowStatus.heldInEscrow,
    required this.tierCommissionRate,
    required this.commissionAmountKsh,
    this.platformFeeKsh = 0,
    this.bankTransferFeeKsh = 25,
    required this.netPayoutKsh,
    DateTime? fundedAt,
    this.releasedAt,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        fundedAt = fundedAt ?? DateTime.now();

  final String id;
  final String projectId;
  final String projectTitle;
  final String clientId;
  final String clientName;
  final String architectId;
  final String architectName;
  final int amountKsh;

  /// Simulated bank transaction reference (was `mpesaRef` in the Kotlin
  /// version).
  final String bankRef;

  final EscrowStatus status;
  final double tierCommissionRate;
  final int commissionAmountKsh;
  final int platformFeeKsh;

  /// Simulated bank transfer processing fee (was `mpesaB2cFeeKsh`).
  final int bankTransferFeeKsh;

  final int netPayoutKsh;
  final DateTime fundedAt;
  final DateTime? releasedAt;

  EscrowTransaction copyWith({EscrowStatus? status, DateTime? releasedAt}) {
    return EscrowTransaction(
      id: id,
      projectId: projectId,
      projectTitle: projectTitle,
      clientId: clientId,
      clientName: clientName,
      architectId: architectId,
      architectName: architectName,
      amountKsh: amountKsh,
      bankRef: bankRef,
      status: status ?? this.status,
      tierCommissionRate: tierCommissionRate,
      commissionAmountKsh: commissionAmountKsh,
      platformFeeKsh: platformFeeKsh,
      bankTransferFeeKsh: bankTransferFeeKsh,
      netPayoutKsh: netPayoutKsh,
      fundedAt: fundedAt,
      releasedAt: releasedAt ?? this.releasedAt,
    );
  }
}