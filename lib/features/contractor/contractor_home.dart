import 'package:flutter/material.dart';

class ContractorHome extends StatelessWidget {
  const ContractorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      children: [
        Text('Jobs Feed', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...[
          ('Kitchen sink leak', 'Distance: 2.1 mi • Est: \$220', Icons.plumbing),
          ('HVAC check', 'Distance: 4.7 mi • Est: \$180', Icons.ac_unit),
          ('Drywall patch', 'Distance: 1.3 mi • Est: \$140', Icons.handyman),
        ].map((j) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: ListTile(
              leading: Icon(j.$3),
              title: Text(j.$1),
              subtitle: Text(j.$2),
              trailing: FilledButton.tonal(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Demo: Accepted "${j.$1}"')),
                ),
                child: const Text('Accept'),
              ),
            ),
          ),
        )),
      ],
    );
  }
}
