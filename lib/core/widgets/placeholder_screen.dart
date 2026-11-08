import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Stands in for screens scheduled after Phase 1.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    this.showBack = false,
    super.key,
  });

  final String title;
  final bool showBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: showBack
        ? AppBar(backgroundColor: AppColors.background, elevation: 0)
        : null,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Not built yet.', style: AppText.caption),
          ],
        ),
      ),
    ),
  );
}
