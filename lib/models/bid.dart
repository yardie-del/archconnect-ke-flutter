import 'architect_tier.dart';
import 'project_brief.dart';

/// A project brief open for bidding, as shown to architects browsing the
/// bidding board. Ported from the relevant fields of Kotlin's
/// `ProjectEntity`.
class OpenProject {
  const OpenProject({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.budgetMinKsh,
    required this.budgetMaxKsh,
    required this.deadlineDays,
  });

  final String id;
  final String title;
  final String description;
  final ProjectCategory category;
  final String location;
  final int budgetMinKsh;
  final int budgetMaxKsh;
  final int deadlineDays;
}

/// A bid an architect has submitted on an [OpenProject]. Ported from the
/// Kotlin `BidEntity`.
class Bid {
  const Bid({
    required this.id,
    required this.projectId,
    required this.architectName,
    required this.architectTier,
    required this.isBoraqsVerified,
    required this.amountKsh,
    required this.deliveryDays,
    required this.proposalNote,
  });

  final String id;
  final String projectId;
  final String architectName;
  final ArchitectTier architectTier;
  final bool isBoraqsVerified;
  final int amountKsh;
  final int deliveryDays;
  final String proposalNote;
}