import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/alive_controller.dart';
import 'data/local_event_repository.dart';
import 'models/memory_event.dart';
import 'models/recommendation.dart';
import 'screens/event_detail_page.dart';
import 'services/recommendation_service.dart';
import 'utils/formatters.dart';
import 'widgets/event_card.dart';
import 'widgets/recommendation_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AliveController controller = AliveController(
    LocalEventRepository(prefs),
    RecommendationService(),
  );
  await controller.initialize();
  runApp(AliveApp(controller: controller));
}

class AliveApp extends StatelessWidget {
  const AliveApp({super.key, required this.controller});

  final AliveController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '回忆区',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF457B9D)),
            useMaterial3: true,
          ),
          home: HomeShell(controller: controller),
        );
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});

  final AliveController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      MemoriesPage(controller: widget.controller),
      FootprintPage(events: widget.controller.events),
      TimelinePage(events: widget.controller.events),
      FavoritesPage(controller: widget.controller),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('回忆区'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.auto_stories), label: '回忆'),
          NavigationDestination(icon: Icon(Icons.map), label: '足迹'),
          NavigationDestination(icon: Icon(Icons.timeline), label: '时间线'),
          NavigationDestination(icon: Icon(Icons.favorite), label: '收藏'),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SwitchListTile(
                title: const Text('模拟离线模式'),
                subtitle: const Text('用于验证云相册兼容状态。'),
                value: widget.controller.isOffline,
                onChanged: (bool value) {
                  widget.controller.setOffline(value);
                },
              ),
              SwitchListTile(
                title: const Text('仅推荐本地可查看事件'),
                subtitle: const Text('避免提示仅云端可访问的事件。'),
                value: widget.controller.recommendLocalOnly,
                onChanged: (bool value) {
                  widget.controller.setRecommendLocalOnly(value);
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Alive 本地优先：无需登录，不上传云端。',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MemoriesPage extends StatelessWidget {
  const MemoriesPage({super.key, required this.controller});

  final AliveController controller;

  @override
  Widget build(BuildContext context) {
    final List<MemoryEvent> events = List<MemoryEvent>.from(controller.events)
      ..sort((MemoryEvent a, MemoryEvent b) => b.startAt.compareTo(a.startAt));

    final Recommendation? topRecommendation =
        controller.recommendations.isEmpty ? null : controller.recommendations.first;

    final MemoryEvent? topEvent = topRecommendation == null
        ? null
        : controller.eventById(topRecommendation.eventId);

    return ListView(
      children: <Widget>[
        if (topRecommendation != null && topEvent != null)
          RecommendationBanner(
            recommendation: topRecommendation,
            event: topEvent,
            onTap: () => _openEvent(context, topEvent),
          ),
        for (final MemoryEvent event in events)
          EventCard(
            event: event,
            onTap: () => _openEvent(context, event),
          ),
      ],
    );
  }

  Future<void> _openEvent(BuildContext context, MemoryEvent event) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EventDetailPage(
          controller: controller,
          event: event,
        ),
      ),
    );
  }
}

class FootprintPage extends StatelessWidget {
  const FootprintPage({super.key, required this.events});

  final List<MemoryEvent> events;

  @override
  Widget build(BuildContext context) {
    final Map<String, int> byLocation = <String, int>{};
    for (final MemoryEvent event in events) {
      byLocation.update(event.locationName, (int count) => count + 1, ifAbsent: () => 1);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFE6EEF4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
              child: Text(
              '足迹地图占位\n（下一阶段接入地图 SDK）',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...byLocation.entries.map(
          (MapEntry<String, int> entry) => ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(entry.key),
            subtitle: Text('${entry.value} 个事件'),
          ),
        ),
      ],
    );
  }
}

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key, required this.events});

  final List<MemoryEvent> events;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<MemoryEvent>> grouped = <String, List<MemoryEvent>>{};
    for (final MemoryEvent event in events) {
      final String bucket = monthBucket(event.startAt);
      grouped.putIfAbsent(bucket, () => <MemoryEvent>[]).add(event);
    }

    final List<String> sortedKeys = grouped.keys.toList()
      ..sort((String a, String b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (BuildContext context, int index) {
        final String key = sortedKeys[index];
        final List<MemoryEvent> items = grouped[key]!;
        return ExpansionTile(
          title: Text(key),
          subtitle: Text('${items.length} 个事件'),
          children: items
              .map(
                (MemoryEvent event) => ListTile(
                  title: Text(event.title),
                  subtitle: Text(event.locationName),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key, required this.controller});

  final AliveController controller;

  @override
  Widget build(BuildContext context) {
    final List<MemoryEvent> favorites =
        controller.events.where((MemoryEvent event) => event.isFavorite).toList();

    if (favorites.isEmpty) {
      return const Center(
        child: Text('暂未收藏事件，给重要回忆点个爱心吧。'),
      );
    }

    return ListView(
      children: favorites
          .map(
            (MemoryEvent event) => EventCard(
              event: event,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        EventDetailPage(controller: controller, event: event),
                  ),
                );
              },
            ),
          )
          .toList(),
    );
  }
}
