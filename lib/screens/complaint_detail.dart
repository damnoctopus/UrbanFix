import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ComplaintDetailScreen extends StatefulWidget {
  static const routeName = '/complaint';
  final int? id;
  const ComplaintDetailScreen({super.key, this.id});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  Map<String, dynamic>? _complaint;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.id == null) return;
    final res = await ApiService.getComplaint(widget.id!);
    setState(() { _complaint = res; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _complaint==null ? const Center(child: Text('Not found')) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _complaint!['image'] != null ? Image.network(_complaint!['image']) : const SizedBox.shrink(),
          const SizedBox(height: 8),
          Text(_complaint!['category'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_complaint!['description'] ?? ''),
          const SizedBox(height: 12),
          Text('Status: ${_complaint!['status'] ?? 'Reported'}', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text('Location: ${_complaint!['latitude'] ?? ''}, ${_complaint!['longitude'] ?? ''}'),
        ]),
      ),
    );
  }
}
