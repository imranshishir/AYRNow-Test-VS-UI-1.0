import 'package:flutter/material.dart';

class AyrLogo extends StatelessWidget {
  final double size;
  const AyrLogo({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    // Simple “house + check” logo feel (no asset needed yet).
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Icon(
        Icons.home_rounded,
        size: size * 0.62,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
