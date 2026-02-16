import 'package:flutter/material.dart';

class ConfirmationScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryPressed;

  const ConfirmationScreen({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.check_circle_outline,
    this.iconColor,
    required this.primaryButtonLabel,
    required this.onPrimaryPressed,
    this.secondaryButtonLabel,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: effectiveIconColor),
              const SizedBox(height: 20),
              Text(
                title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: onPrimaryPressed,
                child: Text(primaryButtonLabel),
              ),
              if (secondaryButtonLabel != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onSecondaryPressed,
                  child: Text(secondaryButtonLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
