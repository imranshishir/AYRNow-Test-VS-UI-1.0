import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final String emptyMessage;

  const AsyncValueView({
    super.key,
    required this.value,
    required this.builder,
    this.emptyMessage = 'No data yet.',
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 10),
              Text('Error: $e', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              )
            ],
          ),
        ),
      ),
      data: (data) {
        if (data is Iterable && data.isEmpty) {
          return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(emptyMessage)));
        }
        return builder(data);
      },
    );
  }
}
