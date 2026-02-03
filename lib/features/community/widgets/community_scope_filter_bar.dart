import 'package:flutter/material.dart';
import '../models/community_models.dart';

class CommunityScopeFilterBar extends StatelessWidget {
  final List<CommunityScope> scopes;
  final CommunityScope? selected;
  final ValueChanged<CommunityScope?> onChanged;

  const CommunityScopeFilterBar({
    super.key,
    required this.scopes,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          ...scopes.map((s) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(s.label),
                selected: selected?.id == s.id,
                onSelected: (_) => onChanged(s),
              ),
            );
          }),
        ],
      ),
    );
  }
}
