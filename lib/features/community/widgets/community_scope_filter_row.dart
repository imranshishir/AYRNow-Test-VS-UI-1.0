import 'package:flutter/material.dart';
import '../models/community_models.dart';
import '../data/community_mock_data.dart';

class CommunityScopeFilterRow extends StatelessWidget {
  final CommunityScope? selected;
  final ValueChanged<CommunityScope?> onChanged;

  const CommunityScopeFilterRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scopes = CommunityMockData.scopes;

    return Material(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
            const SizedBox(width: 8),
            ...scopes.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      s.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                    selected: selected?.id == s.id,
                    onSelected: (_) => onChanged(s),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
