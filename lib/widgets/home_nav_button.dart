import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:buildbuddy/nav.dart';

/// A small, consistent Home button for AppBars that navigates
/// back to the main dashboard using go_router.
class HomeNavButton extends StatelessWidget {
  const HomeNavButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton.icon(
        onPressed: () => context.go(AppRoutes.home),
        icon: Icon(Icons.home, color: cs.onSurface, size: 20),
        label: Text('Home', style: TextStyle(color: cs.onSurface)),
        style: TextButton.styleFrom(
          foregroundColor: cs.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
