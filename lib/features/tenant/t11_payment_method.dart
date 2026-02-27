import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  int _selectedIndex = 0;

  static const _methods = <_PaymentMethod>[
    _PaymentMethod(
      icon: Icons.account_balance_outlined,
      label: 'Bank account ending ****1234',
      subtitle: 'Checking • First National',
    ),
    _PaymentMethod(
      icon: Icons.credit_card_outlined,
      label: 'Credit card ending ****5678',
      subtitle: 'Visa • Expires 08/27',
    ),
    _PaymentMethod(
      icon: Icons.apple,
      label: 'Apple Pay',
      subtitle: 'Connected',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('T-11 • Payment Method')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (int i = 0; i < _methods.length; i++)
            Card(
              child: RadioListTile<int>(
                value: i,
                groupValue: _selectedIndex,
                onChanged: (v) => setState(() => _selectedIndex = v!),
                secondary: Icon(_methods[i].icon),
                title: Text(_methods[i].label),
                subtitle: Text(_methods[i].subtitle),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment method updated (demo)'),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
            child: const Text('Add new method'),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethod {
  final IconData icon;
  final String label;
  final String subtitle;

  const _PaymentMethod({
    required this.icon,
    required this.label,
    required this.subtitle,
  });
}
