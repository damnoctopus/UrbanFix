class StatusUpdate {
  final String status;
  final DateTime timestamp;
  final String? note;

  StatusUpdate({required this.status, required this.timestamp, this.note});

  factory StatusUpdate.fromJson(Map<String, dynamic> json) => StatusUpdate(
        status: json['status'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        note: json['note'],
      );
}
