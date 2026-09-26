import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_user.dart' show UserRole;
import '../models/architect_profile.dart' show Review;
import '../models/dispute.dart';
import '../models/milestone.dart';
import '../widgets/raise_dispute_dialog.dart';
import '../widgets/rate_and_review_dialog.dart';
import '../widgets/wallet_helpers.dart';

Color _statusColor(MilestoneStatus s) => switch (s) {
      MilestoneStatus.pending => slateMuted,
      MilestoneStatus.held => const Color(0xFF2563EB),
      MilestoneStatus.inProgress => const Color(0xFF0284C7),
      MilestoneStatus.delivered => const Color(0xFFD97706),
      MilestoneStatus.approved => mpesaGreen,
      MilestoneStatus.released => mpesaGreen,
      MilestoneStatus.disputed => kenyaRed,
    };

/// Dart port of the Kotlin `ActiveWorkroomScreen`'s milestone tracker.
///
/// Shows a project's staged milestones (e.g. 30% / 30% / 40%) each with
/// its own escrow/delivery/approval lifecycle, plus a "Raise a Dispute"
/// escape hatch. Actions shown depend on [viewerRole]: architects mark
/// work delivered, clients fund and approve/release milestones.
class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
    required this.projectTitle,
    required this.category,
    required this.location,
    required this.milestones,
    required this.viewerRole,
    required this.clientId,
    required this.clientName,
    required this.architectId,
    required this.architectName,
    this.onMilestonesChanged,
    this.onDisputeRaised,
    this.onReviewSubmitted,
  });

  final String projectId;
  final String projectTitle;
  final String category;
  final String location;
  final List<Milestone> milestones;
  final UserRole viewerRole;
  final String clientId;
  final String clientName;
  final String architectId;
  final String architectName;
  final ValueChanged<List<Milestone>>? onMilestonesChanged;
  final ValueChanged<Dispute>? onDisputeRaised;
  final ValueChanged<Review>? onReviewSubmitted;

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late List<Milestone> _milestones = widget.milestones;
  bool _reviewSubmitted = false;

  int get _completedCount => _milestones.where((m) => m.status == MilestoneStatus.released).length;
  bool get _allReleased => _milestones.isNotEmpty && _completedCount == _milestones.length;

  @override
  Widget build(BuildContext context) {
    final progress = _milestones.isEmpty ? 0.0 : _completedCount / _milestones.length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.projectTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: cardBorder)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category, size: 14, color: slateMuted),
                      const SizedBox(width: 4),
                      Text(widget.category, style: const TextStyle(fontSize: 11, color: slateMuted)),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on, size: 14, color: slateMuted),
                      const SizedBox(width: 4),
                      Text(widget.location, style: const TextStyle(fontSize: 11, color: slateMuted)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Overall Progress', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: slateDark)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: slateSurfaceLight,
                      color: mpesaGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$_completedCount of ${_milestones.length} milestones released',
                      style: const TextStyle(fontSize: 10.5, color: slateMuted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Project Milestones', style: TextStyle(fontWeight: FontWeight.bold, color: slateDark)),
          const SizedBox(height: 8),
          ..._milestones.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MilestoneCard(
                  milestone: m,
                  viewerRole: widget.viewerRole,
                  onAdvance: (updated) => _updateMilestone(updated),
                  onRaiseDispute: () => _openDisputeDialog(m),
                ),
              )),
          if (widget.viewerRole == UserRole.client && _allReleased) ...[
            const SizedBox(height: 16),
            Card(
              color: mpesaGreenContainer.withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Project Complete!', style: TextStyle(fontWeight: FontWeight.bold, color: kenyaGreenPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      _reviewSubmitted
                          ? 'Thanks for your feedback on ${widget.architectName}.'
                          : 'All milestones released. Share your experience with ${widget.architectName}.',
                      style: const TextStyle(fontSize: 12, color: slateMedium),
                    ),
                    if (!_reviewSubmitted) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: safariGold),
                          onPressed: _openReviewDialog,
                          icon: const Icon(Icons.star, size: 16),
                          label: const Text('Rate & Review Architect', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _updateMilestone(Milestone updated) {
    setState(() {
      _milestones = _milestones.map((m) => m.id == updated.id ? updated : m).toList();
    });
    widget.onMilestonesChanged?.call(_milestones);
  }

  Future<void> _openDisputeDialog(Milestone milestone) async {
    final submission = await showDialog<DisputeSubmission>(
      context: context,
      builder: (_) => const RaiseDisputeDialog(),
    );
    if (submission == null) return;

    _updateMilestone(milestone.copyWith(status: MilestoneStatus.disputed));

    final dispute = Dispute(
      projectId: widget.projectId,
      projectTitle: widget.projectTitle,
      clientId: widget.clientId,
      clientName: widget.clientName,
      architectId: widget.architectId,
      architectName: widget.architectName,
      issueType: submission.issueType,
      escrowAmountKsh: milestone.amountKsh,
      description: submission.description,
    );
    widget.onDisputeRaised?.call(dispute);
  }

  Future<void> _openReviewDialog() async {
    final review = await showDialog<Review>(
      context: context,
      builder: (_) => RateAndReviewDialog(projectTitle: widget.projectTitle, clientName: widget.clientName),
    );
    if (review == null) return;
    setState(() => _reviewSubmitted = true);
    widget.onReviewSubmitted?.call(review);
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.milestone,
    required this.viewerRole,
    required this.onAdvance,
    required this.onRaiseDispute,
  });

  final Milestone milestone;
  final UserRole viewerRole;
  final ValueChanged<Milestone> onAdvance;
  final VoidCallback onRaiseDispute;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(milestone.status);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cardBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Stage ${milestone.stageNumber}: ${milestone.title}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: slateDark)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(5)),
                child: Text(milestone.status.label,
                    style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${milestone.percentage}% - ${formatKsh(milestone.amountKsh)} - Due in ${milestone.dueDateDays} days',
              style: const TextStyle(fontSize: 11, color: slateMuted)),
          if (milestone.deliverableNotes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('"${milestone.deliverableNotes}"',
                style: const TextStyle(fontSize: 11, color: slateMedium, fontStyle: FontStyle.italic)),
          ],
          if (milestone.releasedAt != null) ...[
            const SizedBox(height: 4),
            Text('Released ${DateFormat('dd MMM yyyy').format(milestone.releasedAt!)} - Ref: ${milestone.bankRef}',
                style: const TextStyle(fontSize: 9.5, color: slateMuted)),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildActionButton(context)),
              if (milestone.status != MilestoneStatus.released && milestone.status != MilestoneStatus.disputed) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onRaiseDispute,
                  style: OutlinedButton.styleFrom(foregroundColor: kenyaRed, side: const BorderSide(color: kenyaRed)),
                  child: const Text('Dispute', style: TextStyle(fontSize: 11)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final isClient = viewerRole == UserRole.client;

    switch (milestone.status) {
      case MilestoneStatus.pending:
        if (!isClient) return const SizedBox.shrink();
        return _btn('Fund Milestone', mpesaGreen, () => onAdvance(milestone.copyWith(
              status: MilestoneStatus.held,
              bankRef: 'BNK-${DateTime.now().millisecondsSinceEpoch}',
            )));
      case MilestoneStatus.held:
        if (isClient) return const SizedBox.shrink();
        return _btn('Start Work', const Color(0xFF0284C7), () => onAdvance(milestone.copyWith(status: MilestoneStatus.inProgress)));
      case MilestoneStatus.inProgress:
        if (isClient) return const SizedBox.shrink();
        return _btn('Submit Deliverable', const Color(0xFFD97706), () => onAdvance(milestone.copyWith(
              status: MilestoneStatus.delivered,
              deliverableNotes: 'Drawings uploaded for client review.',
              deliveredAt: DateTime.now(),
            )));
      case MilestoneStatus.delivered:
        if (!isClient) return const SizedBox.shrink();
        return _btn('Approve & Release', mpesaGreen, () => onAdvance(milestone.copyWith(
              status: MilestoneStatus.released,
              approvedAt: DateTime.now(),
              releasedAt: DateTime.now(),
            )));
      case MilestoneStatus.approved:
      case MilestoneStatus.released:
      case MilestoneStatus.disputed:
        return const SizedBox.shrink();
    }
  }

  Widget _btn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 34,
      child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: color),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}