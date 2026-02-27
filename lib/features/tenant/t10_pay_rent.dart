import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

import '../../core/backend/stripe_config.dart';
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
    final amount = ref.watch(tenantAmountDueProvider);
    final lastPaymentId = ref.watch(lastPaymentIdProvider);
    final stripeEnabled = isStripeConfigured;

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
                  Text('\$${amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
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
          if (!stripeEnabled)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Card payments are not enabled in this build (missing STRIPE_PUBLISHABLE_KEY).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
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
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lastPaymentId != null
                            ? 'Payment submitted. ID: $lastPaymentId'
                            : 'Payment submitted.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton.icon(
            onPressed: (!stripeEnabled || processing)
                ? null
                : () async {
                    await _handlePay(context, amount);
                  },
            icon: processing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_outline),
            label: Text(processing ? 'Processing…' : 'Pay with card'),
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

  Future<void> _handlePay(BuildContext context, double amount) async {
    setState(() {
      processing = true;
      error = null;
      success = null;
    });
    try {
      // TODO: derive unitId from authenticated tenant/household context once wired to backend.
      const unitId = '44444444-4444-4444-4444-444444444444';
      final paymentsApi = ref.read(paymentsApiProvider);
      final intent = await paymentsApi.createPaymentIntent(
        unitId: unitId,
        amountDollars: amount.round(),
      );

      if (intent.clientSecret == null || intent.clientSecret!.isEmpty) {
        // Stubbed backend path: record payment without Stripe PaymentSheet.
        ref.read(lastPaymentIdProvider.notifier).state = intent.paymentId;
        setState(() {
          processing = false;
          success = true;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment recorded (stubbed).')),
          );
        }
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent.clientSecret!,
          merchantDisplayName: 'AYRNOW',
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      ref.read(lastPaymentIdProvider.notifier).state = intent.paymentId;
      setState(() {
        processing = false;
        success = true;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment submitted.')),
        );
      }
    } on StripeException catch (e) {
      setState(() {
        processing = false;
        error = e.error.localizedMessage ?? 'Payment was canceled or failed.';
      });
    } catch (e) {
      setState(() {
        processing = false;
        error = 'Unable to process payment. Please try again.';
      });
    }
  }
}
