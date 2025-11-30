import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/complaint_card.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load(); // Reload data each time this screen comes to foreground
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated || auth.userId == null) {
      setState(() { _loading = false; _items = []; });
      return;
    }
    final items = await ApiService.getUserComplaints(auth.userId!, token: auth.token);
    setState(() { _items = items; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      body: _loading 
        ? const Center(child: CircularProgressIndicator()) 
        : _items.isEmpty 
          ? const Center(child: Text('No complaints')) 
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                return ComplaintCard(
                  // FIX: Use department or category from API
                  category: item['department'] ?? item['category'] ?? 'Issue',
                  status: item['status'] ?? 'Reported',
                  // FIX: Pass image path
                  imagePath: item['imagePath'] ?? item['image_url'], 
                  date: item['created_at'] ?? '',
                );
              },
            ),
    );
  }
}