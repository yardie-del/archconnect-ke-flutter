import 'package:flutter/material.dart';
import 'models/bid.dart';
import 'models/project_brief.dart';
import 'screens/bid_review_screen.dart';
import 'screens/bidding_board_screen.dart';

void main() => runApp(const ArchConnectApp());

class ArchConnectApp extends StatelessWidget {
  const ArchConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArchConnect KE',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const _BiddingDemo(),
    );
  }
}

/// Demo shell tying the architect's bidding board to the client's bid
/// review screen, so you can see the full loop: architect places a bid ->
/// client sees it appear -> client accepts & pays escrow.
class _BiddingDemo extends StatefulWidget {
  const _BiddingDemo();

  @override
  State<_BiddingDemo> createState() => _BiddingDemoState();
}

class _BiddingDemoState extends State<_BiddingDemo> {
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ArchConnect KE - Bidding Demo'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Architect View'),
            Tab(text: 'Client View'),
          ]),
        ),
        body: TabBarView(
          children: [
            BiddingBoardScreen(
              openProjects: _openProjects,
              onBidSubmitted: (bid) => setState(() => _bids.add(bid)),
            ),
            BidReviewScreen(
              projectTitle: _openProjects.first.title,
              bids: _bids,
              onAcceptBid: (bid) {
                debugPrint('Accepted bid ${bid.id} from ${bid.architectName} '
                    'for ${bid.amountKsh} Ksh - proceeding to escrow funding.');
              },
            ),
          ],
        ),
      ),
    );
  }
}