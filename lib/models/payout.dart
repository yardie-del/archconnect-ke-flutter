import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// How an architect chooses to receive a withdrawal.
enum PayoutMethod {
  mpesa('M-Pesa'),
  bank('Bank Transfer');

  const PayoutMethod(this.label);
  final String label;
}

/// A single withdrawal/payout record for an architect.
///
/// Ported from the Kotlin `PayoutEntity` (Room entity) in the original
/// ArchConnect KE app. Mirrors the same fields, but supports either an
/// M-Pesa payout (phone number) or a bank transfer (bank name + account
/// number + account name), selected via [method].
class Payout {
  Payout({
    String? id,
    required this.architectId,
    required this.architectName,
    this.projectTitle = 'Platform Withdrawal',
    required this.amountKsh,
    required this.method,
    this.mpesaB2cRef = '',
    this.recipientPhone = '',
    this.bankName = '',
    this.bankAccountNumber = '',
    this.bankAccountName = '',
    this.feeKsh = 25,
    required this.netReceivedKsh,
    this.status = 'COMPLETED',
    DateTime? date,
  })  : id = id ?? _uuid.v4(),
        date = date ?? DateTime.now();

  final String id;
  final String architectId;
  final String architectName;
  final String projectTitle;
  final int amountKsh;
  final PayoutMethod method;

  // M-Pesa specific
  final String mpesaB2cRef;
  final String recipientPhone;

  // Bank specific
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountName;

  final int feeKsh;
  final int netReceivedKsh;
  final String status;
  final DateTime date;

  /// Basic validation so the UI can enable/disable the confirm button
  /// depending on which method is selected.
  bool get isValid {
    if (amountKsh <= 0) return false;
    switch (method) {
      case PayoutMethod.mpesa:
        return recipientPhone.trim().isNotEmpty;
      case PayoutMethod.bank:
        return bankName.trim().isNotEmpty &&
            bankAccountNumber.trim().isNotEmpty &&
            bankAccountName.trim().isNotEmpty;
    }
  }

  Payout copyWith({
    int? amountKsh,
    PayoutMethod? method,
    String? mpesaB2cRef,
    String? recipientPhone,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountName,
    String? status,
  }) {
    return Payout(
      id: id,
      architectId: architectId,
      architectName: architectName,
      projectTitle: projectTitle,
      amountKsh: amountKsh ?? this.amountKsh,
      method: method ?? this.method,
      mpesaB2cRef: mpesaB2cRef ?? this.mpesaB2cRef,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      feeKsh: feeKsh,
      netReceivedKsh: netReceivedKsh,
      status: status ?? this.status,
      date: date,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'architectId': architectId,
        'architectName': architectName,
        'projectTitle': projectTitle,
        'amountKsh': amountKsh,
        'method': method.name,
        'mpesaB2cRef': mpesaB2cRef,
        'recipientPhone': recipientPhone,
        'bankName': bankName,
        'bankAccountNumber': bankAccountNumber,
        'bankAccountName': bankAccountName,
        'feeKsh': feeKsh,
        'netReceivedKsh': netReceivedKsh,
        'status': status,
        'date': date.toIso8601String(),
      };

  factory Payout.fromJson(Map<String, dynamic> json) => Payout(
        id: json['id'] as String,
        architectId: json['architectId'] as String,
        architectName: json['architectName'] as String,
        projectTitle: json['projectTitle'] as String? ?? 'Platform Withdrawal',
        amountKsh: json['amountKsh'] as int,
        method: PayoutMethod.values.byName(json['method'] as String),
        mpesaB2cRef: json['mpesaB2cRef'] as String? ?? '',
        recipientPhone: json['recipientPhone'] as String? ?? '',
        bankName: json['bankName'] as String? ?? '',
        bankAccountNumber: json['bankAccountNumber'] as String? ?? '',
        bankAccountName: json['bankAccountName'] as String? ?? '',
        feeKsh: json['feeKsh'] as int? ?? 25,
        netReceivedKsh: json['netReceivedKsh'] as int,
        status: json['status'] as String? ?? 'COMPLETED',
        date: DateTime.parse(json['date'] as String),
      );
}
