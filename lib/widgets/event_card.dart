import 'package:flutter/material.dart';

import '../models/memory_event.dart';
import '../utils/formatters.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  final MemoryEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(14),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(formatDateRange(event.startAt, event.endAt)),
              const SizedBox(height: 4),
              Text('${event.locationName} · ${event.photoCount} 张照片'),
              const SizedBox(height: 4),
              _AvailabilityChip(availability: event.availability),
            ],
          ),
        ),
        trailing: Icon(
          event.isFavorite ? Icons.favorite : Icons.chevron_right,
          color: event.isFavorite ? Colors.redAccent : null,
        ),
      ),
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({required this.availability});

  final AssetAvailability availability;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;

    switch (availability) {
      case AssetAvailability.local:
        label = '可离线查看';
        color = Colors.green;
      case AssetAvailability.cloudOnly:
        label = '云端照片来源';
        color = Colors.orange;
      case AssetAvailability.missing:
        label = '照片已缺失';
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color)),
    );
  }
}
