import 'package:flutter/material.dart';
import 'package:ayrnow/ui/shared/switch_role_menu.dart';

class LlAddPropertyScreen extends StatefulWidget {
  const LlAddPropertyScreen({super.key});

  @override
  State<LlAddPropertyScreen> createState() => _LlAddPropertyScreenState();
}

class _LlAddPropertyScreenState extends State<LlAddPropertyScreen> {
  final _name = TextEditingController();
  final _city = TextEditingController();
  String _type = 'Residential';

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property'),
        actions: const [SwitchRoleMenu()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text('Property type', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _type,
            items: const [
              DropdownMenuItem(
                  value: 'Residential',
                  child: Text('Residential (apartments / homes)')),
              DropdownMenuItem(
                  value: 'Commercial',
                  child: Text('Commercial (stores / offices)')),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'Residential'),
          ),
          const SizedBox(height: 14),
          Text('Property name', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
              controller: _name,
              decoration:
                  const InputDecoration(hintText: 'e.g., Harlem Heights')),
          const SizedBox(height: 14),
          Text('City / Location',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
              controller: _city,
              decoration: const InputDecoration(hintText: 'e.g., Buffalo, NY')),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Demo: property saved (next: connect to real data)')),
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.save),
            label: const Text('Save property'),
          ),
        ],
      ),
    );
  }
}
