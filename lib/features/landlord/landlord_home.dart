import 'package:flutter/material.dart';

class LandlordHome extends StatelessWidget {
  const LandlordHome({super.key});

  @override
  Widget build(BuildContext context) {
    return _HiFiHome(
      header: 'Portfolio Overview',
      kpis: const [
        _Kpi('Units', '24'),
        _Kpi('Occupied', '21'),
        _Kpi('Delinquent', '2'),
      ],
      cards: const [
        _CardLine('Rent Board', 'View who paid & follow-ups', Icons.receipt_long),
        _CardLine('Maintenance Inbox', 'New requests: 5', Icons.build_circle),
        _CardLine('Leases', '3 expiring in 30 days', Icons.description),
      ],
      listTitle: 'Today',
      items: const [
        _ListItem('Collect rent from Unit 3B', 'Send reminder', Icons.notifications_active),
        _ListItem('Approve contractor estimate', 'Kitchen sink repair', Icons.task_alt),
        _ListItem('Review applicant', '2 new applications', Icons.person_search),
      ],
    );
  }
}

class _HiFiHome extends StatelessWidget {
  final String header;
  final List<_Kpi> kpis;
  final List<_CardLine> cards;
  final String listTitle;
  final List<_ListItem> items;

  const _HiFiHome({
    required this.header,
    required this.kpis,
    required this.cards,
    required this.listTitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      children: [
        Text(header, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: kpis.map((k) => Expanded(child: _KpiCard(k: k))).toList(),
        ),
        const SizedBox(height: 14),
        ...cards.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ActionCard(c: c),
        )),
        const SizedBox(height: 8),
        Text(listTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...items.map((i) => _ListTileItem(i: i)),
      ],
    );
  }
}

class _Kpi { final String label; final String value; const _Kpi(this.label, this.value); }
class _CardLine { final String title; final String subtitle; final IconData icon; const _CardLine(this.title, this.subtitle, this.icon); }
class _ListItem { final String title; final String subtitle; final IconData icon; const _ListItem(this.title, this.subtitle, this.icon); }

class _KpiCard extends StatelessWidget {
  final _Kpi k;
  const _KpiCard({required this.k});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k.value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(k.label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final _CardLine c;
  const _ActionCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(c.icon),
        title: Text(c.title),
        subtitle: Text(c.subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demo: ${c.title}')),
        ),
      ),
    );
  }
}

class _ListTileItem extends StatelessWidget {
  final _ListItem i;
  const _ListTileItem({required this.i});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(i.icon),
        title: Text(i.title),
        subtitle: Text(i.subtitle),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demo: ${i.title}')),
        ),
      ),
    );
  }
}
