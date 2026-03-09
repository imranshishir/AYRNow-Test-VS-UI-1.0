import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/backend/api_base_url.dart';
import '../../core/state/providers.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addr1Ctrl = TextEditingController();
  final _addr2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addr1Ctrl.dispose();
    _addr2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final token = ref.read(authTokenProvider);
    if (token == null || token.isEmpty || token == 'dev-bypass') {
      setState(() => _error = 'Please log in with a landlord account to add properties.');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      final baseUrl = await resolveApiBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/properties');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final body = jsonEncode({
        'name': _nameCtrl.text.trim(),
        'address1': _addr1Ctrl.text.trim().isEmpty ? null : _addr1Ctrl.text.trim(),
        'city': _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim().isEmpty ? null : _stateCtrl.text.trim(),
        'postalCode': _zipCtrl.text.trim().isEmpty ? null : _zipCtrl.text.trim(),
      });
      final res = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ref.read(landlordPropertiesRefreshProvider.notifier).state++;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property created.')));
        Map<String, String>? created;
        try {
          final j = jsonDecode(res.body) as Map?;
          if (j != null) {
            final id = j['id']?.toString();
            final name = j['name'] as String? ?? _nameCtrl.text.trim();
            if (id != null && id.isNotEmpty) created = {'propertyId': id, 'propertyLabel': name};
          }
        } catch (_) {}
        if (!mounted) return;
        Navigator.pop(context, created);
        return;
      }
      if (res.statusCode == 401) {
        setState(() { _submitting = false; _error = 'Session expired. Please log in again.'; });
        return;
      }
      String msg = 'Unable to create property.';
      try {
        final j = jsonDecode(res.body) as Map?;
        if (j?['message'] != null) msg = j!['message'] as String;
      } catch (_) {}
      setState(() { _submitting = false; _error = msg; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _submitting = false; _error = 'Network error. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('L-20 • Add Property')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Property Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addr1Ctrl,
              decoration: const InputDecoration(labelText: 'Address Line 1'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Address is required'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addr2Ctrl,
              decoration: const InputDecoration(labelText: 'Address Line 2'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityCtrl,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stateCtrl,
                    decoration: const InputDecoration(labelText: 'State'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _zipCtrl,
                    decoration: const InputDecoration(labelText: 'Zip Code'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_submitting ? 'Saving…' : 'Save Property'),
            ),
          ],
        ),
      ),
    );
  }
}
