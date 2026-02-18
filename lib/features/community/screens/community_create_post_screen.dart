import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/providers.dart';
import '../models/community_models.dart';

/// Create post flow (landlord only). Fields: Audience, Scope, Title, Body, Priority.
class CommunityCreatePostScreen extends ConsumerStatefulWidget {
  final bool isLandlord;
  final String authorName;
  final String authorRole;
  final VoidCallback onCreated;

  const CommunityCreatePostScreen({
    super.key,
    required this.isLandlord,
    required this.authorName,
    required this.authorRole,
    required this.onCreated,
  });

  @override
  ConsumerState<CommunityCreatePostScreen> createState() => _CommunityCreatePostScreenState();
}

class _CommunityCreatePostScreenState extends ConsumerState<CommunityCreatePostScreen> {
  CommunityAudience _audience = CommunityAudience.tenants;
  CommunityScopeType _scope = CommunityScopeType.property;
  CommunityPostPriority _priority = CommunityPostPriority.info;
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    return title.isNotEmpty && body.isNotEmpty;
  }

  Future<void> _submit() async {
    if (!_canSubmit || _loading) return;

    setState(() => _loading = true);

    final post = CommunityPost(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      scopeType: _scope,
      scopeId: _scope == CommunityScopeType.property ? 'p1' : _scope == CommunityScopeType.unit ? 'u1' : null,
      authorId: 'current',
      authorName: widget.authorName,
      authorRole: widget.authorRole,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      createdAt: DateTime.now(),
      commentCount: 0,
      priority: _priority,
      audience: _audience,
    );

    await ref.read(reposProvider).communityRepo.createPost(post);
    if (mounted) {
      widget.onCreated();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Announcement'),
        actions: [
          TextButton(
            onPressed: _canSubmit && !_loading ? _submit : null,
            child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Post'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Audience', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<CommunityAudience>(
              segments: const [
                ButtonSegment(value: CommunityAudience.tenants, label: Text('Tenants only')),
                ButtonSegment(value: CommunityAudience.all, label: Text('Everyone')),
              ],
              selected: {_audience},
              onSelectionChanged: (s) => setState(() => _audience = s.first),
            ),
            const SizedBox(height: 20),
            Text('Scope', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: CommunityScopeType.values.map((s) {
                return FilterChip(
                  label: Text(s.label),
                  selected: _scope == s,
                  onSelected: (_) => setState(() => _scope = s),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Priority', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: CommunityPostPriority.values.map((p) {
                return FilterChip(
                  label: Text(p.label),
                  selected: _priority == p,
                  onSelected: (_) => setState(() => _priority = p),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Short and clear',
              ),
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Body',
                hintText: 'Write something useful for the community…',
              ),
              minLines: 4,
              maxLines: 8,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSubmit && !_loading ? _submit : null,
                child: const Text('Create Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
