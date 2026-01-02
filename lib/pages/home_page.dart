import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:buildbuddy/nav.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tiles = [
      _FeatureTile('Idea Generator', Icons.lightbulb, AppRoutes.ideaGenerator, 'Turn themes and skills into ideas'),
      _FeatureTile('Team Builder', Icons.group, AppRoutes.teamBuilder, 'Match roles and skills'),
      _FeatureTile('Planner', Icons.timeline, AppRoutes.planner, 'Features, milestones, timeline'),
      _FeatureTile('Tech Stack', Icons.layers, AppRoutes.techStack, 'Stack picks for delivery'),
      _FeatureTile('UI/UX Assistant', Icons.palette, AppRoutes.designAssistant, 'Palettes, fonts, layouts'),
      _FeatureTile('Mentor Chat', Icons.chat_bubble, AppRoutes.mentorChat, 'Ask coding, design, pitch'),
      _FeatureTile('Pitch Deck', Icons.slideshow, AppRoutes.pitchDeck, 'Slides and demo flow'),
      _FeatureTile('Readiness Score', Icons.verified, AppRoutes.readiness, 'Score and next actions'),
      _FeatureTile('Portfolio', Icons.folder, AppRoutes.portfolio, 'History and export'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('BuildBuddy', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.onSurface)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'BuildBuddy helps students go from hackathon idea to demo faster, smarter, with AI',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(builder: (context, c) {
          final crossAxisCount = c.maxWidth > 1100 ? 3 : c.maxWidth > 700 ? 2 : 1;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, childAspectRatio: 1.6, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemCount: tiles.length,
            itemBuilder: (context, i) => _FeatureCard(tile: tiles[i]),
          );
        }),
      ),
    );
  }
}

class _FeatureTile {
  final String title;
  final IconData icon;
  final String route;
  final String subtitle;
  _FeatureTile(this.title, this.icon, this.route, this.subtitle);
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.tile});
  final _FeatureTile tile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.go(tile.route),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 20, backgroundColor: cs.primaryContainer, child: Icon(tile.icon, color: cs.onPrimaryContainer)),
            const SizedBox(height: 16),
            Text(tile.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.onSurface)),
            const SizedBox(height: 6),
            Text(tile.subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
            const Spacer(),
            Row(children: [Text('Open', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cs.primary)), const SizedBox(width: 6), Icon(Icons.arrow_forward, color: cs.primary, size: 18)])
          ]),
        ),
      ),
    );
  }
}
