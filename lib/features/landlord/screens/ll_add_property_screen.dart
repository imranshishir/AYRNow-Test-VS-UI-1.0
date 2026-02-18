import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/ui/shared/switch_role_menu.dart';
import 'package:ayrnow/core/api/providers/properties_provider.dart';
import 'package:ayrnow/core/api/providers/api_client_provider.dart';
import 'package:ayrnow/core/api/providers/feature_flags_provider.dart';
import 'package:ayrnow/core/api/endpoints/properties_api.dart';

class LlAddPropertyScreen extends ConsumerStatefulWidget {
  const LlAddPropertyScreen({super.key});

  @override
  ConsumerState<LlAddPropertyScreen> createState() => _LlAddPropertyScreenState();
}

class _LlAddPropertyScreenState extends ConsumerState<LlAddPropertyScreen> {
  final _name = TextEditingController();
  final _city = TextEditingController();
  String _type = 'Residential';
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() {
        _error = 'Property name is required';
      });
      return;
    }
    final useRealApi = ref.read(featureFlagsProvider).properties;
    if (!useRealApi) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo: property saved (mock mode)')),
        );
        Navigator.of(context).pop();
      }
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final dio = ref.read(apiClientProvider);
      final api = PropertiesApi(dio);
      await api.create(
        name: name,
        city: _city.text.trim().isNotEmpty ? _city.text.trim() : null,
      );
      if (!mounted) return;
      ref.invalidate(propertiesListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property created')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = 'Failed to create property. Check connection.';
      });
    }
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
            onChanged: _isSubmitting
                ? null
                : (v) => setState(() => _type = v ?? 'Residential'),
          ),
          const SizedBox(height: 14),
          Text('Property name', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'e.g., Harlem Heights'),
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 14),
          Text('City / Location',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _city,
            decoration: const InputDecoration(hintText: 'e.g., Buffalo, NY'),
            enabled: !_isSubmitting,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _isSubmitting ? null : _save,
            icon: _isSubmitting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSubmitting ? 'Saving...' : 'Save property'),
          ),
        ],
      ),
    );
  }
}
