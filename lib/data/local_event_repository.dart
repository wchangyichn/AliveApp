import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/memory_event.dart';

class LocalEventRepository {
  LocalEventRepository(this._preferences);

  final SharedPreferences _preferences;

  static const String _eventsKey = 'alive.events';
  static const String _simulateOfflineKey = 'alive.simulateOffline';
  static const String _recommendLocalOnlyKey = 'alive.recommendLocalOnly';

  Future<List<MemoryEvent>> loadEvents() async {
    final String? raw = _preferences.getString(_eventsKey);
    if (raw == null) {
      final List<MemoryEvent> seeded = _seedData();
      await saveEvents(seeded);
      return seeded;
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((dynamic item) => MemoryEvent.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveEvents(List<MemoryEvent> events) async {
    final String encoded = jsonEncode(
      events.map((MemoryEvent event) => event.toJson()).toList(),
    );
    await _preferences.setString(_eventsKey, encoded);
  }

  bool loadSimulateOffline() => _preferences.getBool(_simulateOfflineKey) ?? false;

  Future<void> saveSimulateOffline(bool value) async {
    await _preferences.setBool(_simulateOfflineKey, value);
  }

  bool loadRecommendLocalOnly() =>
      _preferences.getBool(_recommendLocalOnlyKey) ?? true;

  Future<void> saveRecommendLocalOnly(bool value) async {
    await _preferences.setBool(_recommendLocalOnlyKey, value);
  }

  List<MemoryEvent> _seedData() {
    final DateTime now = DateTime.now();
    return <MemoryEvent>[
      MemoryEvent(
        id: 'e01',
        title: '西湖周末漫步',
        startAt: DateTime(now.year, now.month, now.day - 5, 10),
        endAt: DateTime(now.year, now.month, now.day - 5, 19),
        locationName: '杭州',
        photoCount: 43,
        availability: AssetAvailability.local,
      ),
      MemoryEvent(
        id: 'e02',
        title: '深夜江边散步',
        startAt: DateTime(now.year, now.month, now.day - 2, 21),
        endAt: DateTime(now.year, now.month, now.day - 2, 23),
        locationName: '上海外滩',
        photoCount: 12,
        availability: AssetAvailability.cloudOnly,
      ),
      MemoryEvent(
        id: 'e03',
        title: '家人晚餐时光',
        startAt: DateTime(now.year - 1, now.month, now.day, 18),
        endAt: DateTime(now.year - 1, now.month, now.day, 21),
        locationName: '南京',
        photoCount: 26,
        availability: AssetAvailability.local,
        isFavorite: true,
        note: '原本只是普通晚餐，最后变成了很久很暖的一次聊天。',
      ),
      MemoryEvent(
        id: 'e04',
        title: '重返旧校园',
        startAt: DateTime(now.year - 2, 4, 11, 9),
        endAt: DateTime(now.year - 2, 4, 11, 16),
        locationName: '武汉',
        photoCount: 31,
        availability: AssetAvailability.missing,
      ),
    ];
  }
}
