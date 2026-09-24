import 'package:flutter/material.dart';
import 'models/app_notification.dart';
import 'models/app_user.dart';
import 'models/architect_profile.dart';
import 'models/architect_tier.dart';
import 'models/bid.dart';
import 'models/milestone.dart';
import 'models/project_brief.dart';
import 'screens/architect_profile_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/bid_review_screen.dart';
import 'screens/bidding_board_screen.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/post_brief_screen.dart';
import 'screens/project_details_screen.dart';
import 'screens/wallet_screen.dart';

void main() => runApp(const ArchConnectApp());

class ArchConnectApp extends StatelessWidget {
  const ArchConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArchConnect KE',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const _AppRoot(),
    );
  }
}

/// App root: shows [AuthScreen] until a real [AppUser] is signed in, then
/// [HomeScreen], from which every previously-built screen is reached using
/// the real logged-in identity instead of hardcoded demo IDs.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  AppUser? _currentUser;

  // Shared in-memory sample data, standing in for Firestore until the
  // backend is wired up.
  final _openProjects = const [
    OpenProject(
      id: 'proj-1',
      title: 'Modern 4-Bedroom Eco-Villa with Solar Design',
      description: 'Full schematic + county approval drawings for a sustainable '
          'family villa on a 0.5 acre plot in Karen.',
      category: ProjectCategory.housePlan,
      location: 'Karen, Nairobi',
      budgetMinKsh: 150000,
      budgetMaxKsh: 250000,
      deadlineDays: 14,
    ),
  ];
  final List<Bid> _bids = [];

  List<Milestone> _milestones = [
    Milestone(
      projectId: 'proj-1',
      stageNumber: 1,
      title: 'Concept Design & Site Analysis',
      percentage: 30,
      amountKsh: 60000,
      dueDateDays: 5,
    ),
    Milestone(
      projectId: 'proj-1',
      stageNumber: 2,
      title: 'Schematic Drawings & County Submission',
      percentage: 30,
      amountKsh: 60000,
      dueDateDays: 10,
    ),
    Milestone(
      projectId: 'proj-1',
      stageNumber: 3,
      title: 'Final CAD Package & Handover',
      percentage: 40,
      amountKsh: 80000,
      dueDateDays: 14,
    ),
  ];

  final List<AppNotification> _notifications = [];

  void _addNotification(NotificationType type, String title, String message, {String? projectId}) {
    setState(() {
      _notifications.insert(0, AppNotification(type: type, title: title, message: message, projectId: projectId));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return AuthScreen(onAuthSuccess: (u) => setState(() => _currentUser = u));
    }
    final user = _currentUser!;
    return HomeScreen(
      user: user,
      onSignOut: () => setState(() => _currentUser = null),
      unreadNotificationCount: _notifications.where((n) => !n.isRead).length,
      onOpenNotifications: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => NotificationsScreen(
          notifications: _notifications,
          onNotificationsChanged: (updated) => setState(() {
            _notifications
              ..clear()
              ..addAll(updated);
          }),
        ),
      )),
      onPostBrief: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PostBriefScreen(
          onBriefPosted: (brief) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Brief "${brief.title}" posted.')),
            );
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      )),
      onReviewBids: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BidReviewScreen(
          projectId: _openProjects.first.id,
          projectTitle: _openProjects.first.title,
          clientId: user.id,
          clientName: user.fullName,
          bids: _bids,
        ),
      )),
      onBrowseBriefs: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BiddingBoardScreen(
          openProjects: _openProjects,
          onBidSubmitted: (bid) {
            setState(() => _bids.add(Bid(
                  id: bid.id,
                  projectId: bid.projectId,
                  architectName: user.fullName,
                  architectTier: user.tier ?? ArchitectTier.gold,
                  isBoraqsVerified: user.boraqsNumber.isNotEmpty,
                  amountKsh: bid.amountKsh,
                  deliveryDays: bid.deliveryDays,
                  proposalNote: bid.proposalNote,
                )));
            _addNotification(
              NotificationType.newBid,
              'New Bid Received',
              '${user.fullName} bid ${bid.amountKsh} Ksh on "${_openProjects.first.title}".',
              projectId: bid.projectId,
            );
          },
        ),
      )),
      onViewProfile: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ArchitectPublicProfileScreen(
          profile: ArchitectProfile(
            userId: user.id,
            firmName: user.firmName.isNotEmpty ? user.firmName : user.fullName,
            tier: user.tier ?? ArchitectTier.gold,
            isBoraqsVerified: user.boraqsNumber.isNotEmpty,
            boraqsNumber: user.boraqsNumber,
            bio: user.bio,
            location: user.location,
          ),
          reviews: const [],
          viewerRole: ViewerRole.architect,
        ),
      )),
      onWallet: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ArchitectWalletScreen(
          architectId: user.id,
          architectName: user.fullName,
          tier: user.tier ?? ArchitectTier.gold,
          totalRevenueKsh: 0,
          payouts: const [],
        ),
      )),
      onProjectDetails: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProjectDetailsScreen(
          projectTitle: _openProjects.first.title,
          category: _openProjects.first.category.displayName,
          location: _openProjects.first.location,
          milestones: _milestones,
          viewerRole: user.role,
          onMilestonesChanged: (updated) {
            for (final m in updated) {
              final old = _milestones.firstWhere((x) => x.id == m.id, orElse: () => m);
              if (old.status != m.status) {
                switch (m.status) {
                  case MilestoneStatus.held:
                    _addNotification(NotificationType.escrowFunded, 'Escrow Funded',
                        'Stage ${m.stageNumber} (${m.title}) is now funded and held in escrow.',
                        projectId: m.projectId);
                    break;
                  case MilestoneStatus.delivered:
                    _addNotification(NotificationType.milestoneDelivered, 'Deliverable Submitted',
                        'Stage ${m.stageNumber} (${m.title}) is ready for your review.',
                        projectId: m.projectId);
                    break;
                  case MilestoneStatus.released:
                    _addNotification(NotificationType.milestoneReleased, 'Payment Released',
                        'Stage ${m.stageNumber} (${m.title}) was approved and funds released.',
                        projectId: m.projectId);
                    break;
                  default:
                    break;
                }
              }
            }
            setState(() => _milestones = updated);
          },
          onRaiseDispute: (m) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dispute raised on "${m.title}" (Dispute Centre not built yet).')),
          ),
        ),
      )),
    );
  }
}