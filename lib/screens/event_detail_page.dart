import 'package:flutter/material.dart';

import '../controllers/alive_controller.dart';
import '../models/memory_event.dart';
import '../utils/formatters.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({
    super.key,
    required this.controller,
    required this.event,
  });

  final AliveController controller;
  final MemoryEvent event;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _noteController = TextEditingController(text: widget.event.note);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MemoryEvent current = widget.controller.eventById(widget.event.id) ?? widget.event;

    return Scaffold(
      appBar: AppBar(
        title: const Text('事件详情'),
        actions: <Widget>[
          IconButton(
            onPressed: _isSaving ? null : _save,
            icon: const Icon(Icons.check),
            tooltip: '保存',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _StatusBanner(
            availability: current.availability,
            isOffline: widget.controller.isOffline,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '事件标题',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${formatDateRange(current.startAt, current.endAt)} · ${current.locationName}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            '本事件共 ${current.photoCount} 张照片',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 8,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: '游记 / 日记',
              alignLabelWithHint: true,
              hintText: '记录你想记住的片刻、心情和细节。',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('收藏这个事件'),
            value: current.isFavorite,
            onChanged: (bool value) async {
              await widget.controller.updateEvent(current.id, isFavorite: value);
              if (mounted) {
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });
    await widget.controller.updateEvent(
      widget.event.id,
      title: _titleController.text.trim(),
      note: _noteController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _isSaving = false;
    });
    Navigator.of(context).pop();
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.availability,
    required this.isOffline,
  });

  final AssetAvailability availability;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color color;

    switch (availability) {
      case AssetAvailability.local:
        text = '所有照片都可在当前设备查看。';
        color = Colors.green;
      case AssetAvailability.cloudOnly:
        text = isOffline
            ? '照片来自云相册，当前离线状态下暂不可查看。'
            : '照片来自云相册，可能按需加载。';
        color = Colors.orange;
      case AssetAvailability.missing:
        text = '原始照片已缺失，但你仍可编辑这段回忆文字。';
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: color)),
    );
  }
}
