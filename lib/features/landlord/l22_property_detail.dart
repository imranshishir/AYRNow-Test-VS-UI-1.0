import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/backend/api_base_url.dart';
import '../../core/state/providers.dart';

class PropertyUnitDto {
  PropertyUnitDto({
    required this.id,
    required this.label,
    this.status,
  });

  final String id;
  final String label;
  final String? status;

  factory PropertyUnitDto.fromJson(Map<String, dynamic> json) {
    return PropertyUnitDto(
      id: json['id']?.toString() ?? '',
      label: json['unitLabel'] as String? ?? json['label']?.toString() ?? '',
      status: json['status'] as String?,
    );
  }
}

class PropertyDetailScreen extends ConsumerStatefulWidget {
  const PropertyDetailScreen({super.key, this.initialUnitsFuture});

  /// For tests: allow injecting a precomputed future to avoid real network.
  final Future<List<PropertyUnitDto>>? initialUnitsFuture;

  static const _fallbackPropertyId = '33333333-3333-3333-3333-333333333333';
  static const _fallbackPropertyName = 'Harlem Rd Apartments';
  static const _address = '123 Harlem Rd, Buffalo, NY';
  static const _totalUnits = 4;

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  Future<List<PropertyUnitDto>>? _unitsFuture;
  String? _lastPropertyId;

  @override
  void initState() {
    super.initState();
    _unitsFuture = widget.initialUnitsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = args is Map ? args : const <String, dynamic>{};
    final propertyId =
        map['propertyId']?.toString() ?? PropertyDetailScreen._fallbackPropertyId;
    final propertyName =
        map['propertyLabel']?.toString() ?? PropertyDetailScreen._fallbackPropertyName;

    if (_unitsFuture == null || _lastPropertyId != propertyId) {
      _lastPropertyId = propertyId;
      _unitsFuture = _fetchUnits(propertyId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('L-22 • Property Detail'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Property (demo)')),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Property',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    propertyName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    PropertyDetailScreen._address,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.door_front_door_outlined,
                          size: 18, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      const Text(
                        '${PropertyDetailScreen._totalUnits} units',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.people_outlined,
                          size: 18, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      // This will be replaced with real occupancy once wired; keep demo text for now.
                      const Text(
                        '—/— occupied',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _goToAddUnit(propertyId, propertyName);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add unit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Units',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<PropertyUnitDto>>(
            future: _unitsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Unable to load units. Please try again.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _unitsFuture = _fetchUnits(propertyId);
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                );
              }
              final units = snapshot.data ?? const <PropertyUnitDto>[];
              if (units.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('No units yet.'),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _goToAddUnit(propertyId, propertyName),
                      icon: const Icon(Icons.add),
                      label: const Text('Add unit'),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  for (final u in units)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.meeting_room_outlined),
                        title: Text(u.label),
                        subtitle: u.status != null && u.status!.isNotEmpty
                            ? Text('Status: ${u.status}')
                            : null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/L-24',
                          arguments: {'unitId': u.id, 'unitLabel': u.label},
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<PropertyUnitDto>> _fetchUnits(String propertyId) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri = Uri.parse('$baseUrl/api/v1/properties/$propertyId/units');
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    final token = ref.read(authTokenProvider);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final res =
        await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return const <PropertyUnitDto>[];
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => PropertyUnitDto.fromJson(
                  e.cast<String, dynamic>(),
                ))
            .toList();
      }
      return const <PropertyUnitDto>[];
    }
    debugPrint(
      'PropertyDetailScreen _fetchUnits error: status=${res.statusCode} body=${res.body}',
    );
    throw Exception('Failed to load units (${res.statusCode})');
  }

  Future<void> _goToAddUnit(String propertyId, String propertyName) async {
    final result = await Navigator.pushNamed(
      context,
      '/L-21',
      arguments: {
        'propertyId': propertyId,
        'propertyLabel': propertyName,
      },
    );
    if (result == true) {
      setState(() {
        _unitsFuture = _fetchUnits(propertyId);
      });
    }
  }
}
