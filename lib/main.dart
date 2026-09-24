import 'package:flutter/material.dart';
import 'models/architect_profile.dart';
import 'models/architect_tier.dart';
import 'screens/architect_profile_screen.dart';

void main() => runApp(const ArchConnectApp());

class ArchConnectApp extends StatelessWidget {
  const ArchConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArchConnect KE',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: _buildDemoProfile(),
    );
  }

  Widget _buildDemoProfile() {
    // Sample data standing in for what will come from Firestore once the
    // backend is wired up.
    const profile = ArchitectProfile(
      userId: 'demo-architect-id',
      firmName: 'Mwangi & Associates Architects',
      tier: ArchitectTier.gold,
      isBoraqsVerified: true,
      boraqsNumber: 'BORAQS #A-4471',
      bio: 'Premier registered architectural practice specializing in '
          'luxury sustainable villas, commercial towers and hospitality '
          'projects across Nairobi and Homa Bay.',
      location: 'Karen, Nairobi',
      ratingAvg: 4.8,
      reviewCount: 23,
      completedProjects: 41,
      onTimeRate: 96,
      responseTimeHours: 2,
    );

    final reviews = [
      Review(
        id: '1',
        clientName: 'David Otieno',
        rating: 5,
        comment: 'Excellent communication and the final design exceeded our brief.',
        date: DateTime(2026, 8, 12),
      ),
      Review(
        id: '2',
        clientName: 'Grace Nyambura',
        rating: 4,
        comment: 'Great work overall, milestone updates could have been faster.',
        date: DateTime(2026, 7, 3),
      ),
    ];

    return ArchitectPublicProfileScreen(
      profile: profile,
      reviews: reviews,
      viewerRole: ViewerRole.client,
      onHireTap: () => debugPrint('Post Project & Invite tapped'),
      onTierUpgradeSubmitted: (req) => debugPrint(
        'Tier upgrade requested: ${req.tier.title} / ${req.boraqsNumber}',
      ),
    );
  }
}
