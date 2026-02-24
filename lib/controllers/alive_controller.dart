import 'package:flutter/foundation.dart';

import '../data/local_event_repository.dart';
import '../models/memory_event.dart';
import '../models/recommendation.dart';
import '../services/recommendation_service.dart';

class AliveController extends ChangeNotifier {
  AliveController(this._repository, this._recommendationService);

  final LocalEventRepository _repository;
  final RecommendationService _recommendationService;

  bool _isInitialized = false;
  bool _isOffline = false;
  bool _recommendLocalOnly = true;
  List<MemoryEvent> _events = <MemoryEvent>[];
  List<Recommendation> _recommendations = <Recommendation>[];

  bool get isInitialized => _isInitialized;
  bool get isOffline => _isOffline;
  bool get recommendLocalOnly => _recommendLocalOnly;
  List<MemoryEvent> get events => _events;
  List<Recommendation> get recommendations => _recommendations;

  Future<void> initialize() async {
    _events = await _repository.loadEvents();
    _isOffline = _repository.loadSimulateOffline();
    _recommendLocalOnly = _repository.loadRecommendLocalOnly();
    _refreshRecommendations();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> updateEvent(
    String eventId, {
    String? title,
    String? note,
    bool? isFavorite,
  }) async {
    _events = _events.map((MemoryEvent event) {
      if (event.id != eventId) {
        return event;
      }

      return event.copyWith(
        title: title,
        note: note,
        isFavorite: isFavorite,
        lastEditedAt: DateTime.now(),
      );
    }).toList();

    await _repository.saveEvents(_events);
    _refreshRecommendations();
    notifyListeners();
  }

  Future<void> setOffline(bool value) async {
    _isOffline = value;
    await _repository.saveSimulateOffline(value);
    _refreshRecommendations();
    notifyListeners();
  }

  Future<void> setRecommendLocalOnly(bool value) async {
    _recommendLocalOnly = value;
    await _repository.saveRecommendLocalOnly(value);
    _refreshRecommendations();
    notifyListeners();
  }

  MemoryEvent? eventById(String eventId) {
    for (final MemoryEvent event in _events) {
      if (event.id == eventId) {
        return event;
      }
    }
    return null;
  }

  void _refreshRecommendations() {
    _recommendations = _recommendationService.rank(
      _events,
      isOffline: _isOffline,
      recommendLocalOnly: _recommendLocalOnly,
    );
  }
}
