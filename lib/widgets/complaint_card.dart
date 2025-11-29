import 'package:flutter/material.dart';

class ComplaintCard extends StatelessWidget {
  final String category;
  final String status;
  final String date;

  const ComplaintCard({super.key, required this.category, required this.status, required this.date});

  factory ComplaintCard.sample(int i) {
    final statuses = ['Reported', 'Verified', 'Assigned', 'In Progress', 'Completed'];
    return ComplaintCard(category: 'Pothole', status: statuses[i % statuses.length], date: '2025-11-2${i}');
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Reported': return Colors.grey;
      case 'Verified': return const Color(0xFF3F8CFF);
      case 'Assigned': return Colors.yellow.shade700;
      case 'In Progress': return Colors.orange;
      case 'Completed': return Colors.green;
      case 'Closed': return Colors.black;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Container(width: 72, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade200), child: const Icon(Icons.image, size: 36, color: Colors.black26)),
        title: Text(category, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date),
        trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: _statusColor(status), borderRadius: BorderRadius.circular(6)), child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12))),
      ),
    );
  }
}
