import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/providers.dart';

class PayRentScreen extends ConsumerStatefulWidget {
  const PayRentScreen({super.key});

  @override
  ConsumerState<PayRentScreen> createState() => _PayRentScreenState();
}

class _PayRentScreenState extends ConsumerState<PayRentScreen> {
  bool autopay = false;
  bool processing = false;
  String? error;
  bool? success;

  @override
  Widget build(BuildContext context) {
    final repos = ref.read(reposProvider);
    final amount = ref.watch(tenantAmountDueProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('T-10 • Pay Rent')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Amount due', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('\$${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: autopay,
                    onChanged: (v) => setState(() => autopay = v),
                    title: const Text('Enable AutoPay'),
                    subtitle: const Text('Automatically pay on the due date (demo toggle).'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (error != null) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline),
                    const SizedBox(width: 10),
                    Expanded(child: Text(error!)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (success == true) ...[
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline),
                    SizedBox(width: 10),
                    Expanded(child: Text('Payment successful (mock). Receipt available in T-14.')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton.icon(
            onPressed: processing ? null : () async {
              setState(() { processing = true; error = null; success = null; });
              final ok = await repos.simulatePayment(amount: amount);
              setState(() {
                processing = false;
                success = ok;
                if (!ok) error = 'Payment failed (mock). Please try again.';
              });
            },
            icon: processing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.lock_outline),
            label: Text(processing ? 'Processing…' : 'Pay now'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/T-11'),
            child: const Text('Choose payment method (T-11)'),
          )
        ],
      ),
    );
  }
}
