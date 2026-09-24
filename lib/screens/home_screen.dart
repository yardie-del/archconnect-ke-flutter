import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../widgets/wallet_helpers.dart';

/// Landing screen after successful auth. Simple dashboard routing into the
/// screens already built (profile, post brief, bidding, wallet), now using
/// the real logged-in [AppUser] instead of hardcoded demo IDs.
///
/// This is intentionally minimal — a real Home screen (matching the concept
/// doc) would show live project/notification summaries once the backend
/// exists. For now it's the connective tissue between Auth and everything
/// else already built.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.onSignOut,
    this.onPostBrief,
    this.onReviewBids,
    this.onBrowseBriefs,
    this.onViewProfile,
    this.onWallet,
    this.onProjectDetails,
    this.onOpenNotifications,
    this.unreadNotificationCount = 0,
  });

  final AppUser user;
  final VoidCallback onSignOut;
  final VoidCallback? onPostBrief;
  final VoidCallback? onReviewBids;
  final VoidCallback? onBrowseBriefs;
  final VoidCallback? onViewProfile;
  final VoidCallback? onWallet;
  final VoidCallback? onProjectDetails;
  final VoidCallback? onOpenNotifications;
  final int unreadNotificationCount;

  @override
  Widget build(BuildContext context) {
    final isClient = user.role == UserRole.client;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.fullName}'),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(onPressed: onOpenNotifications, icon: const Icon(Icons.notifications_outlined)),
              if (unreadNotificationCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: kenyaRed, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text('$unreadNotificationCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          IconButton(onPressed: onSignOut, icon: const Icon(Icons.logout), tooltip: 'Sign Out'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: isClient ? kenyaGreenPrimary : safariGold,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isClient ? 'Client Account' : '${user.tier?.title ?? ''} Architect',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(user.email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(user.location, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, color: slateDark)),
          const SizedBox(height: 10),
          if (isClient) ...[
            _actionTile(context, Icons.assignment_add, 'Post a Brief', 'Describe your project and get bids', onPostBrief),
            _actionTile(context, Icons.gavel, 'Review Bids', 'See offers from verified architects', onReviewBids),
            _actionTile(context, Icons.timeline, 'Active Project Tracking', 'Milestones, deliverables & approvals', onProjectDetails),
          ] else ...[
            _actionTile(context, Icons.storefront, 'Browse Open Briefs', 'Bid on client projects', onBrowseBriefs),
            _actionTile(context, Icons.badge, 'My Public Profile', 'What clients see about you', onViewProfile),
            _actionTile(context, Icons.account_balance_wallet, 'Wallet', 'Balance & payout history', onWallet),
            _actionTile(context, Icons.timeline, 'Active Project Tracking', 'Milestones, deliverables & approvals', onProjectDetails),
          ],
        ],
      ),
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback? onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: cardBorder)),
      child: ListTile(
        leading: Icon(icon, color: kenyaGreenPrimary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: slateMuted)),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: onTap ??
            () => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('$title - not wired yet.'))),
      ),
    );
  }
}