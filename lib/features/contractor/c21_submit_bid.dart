import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _MaterialRow {
  final TextEditingController nameController;
  final TextEditingController costController;

  _MaterialRow()
      : nameController = TextEditingController(),
        costController = TextEditingController();

  void dispose() {
    nameController.dispose();
    costController.dispose();
  }
}

class SubmitBidScreen extends ConsumerStatefulWidget {
  const SubmitBidScreen({super.key});

  @override
  ConsumerState<SubmitBidScreen> createState() => _SubmitBidScreenState();
}

class _SubmitBidScreenState extends ConsumerState<SubmitBidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bidAmountController = TextEditingController();
  final _notesController = TextEditingController();
  String _estimatedCompletion = 'Same day';
  final List<_MaterialRow> _materials = [_MaterialRow()];

  static const _completionOptions = [
    'Same day',
    '1-2 days',
    '3-5 days',
    '1 week+',
  ];

  double get _bidAmount {
    return double.tryParse(_bidAmountController.text) ?? 0;
  }

  double get _materialsTotal {
    double total = 0;
    for (final row in _materials) {
      total += double.tryParse(row.costController.text) ?? 0;
    }
    return total;
  }

  double get _grandTotal => _bidAmount + _materialsTotal;

  @override
  void dispose() {
    _bidAmountController.dispose();
    _notesController.dispose();
    for (final row in _materials) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('C-21 • Submit Bid')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('JOB-501', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Harlem Rd Apartments',
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 2),
                    Text('Replace faucet', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bidAmountController,
              decoration: const InputDecoration(
                labelText: 'Bid Amount (\$)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter a bid amount';
                if (double.tryParse(v) == null) return 'Enter a valid number';
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _estimatedCompletion,
              decoration: const InputDecoration(
                labelText: 'Estimated Completion',
                prefixIcon: Icon(Icons.schedule),
              ),
              items: _completionOptions
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _estimatedCompletion = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes / Message',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text('Materials', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._materials.asMap().entries.map((entry) {
              final i = entry.key;
              final row = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: row.nameController,
                        decoration: InputDecoration(
                          labelText: 'Item ${i + 1}',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: row.costController,
                        decoration: const InputDecoration(
                          labelText: 'Cost (\$)',
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (_materials.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            _materials[i].dispose();
                            _materials.removeAt(i);
                          });
                        },
                      ),
                  ],
                ),
              );
            }),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _materials.add(_MaterialRow())),
                icon: const Icon(Icons.add),
                label: const Text('Add material'),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: theme.textTheme.titleMedium),
                Text(
                  '\$${_grandTotal.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bid submitted (demo).')),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Submit Bid'),
            ),
          ],
        ),
      ),
    );
  }
}
