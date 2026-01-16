import 'package:flutter/material.dart';

class MethodInfoBox extends StatelessWidget {
  const MethodInfoBox({
    super.key,
    required this.methodLabel,
    required this.code,
    required this.description,
  });

  final String methodLabel;
  final String code;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceContainerHighest;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            methodLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            code,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(description, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
