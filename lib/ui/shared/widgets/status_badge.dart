import 'package:flutter/material.dart';

enum RequestStatus { pending, inProgress, resolved }

extension RequestStatusX on RequestStatus {
  String get label => switch (this) {
        RequestStatus.pending => 'Pending',
        RequestStatus.inProgress => 'In Progress',
        RequestStatus.resolved => 'Resolved',
      };
}

RequestStatus statusFromString(String s) {
  switch (s.toLowerCase()) {
    case 'pending':
    case 'open':
      return RequestStatus.pending;
    case 'in progress':
    case 'inprogress':
      return RequestStatus.inProgress;
    case 'resolved':
    case 'done':
    case 'closed':
      return RequestStatus.resolved;
    default:
      return RequestStatus.pending;
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;
  final bool? _isActiveOverride;

  const StatusBadge({super.key, required this.status, this.compact = false}) : _isActiveOverride = null;

  /// Badge for managed user Active/Revoked using theme colors.
  const StatusBadge.managedUser({super.key, required bool isActive, this.compact = false})
      : status = isActive ? 'active' : 'revoked',
        _isActiveOverride = isActive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = _isActiveOverride;
    final color = isActive != null
        ? (isActive ? scheme.primaryContainer : scheme.errorContainer)
        : switch (statusFromString(status)) {
            RequestStatus.pending => scheme.secondaryContainer,
            RequestStatus.inProgress => scheme.surfaceContainerHighest,
            RequestStatus.resolved => scheme.primaryContainer,
          };
    final onColor = isActive != null
        ? (isActive ? scheme.onPrimaryContainer : scheme.onErrorContainer)
        : switch (statusFromString(status)) {
            RequestStatus.pending => scheme.onSecondaryContainer,
            RequestStatus.inProgress => scheme.onSurface,
            RequestStatus.resolved => scheme.onPrimaryContainer,
          };
    final label = isActive != null ? (isActive ? 'Active' : 'Revoked') : statusFromString(status).label;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: onColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
