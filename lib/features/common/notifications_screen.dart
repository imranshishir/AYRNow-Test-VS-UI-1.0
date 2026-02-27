import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _MockNotification {
  final IconData icon;
  final String title;
  final String subtitle;
  final String timeAgo;
  final String group;

  const _MockNotification({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.group,
  });
}

const _notifications = <_MockNotification>[
  _MockNotification(
    icon: Icons.payments_outlined,
    title: 'Rent Payment Reminder',
    subtitle: 'Your rent of \$1,650 is due in 2 days.',
    timeAgo: '1h ago',
    group: 'Today',
  ),
  _MockNotification(
    icon: Icons.build_outlined,
    title: 'Maintenance Update',
    subtitle: 'Ticket TCK-1007 "Leaking sink" status changed to Approved.',
    timeAgo: '3h ago',
    group: 'Today',
  ),
  _MockNotification(
    icon: Icons.forum_outlined,
    title: 'New Community Post',
    subtitle: 'John posted in "Building Announcements".',
    timeAgo: '5h ago',
    group: 'Today',
  ),
  _MockNotification(
    icon: Icons.check_circle_outlined,
    title: 'Approval Request',
    subtitle: 'Visitor access request for Unit 2B needs your approval.',
    timeAgo: '1d ago',
    group: 'Earlier',
  ),
  _MockNotification(
    icon: Icons.receipt_long_outlined,
    title: 'Receipt Available',
    subtitle: 'Your January rent receipt is ready to download.',
    timeAgo: '2d ago',
    group: 'Earlier',
  ),
  _MockNotification(
    icon: Icons.campaign_outlined,
    title: 'System Announcement',
    subtitle: 'Scheduled maintenance on Feb 28 from 2-4 AM.',
    timeAgo: '3d ago',
    group: 'Earlier',
  ),
];

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late List<_MockNotification> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(_notifications);
  }

  void _markAllRead() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = <String, List<_MockNotification>>{};
    for (final n in _items) {
      grouped.putIfAbsent(n.group, () => []).add(n);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('I-10 \u2022 Notifications'),
        actions: [
          IconButton(
            onPressed: _markAllRead,
            icon: const Icon(Icons.done_all_outlined),
            tooltip: 'Mark all read',
          ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Text('No notifications',
                  style: theme.textTheme.bodyLarge))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _countWithHeaders(grouped),
              itemBuilder: (context, index) {
                final entry = _entryAt(grouped, index);
                if (entry is String) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(entry,
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold)),
                  );
                }
                final n = entry as _MockNotification;
                return Dismissible(
                  key: ValueKey('${n.title}_${n.timeAgo}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: theme.colorScheme.error,
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() => _items.remove(n));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${n.title} dismissed')),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(n.icon, size: 20)),
                    title: Text(n.title),
                    subtitle: Text(n.subtitle),
                    trailing: Text(n.timeAgo,
                        style: theme.textTheme.bodySmall),
                  ),
                );
              },
            ),
    );
  }

  int _countWithHeaders(Map<String, List<_MockNotification>> grouped) {
    int count = 0;
    for (final entry in grouped.entries) {
      count += 1 + entry.value.length;
    }
    return count;
  }

  Object _entryAt(Map<String, List<_MockNotification>> grouped, int index) {
    int cursor = 0;
    for (final entry in grouped.entries) {
      if (index == cursor) return entry.key;
      cursor++;
      if (index < cursor + entry.value.length) {
        return entry.value[index - cursor];
      }
      cursor += entry.value.length;
    }
    return '';
  }
}
