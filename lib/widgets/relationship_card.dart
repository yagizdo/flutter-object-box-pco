import 'package:flutter/material.dart';
import 'package:object_box_poc/widgets/method_info_box.dart';

class RelationshipCard extends StatelessWidget {
  const RelationshipCard({
    super.key,
    required this.title,
    required this.methodLabel,
    required this.code,
    required this.description,
    required this.child,
  });

  final String title;
  final String methodLabel;
  final String code;
  final String description;
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
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            MethodInfoBox(
              methodLabel: methodLabel,
              code: code,
              description: description,
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

