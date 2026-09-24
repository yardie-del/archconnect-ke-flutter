import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/architect_profile.dart';
import '../models/architect_tier.dart';
import '../widgets/tier_upgrade_dialog.dart';
import '../widgets/wallet_helpers.dart';
import '../widgets/tier_badge.dart';

/// Who is viewing the profile — mirrors the Kotlin check on
/// `currentUser?.role == UserRole.CLIENT` to decide which CTA to show.
enum ViewerRole { client, architect, admin }

/// Dart port of the Kotlin `ArchitectPublicProfileScreen`.
///
/// Shows the cover banner, firm details + tier badge, stats grid,
/// a "Hire" CTA for clients (or a "Request Tier Upgrade" CTA for the
/// architect viewing their own profile), portfolio thumbnails, and
/// verified client reviews.
class ArchitectPublicProfileScreen extends StatelessWidget {
  const ArchitectPublicProfileScreen({
    super.key,
    required this.profile,
    required this.reviews,
    required this.viewerRole,
    this.onHireTap,
    this.onTierUpgradeSubmitted,
  });

  final ArchitectProfile profile;
  final List<Review> reviews;
  final ViewerRole viewerRole;
  final VoidCallback? onHireTap;
  final ValueChanged<TierUpgradeRequest>? onTierUpgradeSubmitted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: profile.coverImageUrl != null
                  ? Image.network(profile.coverImageUrl!, fit: BoxFit.cover,
                      colorBlendMode: BlendMode.darken, color: Colors.black.withOpacity(0.4))
                  : Container(color: slateDark),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDetailsCard(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildPortfolio(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _buildReviews(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.firmName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: slateDark)),
                    Text(profile.location, style: const TextStyle(fontSize: 11.5, color: slateMuted)),
                  ],
                ),
                ),
                const SizedBox(width: 8),
                TierBadge(tier: profile.tier, isBoraqsVerified: profile.isBoraqsVerified),
              ],
            ),
            if (profile.boraqsNumber.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Official Registration: ${profile.boraqsNumber}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kenyaGreenPrimary)),
            ],
            const SizedBox(height: 10),
            Text(
              profile.bio.isNotEmpty
                  ? profile.bio
                  : 'Premier registered architectural practice specializing in luxury sustainable villas, commercial towers and hospitality.',
              style: const TextStyle(fontSize: 11.5, color: slateMedium, height: 1.3),
            ),
            const SizedBox(height: 12),
            _buildStatsGrid(),
            const SizedBox(height: 14),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: slateSurfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statColumn('Rating', '${profile.ratingAvg.toStringAsFixed(1)} (${profile.reviewCount})'),
          _statColumn('Completed', '${profile.completedProjects}'),
          _statColumn('On-Time', '${profile.onTimeRate}%', color: mpesaGreen),
          _statColumn('Response', '${profile.responseTimeHours}h'),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value, {Color color = slateDark}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: slateMuted)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (viewerRole == ViewerRole.client) {
      final label = profile.firmName.length > 18 ? profile.firmName.substring(0, 18) : profile.firmName;
      return SizedBox(
        width: double.infinity,
        height: 42,
        child: FilledButton.icon(
          onPressed: onHireTap,
          style: FilledButton.styleFrom(backgroundColor: kenyaGreenPrimary),
          icon: const Icon(Icons.assignment_turned_in),
          label: Text('Post Project & Invite $label'),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton.icon(
        onPressed: () async {
          final result = await showDialog<TierUpgradeRequest>(
            context: context,
            builder: (_) => const TierUpgradeDialog(),
          );
          if (result != null) onTierUpgradeSubmitted?.call(result);
        },
        icon: const Icon(Icons.upgrade, color: safariGold),
        label: const Text('Request Tier Upgrade (Gold / Diamond)',
            style: TextStyle(color: safariGold, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPortfolio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Architectural Portfolio & CAD Elevations',
            style: TextStyle(fontWeight: FontWeight.bold, color: slateDark)),
        const SizedBox(height: 8),
        if (profile.portfolioImageUrls.isEmpty)
          const Text('No portfolio images yet.', style: TextStyle(fontSize: 11, color: slateMuted))
        else
          Row(
            children: profile.portfolioImageUrls.take(2).map((url) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(url, height: 110, fit: BoxFit.cover),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verified Client Reviews (${reviews.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, color: slateDark)),
        const SizedBox(height: 8),
        if (reviews.isEmpty)
          const Text('No public reviews yet.', style: TextStyle(fontSize: 11, color: slateMuted))
        else
          ...reviews.map((r) => _ReviewCard(review: r)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: cardBorder), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(DateFormat('dd MMM yyyy').format(review.date),
                  style: const TextStyle(fontSize: 10, color: slateMuted)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < review.rating.round() ? Icons.star : Icons.star_border,
                size: 14,
                color: safariGold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(review.comment, style: const TextStyle(fontSize: 11.5, color: slateMedium)),
        ],
      ),
    );
  }
}