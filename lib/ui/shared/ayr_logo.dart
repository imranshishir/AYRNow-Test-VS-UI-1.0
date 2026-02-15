import 'package:flutter/material.dart';

class AyrLogo extends StatelessWidget {
  final double size;
  const AyrLogo({super.key, this.size = 56});

  static const String _assetPath = 'assets/logo/logo.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        _assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => _fallbackLogo(context),
      ),
    );
  }

  Widget _fallbackLogo(BuildContext context) {
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
