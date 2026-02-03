import 'package:flutter/material.dart';
import '../data/community_mock_data.dart';
import '../models/community_models.dart';

class CommunityCreatePostSheet extends StatefulWidget {
  final bool isLandlord;
  final CommunityScope? defaultScope;
  final void Function(CommunityPost post) onSubmit;

  const CommunityCreatePostSheet({
    super.key,
    required this.isLandlord,
    required this.defaultScope,
    required this.onSubmit,
  });

  @override
  State<CommunityCreatePostSheet> createState() => _CommunityCreatePostSheetState();
}

class _CommunityCreatePostSheetState extends State<CommunityCreatePostSheet> {
  late CommunityPostType _type;
  CommunityScope? _scope;
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = CommunityPostType.post;
    _scope = widget.defaultScope ?? CommunityMockData.scopes.first;
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  bool get _needsTitle => _type == CommunityPostType.announcement || _type == CommunityPostType.alert || _type == CommunityPostType.event;

  CommunityAuthor get _author =>
      widget.isLandlord ? CommunityMockData.landlord : CommunityMockData.tenantB;

  List<DropdownMenuItem<CommunityPostType>> _typeItems() {
    final items = <CommunityPostType>[
      CommunityPostType.post,
      CommunityPostType.event,
      if (widget.isLandlord) CommunityPostType.announcement,
      if (widget.isLandlord) CommunityPostType.alert,
    ];

    String label(CommunityPostType t) {
      switch (t) {
        case CommunityPostType.announcement:
          return 'Announcement';
        case CommunityPostType.alert:
          return 'Alert';
        case CommunityPostType.post:
          return 'Post';
        case CommunityPostType.event:
          return 'Event';
      }
    }

    return items
        .map((t) => DropdownMenuItem(
              value: t,
              child: Text(label(t)),
            ))
        .toList();
  }

  void _submit() {
    final body = _body.text.trim();
    if (body.isEmpty) return;

    final title = _title.text.trim();
    if (_needsTitle && title.isEmpty) return;

    final post = CommunityPost(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      type: _type,
      scope: _scope ?? CommunityMockData.scopes.first,
      title: _needsTitle ? title : null,
      body: body,
      createdAt: DateTime.now(),
      author: _author,
      isPinned: (_type == CommunityPostType.announcement || _type == CommunityPostType.alert) && widget.isLandlord,
      likeCount: 0,
      commentCount: 0,
      iLiked: false,
    );

    widget.onSubmit(post);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scopes = CommunityMockData.scopes;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Create', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<CommunityPostType>(
                    value: _type,
                    items: _typeItems(),
                    onChanged: (v) => setState(() => _type = v ?? CommunityPostType.post),
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<CommunityScope>(
                    value: _scope,
                    items: scopes
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                        .toList(),
                    onChanged: (v) => setState(() => _scope = v),
                    decoration: const InputDecoration(labelText: 'Audience'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_needsTitle)
              TextField(
                controller: _title,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Short and clear',
                ),
              ),

            if (_needsTitle) const SizedBox(height: 12),

            TextField(
              controller: _body,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Write something useful for the community…',
              ),
            ),

            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('Post'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
