import 'package:flutter/material.dart';
import 'package:ayrnow/features/contractor/screens/c_jobs.dart';
import 'package:ayrnow/features/contractor/screens/c_schedule.dart';
import 'package:ayrnow/features/contractor/screens/c_messages.dart';
import 'package:ayrnow/features/contractor/screens/c_profile.dart';

class ContractorHome extends StatefulWidget {
  const ContractorHome({super.key});

  @override
  State<ContractorHome> createState() => _ContractorHomeState();
}

class _ContractorHomeState extends State<ContractorHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      ContractorJobsScreen(),
      ContractorScheduleScreen(),
      ContractorMessagesScreen(),
      ContractorProfileScreen(),
    ];

    return SafeArea(
      child: Column(
        children: [
          Expanded(child: pages[_index]),
          const Divider(height: 1),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
              NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Schedule'),
              NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Messages'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ],
      ),
    );
  }
}
