import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StatusTimelineScreen extends StatefulWidget {
  final int id;
  const StatusTimelineScreen({super.key, required this.id});

  @override
  State<StatusTimelineScreen> createState() => _StatusTimelineScreenState();
}

class _StatusTimelineScreenState extends State<StatusTimelineScreen> {
  List<dynamic> _timeline = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await ApiService.getComplaintStatus(widget.id);
    setState(() { _timeline = items; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Timeline')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: _timeline.length,
        itemBuilder: (_, i) {
          final it = _timeline[i] as Map<String, dynamic>;
          return ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(it['status'] ?? ''),
            subtitle: Text(it['timestamp'] ?? ''),
          );
        },
      ),
    );
  }
}
