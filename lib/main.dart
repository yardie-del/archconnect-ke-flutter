import 'package:flutter/material.dart';
import 'models/project_brief.dart';
import 'screens/post_brief_screen.dart';

void main() => runApp(const ArchConnectApp());

class ArchConnectApp extends StatelessWidget {
  const ArchConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArchConnect KE',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: PostBriefScreen(
        onBriefPosted: (brief) {
          debugPrint(
            'Brief posted: ${brief.title} | ${brief.category.displayName} | '
            '${brief.location} | Ksh ${brief.budgetMinKsh}-${brief.budgetMaxKsh} | '
            '${brief.deadlineDays} days',
          );
        },
        onCancel: () => debugPrint('Post brief cancelled'),
      ),
    );
  }
}
