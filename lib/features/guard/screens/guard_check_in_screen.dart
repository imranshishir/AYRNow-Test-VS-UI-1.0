import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ayrnow/features/guard/screens/guard_demo_data.dart';

class GuardCheckInScreen extends StatefulWidget {
  final GuardDemoStore store;
  final GuardApproval approval;
  const GuardCheckInScreen(
      {super.key, required this.store, required this.approval});

  @override
  State<GuardCheckInScreen> createState() => _GuardCheckInScreenState();
}

class _GuardCheckInScreenState extends State<GuardCheckInScreen> {
  final _plate = TextEditingController();
  final _party = TextEditingController(text: '1');
  bool _otpVerified = false;
  late final String _otp;

  @override
  void initState() {
    super.initState();
    _otp = _generateOtp();
  }

  @override
  void dispose() {
    _plate.dispose();
    _party.dispose();
    super.dispose();
  }

  String _generateOtp() {
    final r = Random();
    final n = 100000 + r.nextInt(900000);
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.approval;
    final typeLabel = switch (a.type) {
      VisitorType.guest => 'Guest',
      VisitorType.delivery => 'Delivery',
      VisitorType.vendor => 'Vendor',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arrival Check-In'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.visitorName,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Row(children: [
                    Chip(label: Text(typeLabel)),
                    const SizedBox(width: 8),
                    Text('ID: ${a.id}')
                  ]),
                  const SizedBox(height: 6),
                  Text('${a.propertyName} • ${a.unitLabel}',
                      style: Theme.of(context).textTheme.bodyMedium),
                  if (a.notes.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(a.notes),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _verifyCard(context),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Entry Details',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _party,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Party size',
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _plate,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle plate (optional)',
                      prefixIcon: Icon(Icons.directions_car_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _otpVerified
                ? () {
                    final partySize = int.tryParse(_party.text.trim()) ?? 1;
                    final plate =
                        _plate.text.trim().isEmpty ? null : _plate.text.trim();
                    widget.store.checkInFromApproval(
                      approval: a,
                      passCode: 'PASS-$_otp',
                      partySize: partySize.clamp(1, 20),
                      vehiclePlate: plate,
                    );
                    Navigator.of(context).pop(true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Checked-in (demo). Added to Active Visitors.')),
                    );
                  }
                : null,
            icon: const Icon(Icons.badge_outlined),
            label: const Text('Issue Pass & Check-In'),
          ),
          const SizedBox(height: 10),
          Text(
            'Note: OTP/QR + photo/ID capture can be added later. This is a HIFI skeleton with real navigation & state.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _verifyCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verify (OTP / QR placeholder)',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Demo OTP: $_otp\n(pretend this came from tenant approval screen)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () => setState(() => _otpVerified = true),
                    label: const Text('Scan QR'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: Icon(_otpVerified
                        ? Icons.check_circle
                        : Icons.verified_outlined),
                    onPressed: () => setState(() => _otpVerified = true),
                    label: Text(_otpVerified ? 'Verified' : 'Verify OTP'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
