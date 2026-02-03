import 'package:flutter/material.dart';

class ContractorScheduleScreen extends StatelessWidget {
  const ContractorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        Text('Schedule', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text('Your upcoming jobs (HIFI skeleton).', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        _DayCard(day: 'Today', items: const [
          _SchedItem(time: '2:30 PM', title: 'Harlem Heights • Apt 2B', subtitle: 'Plumbing • Leaking faucet'),
        ]),
        const SizedBox(height: 12),
        _DayCard(day: 'Tomorrow', items: const [
          _SchedItem(time: '10:00 AM', title: 'Elmwood Plaza • Store 12', subtitle: 'Electrical • Light fixture'),
          _SchedItem(time: '3:00 PM', title: 'Lakeview Villas • Apt 03', subtitle: 'HVAC • Heater noise'),
        ]),
      ],
    );
  }
}

class _SchedItem {
  final String time;
  final String title;
  final String subtitle;
  const _SchedItem({required this.time, required this.title, required this.subtitle});
}

class _DayCard extends StatelessWidget {
  final String day;
  final List<_SchedItem> items;
  const _DayCard({required this.day, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ...items.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 80, child: Text(i.time, style: Theme.of(context).textTheme.labelLarge)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(i.title, style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text(i.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                        ]),
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
