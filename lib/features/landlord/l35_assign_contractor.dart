import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _Contractor {
  final String name;
  final double rating;
  final String distance;

  const _Contractor({
    required this.name,
    required this.rating,
    required this.distance,
  });
}

class AssignContractorScreen extends ConsumerStatefulWidget {
  const AssignContractorScreen({super.key});

  @override
  ConsumerState<AssignContractorScreen> createState() =>
      _AssignContractorScreenState();
}

class _AssignContractorScreenState
    extends ConsumerState<AssignContractorScreen> {
  static const _contractors = <_Contractor>[
    _Contractor(name: "Mike's Plumbing", rating: 4.8, distance: '3.2 mi'),
    _Contractor(name: 'QuickFix Repairs', rating: 4.5, distance: '5.1 mi'),
    _Contractor(name: "Bob's Handyman", rating: 4.2, distance: '7.8 mi'),
  ];

  int? _selectedIndex;
  bool _assigning = false;

  Future<void> _assign() async {
    if (_selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a contractor')),
      );
      return;
    }
    setState(() => _assigning = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _assigning = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_contractors[_selectedIndex!].name} assigned (demo)',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('L-35 • Assign Contractor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.build_outlined,
                      color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TCK-1007 • Leaking sink',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          'Unit 2B • High priority',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Available Contractors',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _contractors.length; i++)
            Card(
              child: RadioListTile<int>(
                value: i,
                groupValue: _selectedIndex,
                onChanged: (v) => setState(() => _selectedIndex = v),
                title: Text(_contractors[i].name),
                subtitle: Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${_contractors[i].rating}'),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(_contractors[i].distance),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _assigning ? null : _assign,
            icon: _assigning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(_assigning ? 'Assigning…' : 'Assign Selected'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invite New Contractor (demo)'),
                ),
              );
            },
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Invite New Contractor'),
          ),
        ],
      ),
    );
  }
}
