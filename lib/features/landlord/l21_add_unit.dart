import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/backend/api_base_url.dart';
import '../../core/backend/dtos/unit_dto.dart';
import '../../core/state/providers.dart';

/// Minimal real Add Unit screen for landlords.
/// Expects arguments via ModalRoute:
/// { "propertyId": "<uuid-or-id>", "propertyLabel": "<optional human label>" }.
class AddUnitScreen extends ConsumerStatefulWidget {
  const AddUnitScreen({
    super.key,
    required this.propertyId,
    this.propertyLabel,
  });

  final String propertyId;
  final String? propertyLabel;

  @override
  ConsumerState<AddUnitScreen> createState() => _AddUnitScreenState();
}

class _AddUnitScreenState extends ConsumerState<AddUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _bedsController = TextEditingController();
  final _bathsController = TextEditingController();
  final _rentController = TextEditingController();

  bool _submitting = false;
  String? _errorMessage;
  bool _success = false;

  @override
  void dispose() {
    _labelController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyLabel = widget.propertyLabel ?? widget.propertyId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('L-21 • Add Unit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Property',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(
              propertyLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Unit label / number *',
                hintText: 'e.g. Unit 1A',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Unit label is required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bedsController,
                    decoration: const InputDecoration(
                      labelText: 'Bedrooms',
                      hintText: 'e.g. 2',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _bathsController,
                    decoration: const InputDecoration(
                      labelText: 'Bathrooms',
                      hintText: 'e.g. 1',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rentController,
              decoration: const InputDecoration(
                labelText: 'Rent (optional)',
                prefixText: '\$',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage!)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_success) ...[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Unit created.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: _submitting ? null : _handleSubmit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_submitting ? 'Saving…' : 'Save unit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
      _success = false;
    });

    final label = _labelController.text.trim();
    final beds = _bedsController.text.trim();
    final baths = _bathsController.text.trim();
    final rent = _rentController.text.trim();

    // Minimal logging to aid debugging / DoD.
    debugPrint(
      'AddUnitScreen submit: propertyId=${widget.propertyId}, '
      'label=$label, beds=$beds, baths=$baths, rent=$rent',
    );

    try {
      final baseUrl = await resolveApiBaseUrl();
      final uri =
          Uri.parse('$baseUrl/api/v1/properties/${widget.propertyId}/units');

      final token = ref.read(authTokenProvider);
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{
        'unitLabel': label,
        // Map UI fields into status later if needed; for now always vacant.
        'status': 'vacant',
      };

      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>?;
          if (json != null) {
            final unit = UnitDto.fromJson(json);
            debugPrint('AddUnitScreen success: created unit ${unit.id}');
          }
        } catch (e) {
          debugPrint('AddUnitScreen parse warning: $e');
        }
        setState(() {
          _submitting = false;
          _success = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit created.')),
        );
        Navigator.pop(context, true);
        return;
      }

      String message = 'Unable to save unit. Please try again.';
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>?;
        final apiMessage = json?['message'] as String?;
        if (apiMessage != null && apiMessage.isNotEmpty) {
          message = apiMessage;
        }
      } catch (_) {
        // ignore parse errors, keep generic message
      }
      debugPrint(
        'AddUnitScreen backend error: status=${response.statusCode} body=${response.body}',
      );
      setState(() {
        _submitting = false;
        _errorMessage = message;
      });
    } catch (e, st) {
      debugPrint('AddUnitScreen error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = 'Unable to save unit. Please check your connection.';
      });
    }
  }
}

