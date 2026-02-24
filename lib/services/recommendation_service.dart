import '../models/memory_event.dart';
import '../models/recommendation.dart';

class RecommendationService {
  List<Recommendation> rank(
    List<MemoryEvent> events, {
    required bool isOffline,
    required bool recommendLocalOnly,
  }) {
    final DateTime now = DateTime.now();
    final List<Recommendation> scored = <Recommendation>[];

    for (final MemoryEvent event in events) {
      if (event.availability == AssetAvailability.missing) {
        continue;
      }

      int score = 0;
      final List<String> reasons = <String>[];

      if (!event.hasNote && event.photoCount >= 10) {
        score += 45;
        reasons.add('这段事件照片较多，还没有写下回忆。');
      }

      final bool isAnniversary =
          event.startAt.month == now.month && event.startAt.day == now.day;
      if (isAnniversary) {
        score += 55;
        reasons.add('这一天在往年也发生过，值得重温。');
      }

      if (event.isFavorite) {
        score += 20;
        reasons.add('你已经将它标记为收藏事件。');
      }

      if (event.availability == AssetAvailability.cloudOnly) {
        score -= 20;
        reasons.add('部分照片可能需要联网后才能加载。');
      }

      if (isOffline && event.availability == AssetAvailability.cloudOnly) {
        score -= 60;
      }

      if (recommendLocalOnly && event.availability != AssetAvailability.local) {
        continue;
      }

      if (score > 0) {
        scored.add(
          Recommendation(
            eventId: event.id,
            score: score,
            reason: reasons.join(' '),
          ),
        );
      }
    }

    scored.sort((Recommendation a, Recommendation b) => b.score - a.score);
    return scored.take(3).toList();
  }
}
