import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/community_mock_data.dart';
import '../models/community_models.dart';
import '../store/community_store.dart';

class CommunitySosAlertScreen extends ConsumerStatefulWidget {
  final bool isLandlord;
  const CommunitySosAlertScreen({super.key, required this.isLandlord});

  @override
  ConsumerState<CommunitySosAlertScreen> createState() => _CommunitySosAlertScreenState();
}

class _CommunitySosAlertScreenState extends ConsumerState<CommunitySosAlertScreen> {
  static const int _maxSeconds = 60;

  int _remaining = _maxSeconds;
  Timer? _timer;

  double _slide = 0.0;
  bool _sent = false;

  CommunityScope? _scope;
  final _details = TextEditingController();

  @override
  void initState() {
    super.initState();
    final scopes = CommunityMockData.scopes;
    _scope = scopes.firstWhere(
      (s) => s.type == CommunityScopeType.building,
      orElse: () => scopes.first,
    );
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _remaining = _maxSeconds;
      _slide = 0.0;
      _sent = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _remaining -= 1;
        if (_remaining <= 0) {
          t.cancel();
          _remaining = 0;
          _slide = 0.0;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _details.dispose();
    super.dispose();
  }

  void _send() {
    if (_sent) return;
    final scope = _scope;
    if (scope == null) return;

    final body = _details.text.trim().isEmpty
        ? 'Emergency SOS alert triggered. Please check on neighbors and follow building safety instructions.'
        : _details.text.trim();

    final author = widget.isLandlord ? CommunityMockData.landlord : CommunityMockData.tenantB;

    final post = CommunityPost(
      id: 'sos-${DateTime.now().millisecondsSinceEpoch}',
      type: CommunityPostType.alert,
      scope: scope,
      title: 'SOS Emergency Alert',
      body: body,
      createdAt: DateTime.now(),
      author: author,
      isPinned: true,
      likeCount: 0,
      commentCount: 0,
      iLiked: false,
    );

    ref.read(communityStoreProvider.notifier).addPost(post);

    setState(() => _sent = true);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SOS alert posted to ${scope.label} (mock).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final buildingScopes =
        CommunityMockData.scopes.where((s) => s.type == CommunityScopeType.building).toList();
    final scopeChoices = buildingScopes.isNotEmpty ? buildingScopes : CommunityMockData.scopes;

    final canSlide = _remaining > 0 && !_sent;

    return Scaffold(
      appBar: AppBar(title: const Text('SOS Alert')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Use this only for real emergencies.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This will post a building-wide SOS alert (mock). Later this triggers push notifications.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<CommunityScope>(
            value: _scope,
            items: scopeChoices.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
            onChanged: (v) => setState(() => _scope = v),
            decoration: const InputDecoration(
              labelText: 'Send to',
              helperText: 'Choose the building to notify',
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _details,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Emergency details (optional)',
              hintText: 'Example: Fire alarm on Floor 2. Evacuate using stairs.',
            ),
          ),

          const SizedBox(height: 18),

          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _remaining > 0 ? 'Confirm within: $_remaining s' : 'Time expired — restart',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: _startCountdown,
                    child: const Text('Restart'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Slide to send SOS',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Opacity(
                    opacity: canSlide ? 1.0 : 0.5,
                    child: Slider(
                      value: canSlide ? _slide : 0.0,
                      onChanged: canSlide
                          ? (v) => setState(() => _slide = v)
                          : null,
                      onChangeEnd: canSlide
                          ? (v) {
                              if (v >= 0.98) {
                                _send();
                              } else {
                                setState(() => _slide = 0.0);
                              }
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    canSlide
                        ? 'Push all the way to confirm.'
                        : 'Restart the timer to enable sliding.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('CANCEL'),
          ),

          const SizedBox(height: 14),
          Text(
            'Tip: In a real emergency, call local emergency services immediately.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
