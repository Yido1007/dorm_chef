import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  final String image;
  final String mainText;
  final String altText;
  const Empty(this.image, this.mainText, this.altText, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              image,
              width: 140,
              fit: BoxFit.contain,
              semanticLabel: 'Boş entanver.',
              errorBuilder:
                  (_, __, ___) => Icon(
                    Icons.image_not_supported_outlined,
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Text(mainText, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              altText,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
