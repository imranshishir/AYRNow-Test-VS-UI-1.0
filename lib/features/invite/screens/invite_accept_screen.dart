import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/api/endpoints/invites_api.dart';
import 'package:ayrnow/core/api/providers/api_client_provider.dart';
import 'package:ayrnow/core/api/providers/feature_flags_provider.dart';
import 'package:ayrnow/core/api/providers/leases_provider.dart';
import 'package:ayrnow/features/invite/store/invite_store.dart';
import 'package:ayrnow/features/invite/models/invite_models.dart';

class InviteAcceptScreen extends ConsumerStatefulWidget {
  final String code;
  const InviteAcceptScreen({super.key, required this.code});

  @override
  ConsumerState<InviteAcceptScreen> createState() => _InviteAcceptScreenState();
}

class _InviteAcceptScreenState extends ConsumerState<InviteAcceptScreen> {
  bool _accepting = false;

  @override
  Widget build(BuildContext context) {
    final useRealApi = ref.watch(featureFlagsProvider).invites;
    final invite = useRealApi ? null : ref.watch(inviteStoreProvider.notifier).findByCode(widget.code);

    if (!useRealApi && invite == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Accept Invite')),
        body: const Center(child: Text('Invite not found.')),
      );
    }

    if (useRealApi) {
      return Scaffold(
        appBar: AppBar(title: const Text('Accept Invite')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You have been invited to join a unit.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('Accept to activate your access. You must be logged in.'),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _accepting
                          ? null
                          : () => _acceptViaApi(context),
                      icon: _accepting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.verified_outlined),
                      label: Text(_accepting ? 'Accepting...' : 'Accept & activate'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _accepting ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Accept Invite')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${invite!.propertyName} • ${invite.unitName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Permission: ${invite.permission.label}'),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () {
                      final ok = ref.read(inviteStoreProvider.notifier).acceptInvite(widget.code);
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invite is no longer available.')),
                        );
                        Navigator.of(context).pop();
                        return;
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const _InviteSuccessScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Accept & activate'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptViaApi(BuildContext context) async {
    setState(() => _accepting = true);
    try {
      final dio = ref.read(apiClientProvider);
      final api = InvitesApi(dio);
      await api.accept(widget.code);
      ref.invalidate(activeLeaseProvider);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _InviteSuccessScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _accepting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${e.toString().split('\n').first}')),
      );
    }
  }
}

class _InviteSuccessScreen extends StatelessWidget {
  const _InviteSuccessScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                'Access activated',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You are now attached to this unit. You can view rent, submit tickets, and more from your dashboard.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                icon: const Icon(Icons.home),
                label: const Text('Back to dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
