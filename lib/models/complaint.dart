class Complaint {
  final int id;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final int severity;
  final String? imageUrl;
  final String status;
  final DateTime createdAt;

  Complaint({required this.id, required this.category, required this.description, required this.latitude, required this.longitude, required this.severity, this.imageUrl, required this.status, required this.createdAt});

  factory Complaint.fromJson(Map<String, dynamic> json) => Complaint(
        id: json['id'] as int,
        category: json['category'] ?? '',
        description: json['description'] ?? '',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        severity: json['severity'] ?? 1,
        imageUrl: json['image'] ?? json['image_url'],
        status: json['status'] ?? 'Reported',
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );
}
