import 'package:flutter/material.dart';

import '../models/memory_event.dart';
import '../models/recommendation.dart';

class RecommendationBanner extends StatelessWidget {
  const RecommendationBanner({
    super.key,
    required this.recommendation,
    required this.event,
    required this.onTap,
  });

  final Recommendation recommendation;
  final MemoryEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF1D3557), Color(0xFF457B9D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '今日回忆提示',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            event.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            recommendation.reason,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1D3557),
            ),
            child: const Text('打开并写下回忆'),
          ),
        ],
      ),
    );
  }
}
