import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final VoidCallback? onTap;

  const SectionCard({
    super.key,
    this.title,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );

    if (onTap != null) {
      return Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: content,
        ),
      );
    }
    return Card(child: content);
  }
}
