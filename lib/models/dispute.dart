import 'package:flutter/material.dart';

/// Ported from the Kotlin `DisputeIssueType` enum.
enum DisputeIssueType {
  payment('Payment & Billing Disputes'),
  quality('Deliverable Quality / Scope Discrepancy'),
  timeline('Delayed Deliverables / Inactivity');

  const DisputeIssueType(this.label);
  final String label;
}

/// Ported from the Kotlin `DisputeStatus` enum, with its color mapped from
/// the original hex constants.
enum DisputeStatus {
  underReview('Under Admin Review', Color(0xFFD97706)),
  awaitingResponse('Awaiting Party Response', Color(0xFF2563EB)),
  resolved('Resolved & Escrow Released/Refunded', Color(0xFF16A34A)),
  closed('Closed Case', Color(0xFF64748B));

  const DisputeStatus(this.label, this.color);
  final String label;
  final Color color;
}

/// Ported from the Kotlin `DisputeEntity`.
class Dispute {
  Dispute({
    String? id,
    String? caseId,
    required this.projectId,
    required this.projectTitle,
    required this.clientId,
    required this.clientName,
    required this.architectId,
    required this.architectName,
    required this.issueType,
    required this.escrowAmountKsh,
    this.status = DisputeStatus.underReview,
    required this.description,
    this.resolutionNotes = '',
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        caseId = caseId ?? 'DISP-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}',
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String caseId;
  final String projectId;
  final String projectTitle;
  final String clientId;
  final String clientName;
  final String architectId;
  final String architectName;
  final DisputeIssueType issueType;
  final int escrowAmountKsh;
  final DisputeStatus status;
  final String description;
  final String resolutionNotes;
  final DateTime createdAt;

  Dispute copyWith({DisputeStatus? status, String? resolutionNotes}) {
    return Dispute(
      id: id,
      caseId: caseId,
      projectId: projectId,
      projectTitle: projectTitle,
      clientId: clientId,
      clientName: clientName,
      architectId: architectId,
      architectName: architectName,
      issueType: issueType,
      escrowAmountKsh: escrowAmountKsh,
      status: status ?? this.status,
      description: description,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt,
    );
  }
}