/// Ported from the Kotlin `MilestoneStatus` enum.
enum MilestoneStatus {
  pending('Pending Escrow Funding'),
  held('Funded in Safe Escrow'),
  inProgress('Work in Progress'),
  delivered('Deliverables Submitted'),
  approved('Approved by Client'),
  released('Escrow Released (Bank Transfer)'),
  disputed('In Dispute Hold');

  const MilestoneStatus(this.label);
  final String label;
}

/// Ported from the Kotlin `ProjectMilestoneEntity`. A project is broken
/// into staged milestones (e.g. 30% / 30% / 40%), each funded, delivered,
/// and approved independently.
class Milestone {
  Milestone({
    String? id,
    required this.projectId,
    required this.stageNumber,
    required this.title,
    required this.percentage,
    required this.amountKsh,
    this.status = MilestoneStatus.pending,
    this.dueDateDays = 7,
    this.deliverableUrl = '',
    this.deliverableNotes = '',
    this.deliveredAt,
    this.approvedAt,
    this.releasedAt,
    this.bankRef = '',
  }) : id = id ?? '$projectId-m$stageNumber';

  final String id;
  final String projectId;
  final int stageNumber;
  final String title;
  final int percentage;
  final int amountKsh;
  final MilestoneStatus status;
  final int dueDateDays;
  final String deliverableUrl;
  final String deliverableNotes;
  final DateTime? deliveredAt;
  final DateTime? approvedAt;
  final DateTime? releasedAt;
  final String bankRef;

  Milestone copyWith({
    MilestoneStatus? status,
    String? deliverableUrl,
    String? deliverableNotes,
    DateTime? deliveredAt,
    DateTime? approvedAt,
    DateTime? releasedAt,
    String? bankRef,
  }) {
    return Milestone(
      id: id,
      projectId: projectId,
      stageNumber: stageNumber,
      title: title,
      percentage: percentage,
      amountKsh: amountKsh,
      status: status ?? this.status,
      dueDateDays: dueDateDays,
      deliverableUrl: deliverableUrl ?? this.deliverableUrl,
      deliverableNotes: deliverableNotes ?? this.deliverableNotes,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      approvedAt: approvedAt ?? this.approvedAt,
      releasedAt: releasedAt ?? this.releasedAt,
      bankRef: bankRef ?? this.bankRef,
    );
  }
}