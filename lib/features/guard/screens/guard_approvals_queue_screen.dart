import 'package:flutter/material.dart';
import 'package:ayrnow/features/guard/screens/guard_demo_data.dart';
import 'package:ayrnow/features/guard/screens/guard_check_in_screen.dart';
import 'package:ayrnow/features/guard/screens/guard_incident_report_screen.dart';

class GuardApprovalsQueueScreen extends StatefulWidget {
  final GuardDemoStore store;
  const GuardApprovalsQueueScreen({super.key, required this.store});

  @override
  State<GuardApprovalsQueueScreen> createState() =>
      _GuardApprovalsQueueScreenState();
}

class _GuardApprovalsQueueScreenState extends State<GuardApprovalsQueueScreen> {
  String _query = '';
  VisitorType? _type;

  @override
  Widget build(BuildContext context) {
    final approvals = widget.store.approvals.where((a) {
      final q = _query.trim().toLowerCase();
      final matchesQ = q.isEmpty ||
          a.visitorName.toLowerCase().contains(q) ||
          a.unitLabel.toLowerCase().contains(q) ||
          a.propertyName.toLowerCase().contains(q) ||
          a.id.toLowerCase().contains(q);
      final matchesType = _type == null || a.type == _type;
      return matchesQ && matchesType;
    }).toList()
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approvals Queue'),
        actions: [
          IconButton(
            tooltip: 'Report incident',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      GuardIncidentReportScreen(store: widget.store),
                ),
              );
            },
            icon: const Icon(Icons.report_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          _filters(context),
          const SizedBox(height: 12),
          if (approvals.isEmpty)
            _emptyState(context)
          else
            ...approvals.map((a) => _approvalCard(context, a)),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search / Filter',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by visitor, unit, property, id…',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<VisitorType?>(
              value: _type,
              onChanged: (v) => setState(() => _type = v),
              items: const [
                DropdownMenuItem(value: null, child: Text('All types')),
                DropdownMenuItem(
                    value: VisitorType.guest, child: Text('Guest')),
                DropdownMenuItem(
                    value: VisitorType.delivery, child: Text('Delivery')),
                DropdownMenuItem(
                    value: VisitorType.vendor, child: Text('Vendor')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _approvalCard(BuildContext context, GuardApproval a) {
    final typeLabel = switch (a.type) {
      VisitorType.guest => 'Guest',
      VisitorType.delivery => 'Delivery',
      VisitorType.vendor => 'Vendor',
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    a.visitorName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(typeLabel)),
              ],
            ),
            const SizedBox(height: 6),
            Text('${a.propertyName} • ${a.unitLabel}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('Approval ID: ${a.id}',
                style: Theme.of(context).textTheme.bodySmall),
            if (a.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(a.notes),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.block),
                    onPressed: () {
                      widget.store.denyApproval(a.id);
                      if (mounted) setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Denied (demo).')),
                      );
                    },
                    label: const Text('Deny'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.verified_outlined),
                    onPressed: () async {
                      final didCheckIn = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => GuardCheckInScreen(
                              store: widget.store, approval: a),
                        ),
                      );
                      if (didCheckIn == true && mounted) setState(() {});
                    },
                    label: const Text('Verify & Check-in'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 48),
            const SizedBox(height: 12),
            Text('No pending approvals',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Approvals requested by tenants/landlords will appear here.\n'
              'Use “Switch role” from the top-right menu to return to role selection.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
