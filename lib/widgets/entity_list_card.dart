import 'package:flutter/material.dart';

class EntityListCard extends StatelessWidget {
  const EntityListCard({
    super.key,
    required this.title,
    required this.methodLabel,
    required this.child,
  });

  final String title;
  final String methodLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                const SizedBox(width: 12),
                Text(
                  methodLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

