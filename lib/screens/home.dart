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
        Navigator.pushNamed(context, '/report').then((_) {
          // Reset to home after reporting
          setState(() => _selectedIndex = 0);
        });
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTap,
        backgroundColor: Colors.white,
        elevation: 3,
        // FIX: Replaced invalid icons and ensured all are standard constants
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'My Lists'),
          NavigationDestination(icon: Icon(Icons.add_a_photo_outlined), label: 'Report'), // Note: If add_a_photo_outlined is missing in your SDK, use add_a_photo
          NavigationDestination(icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
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
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/report');
          _refresh();
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        // FIX: Changed Icons.add_camera (invalid) to Icons.add_a_photo (valid)
        icon: const Icon(Icons.add_a_photo), 
        label: const Text('Report Issue'),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('UrbanFix', style: TextStyle(fontWeight: FontWeight.w800)),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
        ],
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('No complaints yet', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _items.length,
                      itemBuilder: (_, i) {
                        final item = _items[i];
                        return ComplaintCard(
                          category: item['department'] ?? item['category'] ?? 'Issue',
                          status: item['status'] ?? 'Reported',
                          imagePath: item['imagePath'] ?? item['image_url'],
                          date: item['created_at'] ?? '',
                        );
                      },
                    ),
        ),
      ),
    );
  }
}