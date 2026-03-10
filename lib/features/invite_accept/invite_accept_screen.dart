import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/state/providers.dart';
import '../lease_onboarding/lease_onboarding_models.dart';

class InviteAcceptScreen extends ConsumerStatefulWidget {
  const InviteAcceptScreen({super.key});

  @override
  ConsumerState<InviteAcceptScreen> createState() => _InviteAcceptScreenState();
}

class _InviteAcceptScreenState extends ConsumerState<InviteAcceptScreen> {
  final _tokenCtrl = TextEditingController();
  final _typedNameCtrl = TextEditingController();
  final Map<String, TextEditingController> _docFilenameCtrls = {};

  LeasePacket? _packet;
  bool _loading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Try to get invite token from route arguments if provided.
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = args is Map ? args : const <String, dynamic>{};
    final token = map['token']?.toString();
    if (token != null && token.isNotEmpty && _tokenCtrl.text.isEmpty) {
      _tokenCtrl.text = token;
      _loadPacket();
    }
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _typedNameCtrl.dispose();
    for (final c in _docFilenameCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final tokenPresent = _tokenCtrl.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant onboarding'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Welcome. This invite guides you through reviewing your lease and uploading any requested documents.',
                    style: theme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _tokenCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Invite code or link token',
                      helperText:
                          'Usually filled automatically when you open this link.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: _loadPacket,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Load onboarding packet'),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    _TenantErrorBanner(message: _error!),
                  ],
                  const SizedBox(height: 16),
                  if (!tokenPresent)
                    Text(
                      'Enter the invite code from your landlord to continue.',
                      style: theme.bodySmall,
                    ),
                  if (tokenPresent && _packet == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'No onboarding packet loaded yet.',
                        style: theme.bodySmall,
                      ),
                    ),
                  if (_packet != null) ...[
                    const SizedBox(height: 24),
                    _OnboardingChecklist(packet: _packet!),
                    const SizedBox(height: 24),
                    _leaseSection(theme),
                    const SizedBox(height: 24),
                    _documentsSection(theme),
                    const SizedBox(height: 24),
                    _submitSection(theme),
                  ],
                ],
              ),
      ),
    );
  }

  Future<void> _loadPacket() async {
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(leaseOnboardingApiProvider);
      final packet = await api.getPacketByInviteToken(token);
      _syncDocControllers(packet);
      setState(() {
        _packet = packet;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _packet = null;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _syncDocControllers(LeasePacket packet) {
    // Create controllers for each document requirement, seeded with filename if present.
    for (final d in packet.documentRequirements) {
      _docFilenameCtrls.putIfAbsent(
        d.id,
        () => TextEditingController(text: d.filename ?? ''),
      );
    }
  }

  Widget _leaseSection(TextTheme theme) {
    final p = _packet!;
    final df = DateFormat.yMMMd();
    final hasAccepted =
        p.inviteSteps.any((s) => s.code == 'lease_accepted' && s.completed);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. Review your lease',
          style: theme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '${p.tenantName}, please confirm this looks right before you continue.',
          style: theme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Property / Unit: ${p.unitId}',
          style: theme.bodySmall,
        ),
        if (p.leaseStartDate != null && p.leaseEndDate != null) ...[
          const SizedBox(height: 4),
          Text(
            'Term: ${df.format(p.leaseStartDate!)} – ${df.format(p.leaseEndDate!)}',
            style: theme.bodySmall,
          ),
        ],
        if (p.monthlyRent != null) ...[
          const SizedBox(height: 4),
          Text('Monthly rent: ${p.monthlyRent?.toStringAsFixed(0)}',
              style: theme.bodySmall),
        ],
        if (p.securityDeposit != null) ...[
          const SizedBox(height: 4),
          Text('Security deposit: ${p.securityDeposit?.toStringAsFixed(0)}',
              style: theme.bodySmall),
        ],
        if (p.lateFeeClause != null && p.lateFeeClause!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Late fee policy:',
            style: theme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            p.lateFeeClause!,
            style: theme.bodySmall,
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _typedNameCtrl,
          decoration: const InputDecoration(
            labelText: 'Type your full name to acknowledge',
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: hasAccepted ? null : _acknowledgeLease,
          icon: const Icon(Icons.check_circle_outline),
          label: Text(
            hasAccepted ? 'Lease acknowledged' : 'I agree to this lease',
          ),
        ),
      ],
    );
  }

  Widget _documentsSection(TextTheme theme) {
    final p = _packet!;
    if (p.documentRequirements.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('2. Upload documents', style: theme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'No documents have been requested for this lease.',
            style: theme.bodyMedium,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('2. Upload documents', style: theme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'You can upload or update each item as needed. For this MVP, enter a filename to mark an item as uploaded.',
          style: theme.bodySmall,
        ),
        const SizedBox(height: 12),
        ...p.documentRequirements.map((d) {
          final ctrl = _docFilenameCtrls[d.id]!;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        d.required
                            ? Icons.check_circle_outline
                            : Icons.radio_button_unchecked,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          d.label,
                          style: theme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _statusChip(d, theme),
                    ],
                  ),
                  if (d.rejectionReason != null &&
                      d.rejectionReason!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Reason: ${d.rejectionReason}',
                      style: theme.bodySmall
                          ?.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Filename or description',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _uploadDoc(d.id, ctrl.text.trim()),
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Mark as uploaded'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _submitSection(TextTheme theme) {
    final p = _packet!;
    final requiredDocs = p.documentRequirements.where((d) => d.required);
    final allRequiredUploaded = requiredDocs.isEmpty ||
        requiredDocs.every(
          (d) =>
              d.status == 'uploaded' ||
              d.status == 'approved' ||
              d.status == 'rejected',
        );
    final alreadySubmitted =
        p.status == 'under_review' || p.status == 'approved' || p.status == 'rejected';

    String statusText;
    if (p.status == 'under_review') {
      statusText = 'Your packet is with your landlord for review.';
    } else if (p.status == 'approved') {
      statusText = 'Your landlord has approved this onboarding packet.';
    } else if (p.status == 'rejected') {
      statusText =
          'Some items were rejected. Update the highlighted documents and submit again.';
    } else {
      statusText = 'When you are ready, submit everything for review.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('3. Submit for review', style: theme.titleMedium),
        const SizedBox(height: 8),
        Text(statusText, style: theme.bodySmall),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: (!allRequiredUploaded || alreadySubmitted)
              ? null
              : _submitForReview,
          icon: const Icon(Icons.send_outlined),
          label: Text(alreadySubmitted ? 'Already submitted' : 'Submit to landlord'),
        ),
      ],
    );
  }

  Future<void> _acknowledgeLease() async {
    final typed = _typedNameCtrl.text.trim();
    if (typed.isEmpty || _packet == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(leaseOnboardingApiProvider);
      final updated = await api.acknowledgeLease(
        packetId: _packet!.id,
        typedName: typed,
      );
      _syncDocControllers(updated);
      setState(() {
        _packet = updated;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _uploadDoc(String docId, String filename) async {
    if (filename.isEmpty || _packet == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(leaseOnboardingApiProvider);
      final updated = await api.uploadTenantDocument(
        packetId: _packet!.id,
        docId: docId,
        filename: filename,
      );
      _syncDocControllers(updated);
      setState(() {
        _packet = updated;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _submitForReview() async {
    if (_packet == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(leaseOnboardingApiProvider);
      final updated =
          await api.submitTenantPacket(packetId: _packet!.id);
      _syncDocControllers(updated);
      setState(() {
        _packet = updated;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submitted. Your landlord will review and respond.'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _statusChip(TenantDocumentRequirement d, TextTheme theme) {
    Color color;
    String label;
    switch (d.status) {
      case 'approved':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'uploaded':
        color = Colors.blue;
        label = 'Uploaded';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Needs update';
        break;
      default:
        color = Colors.grey;
        label = d.required ? 'Required' : 'Optional';
        break;
    }
    return Chip(
      label: Text(label, style: theme.labelSmall?.copyWith(color: color)),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _OnboardingChecklist extends StatelessWidget {
  const _OnboardingChecklist({required this.packet});

  final LeasePacket packet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final steps = packet.inviteSteps;
    String labelFor(String code) {
      switch (code) {
        case 'invite_sent':
          return 'Invite sent';
        case 'lease_reviewed':
          return 'Lease reviewed';
        case 'lease_accepted':
          return 'Lease accepted';
        case 'docs_uploaded':
          return 'Documents uploaded';
        case 'submitted_for_review':
          return 'Submitted for review';
        case 'landlord_reviewed':
          return 'Landlord reviewed';
        case 'completed':
          return 'Completed';
        default:
          return code;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your progress', style: theme.titleMedium),
        const SizedBox(height: 8),
        if (steps.isEmpty)
          Text(
            'Onboarding steps will appear here once available.',
            style: theme.bodySmall,
          )
        else
          ...steps.map((s) {
            return Row(
              children: [
                Icon(
                  s.completed
                      ? Icons.check_circle_outline
                      : Icons.radio_button_unchecked,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(labelFor(s.code), style: theme.bodySmall),
              ],
            );
          }),
      ],
    );
  }
}

class _TenantErrorBanner extends StatelessWidget {
  const _TenantErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

