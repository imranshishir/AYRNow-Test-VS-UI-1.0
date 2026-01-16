import 'package:flutter/material.dart';

class SpecScreen extends StatelessWidget {
  final String id;
  final String title;
  final String purpose;
  final List<String> components;
  final List<String> actions;
  final List<String> states;

  const SpecScreen({
    super.key,
    required this.id,
    required this.title,
    required this.purpose,
    required this.components,
    required this.actions,
    required this.states,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$id • $title')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _h('Purpose'),
          Text(purpose),
          const SizedBox(height: 16),
          _h('Layout / Components'),
          ...components.map(_b),
          const SizedBox(height: 16),
          _h('Primary Actions'),
          ...actions.map(_b),
          const SizedBox(height: 16),
          _h('States'),
          Wrap(spacing: 8, runSpacing: 8, children: states.map((s) => Chip(label: Text(s))).toList()),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
          const SizedBox(height: 12),
          const Text('Dev TODO: replace this placeholder with real UI.'),
        ],
      ),
    );
  }

  Widget _h(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget _b(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• '), Expanded(child: Text(t))]),
  );
}
