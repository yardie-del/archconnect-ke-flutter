import 'package:flutter/material.dart';
import 'models/app_user.dart';
import 'models/architect_profile.dart';
import 'models/architect_tier.dart';
import 'models/bid.dart';
import 'models/project_brief.dart';
import 'screens/architect_profile_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/bid_review_screen.dart';
import 'screens/bidding_board_screen.dart';
import 'screens/home_screen.dart';
import 'screens/post_brief_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return AuthScreen(onAuthSuccess: (u) => setState(() => _currentUser = u));
    }
    final user = _currentUser!;
    return HomeScreen(
      user: user,
      onSignOut: () => setState(() => _currentUser = null),
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
          onBidSubmitted: (bid) => setState(() => _bids.add(Bid(
                id: bid.id,
                projectId: bid.projectId,
                architectName: user.fullName,
                architectTier: user.tier ?? ArchitectTier.gold,
                isBoraqsVerified: user.boraqsNumber.isNotEmpty,
                amountKsh: bid.amountKsh,
                deliveryDays: bid.deliveryDays,
                proposalNote: bid.proposalNote,
              ))),
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
    );
  }
}