class Recommendation {
  Recommendation({
    required this.eventId,
    required this.score,
    required this.reason,
  });

  final String eventId;
  final int score;
  final String reason;
}
