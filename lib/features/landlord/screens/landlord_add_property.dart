import 'package:flutter/material.dart';

class LandlordAddPropertyScreen extends StatefulWidget {
  const LandlordAddPropertyScreen({super.key});

  @override
  State<LandlordAddPropertyScreen> createState() => _LandlordAddPropertyScreenState();
}

class _LandlordAddPropertyScreenState extends State<LandlordAddPropertyScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  String _type = 'Residential';

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Property')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Property name')),
          const SizedBox(height: 12),
          TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: const [
              DropdownMenuItem(value: 'Residential', child: Text('Residential')),
              DropdownMenuItem(value: 'Commercial', child: Text('Commercial')),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'Residential'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save (demo)'),
          ),
        ],
      ),
    );
  }
}
