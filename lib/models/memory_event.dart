enum AssetAvailability { local, cloudOnly, missing }

class MemoryEvent {
  MemoryEvent({
    required this.id,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.locationName,
    required this.photoCount,
    required this.availability,
    this.note = '',
    this.isFavorite = false,
    this.lastEditedAt,
  });

  final String id;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String locationName;
  final int photoCount;
  final AssetAvailability availability;
  final String note;
  final bool isFavorite;
  final DateTime? lastEditedAt;

  bool get hasNote => note.trim().isNotEmpty;

  MemoryEvent copyWith({
    String? title,
    DateTime? startAt,
    DateTime? endAt,
    String? locationName,
    int? photoCount,
    AssetAvailability? availability,
    String? note,
    bool? isFavorite,
    DateTime? lastEditedAt,
  }) {
    return MemoryEvent(
      id: id,
      title: title ?? this.title,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      locationName: locationName ?? this.locationName,
      photoCount: photoCount ?? this.photoCount,
      availability: availability ?? this.availability,
      note: note ?? this.note,
      isFavorite: isFavorite ?? this.isFavorite,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'locationName': locationName,
      'photoCount': photoCount,
      'availability': availability.name,
      'note': note,
      'isFavorite': isFavorite,
      'lastEditedAt': lastEditedAt?.toIso8601String(),
    };
  }

  factory MemoryEvent.fromJson(Map<String, dynamic> json) {
    return MemoryEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      locationName: json['locationName'] as String,
      photoCount: json['photoCount'] as int,
      availability: AssetAvailability.values.byName(json['availability'] as String),
      note: (json['note'] as String?) ?? '',
      isFavorite: (json['isFavorite'] as bool?) ?? false,
      lastEditedAt: json['lastEditedAt'] != null
          ? DateTime.parse(json['lastEditedAt'] as String)
          : null,
    );
  }
}
