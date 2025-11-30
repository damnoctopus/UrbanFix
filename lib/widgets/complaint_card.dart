import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import is needed for baseUrl

class ComplaintCard extends StatelessWidget {
  final String category;
  final String status;
  final String date;
  final String? imagePath; // FIX: 1. Add this field

  const ComplaintCard({
    super.key,
    required this.category,
    required this.status,
    required this.date,
    this.imagePath, // FIX: 2. Add this parameter to the constructor
  });

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
    // Logic to build the correct image URL
    String? fullImageUrl;
    if (imagePath != null && imagePath!.isNotEmpty) {
      // 1. Extract just the filename (removes C:\Users... etc)
      final filename = imagePath!.split(RegExp(r'[/\\]')).last;
      
      // 2. Remove the '/api' suffix from your baseUrl so we can point to /uploads
      final base = baseUrl.replaceAll('/api', ''); 
      
      // 3. Construct the final URL (e.g., http://10.0.2.2:8000/uploads/image.jpg)
      fullImageUrl = '$base/uploads/$filename';
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
          ),
          // FIX: 3. Display the image if available, otherwise show the icon
          child: fullImageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    fullImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
              : const Icon(Icons.image, size: 36, color: Colors.black26),
        ),
        title: Text(category, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date.split('T')[0]),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor(status),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}