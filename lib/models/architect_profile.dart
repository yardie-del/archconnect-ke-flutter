import 'architect_tier.dart';

/// Ported from the Kotlin `ArchitectProfileEntity`.
class ArchitectProfile {
  const ArchitectProfile({
    required this.userId,
    required this.firmName,
    required this.tier,
    this.isBoraqsVerified = false,
    this.boraqsNumber = '',
    this.bio = '',
    this.location = 'Nairobi, Kenya',
    this.ratingAvg = 0.0,
    this.reviewCount = 0,
    this.completedProjects = 0,
    this.onTimeRate = 0,
    this.responseTimeHours = 0,
    this.coverImageUrl,
    this.portfolioImageUrls = const [],
  });

  final String userId;
  final String firmName;
  final ArchitectTier tier;
  final bool isBoraqsVerified;
  final String boraqsNumber;
  final String bio;
  final String location;
  final double ratingAvg;
  final int reviewCount;
  final int completedProjects;
  final int onTimeRate;
  final int responseTimeHours;
  final String? coverImageUrl;
  final List<String> portfolioImageUrls;
}

/// Ported from the Kotlin `ReviewEntity`.
class Review {
  const Review({
    required this.id,
    required this.clientName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final String id;
  final String clientName;
  final double rating;
  final String comment;
  final DateTime date;
}