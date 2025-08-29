import 'package:flutter/material.dart';

class PercentBadge extends StatelessWidget {
  final int percent;
  const PercentBadge({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withOpacity(.25)),
      ),
      child: Text(
        '%$percent',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: cs.onPrimaryContainer),
      ),
    );
  }
}
