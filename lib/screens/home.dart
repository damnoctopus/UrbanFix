import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/complaint_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final _pages = const [
    _HomeView(),
    SizedBox.shrink(), // My Complaints (use route)
    SizedBox.shrink(),
    SizedBox.shrink(),
    SizedBox.shrink(),
  ];

  void _onTap(int idx) {
    setState(() => _selectedIndex = idx);
    switch (idx) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/my');
        break;
      case 2:
        Navigator.pushNamed(context, '/report');
        break;
      case 3:
        Navigator.pushNamed(context, '/notifications');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UrbanFix')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF3F8CFF),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My Complaints'),
          BottomNavigationBarItem(icon: Icon(Icons.add_a_photo), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _refresh() async {
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/report');
              _refresh(); // Reload after reporting new issue
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F8CFF), foregroundColor: Colors.white),
            child: const Padding(padding: EdgeInsets.symmetric(vertical: 14.0), child: Text('Report Issue')),
          ),
          const SizedBox(height: 12),
          const Text('Recent complaints', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
              ? const Center(child: Text('No complaints yet'))
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (_, i) => ComplaintCard(
                      category: _items[i]['category'] ?? 'Issue',
                      status: _items[i]['status'] ?? 'Reported',
                      date: _items[i]['created_at'] ?? '',
                    ),
                  ),
                ),
          )
        ],
      ),
    );
  }
}
