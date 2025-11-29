import 'dart:async';

class MockApiService {
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (email.contains('@')) {
      return {'token': 'mock_jwt_token', 'user_id': 1, 'name': 'Test User'};
    }
    return null;
  }

  static Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {'token': 'mock_jwt_token', 'user_id': 2, 'name': name};
  }

  static Future<List<dynamic>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      {'id': 1, 'name': 'Pothole'},
      {'id': 2, 'name': 'Broken streetlight'},
      {'id': 3, 'name': 'Garbage'},
      {'id': 4, 'name': 'Drainage'},
    ];
  }

  static Future<Map<String, dynamic>?> postComplaint({required Map<String, String> fields}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {'id': 123, 'status': 'Reported', 'created_at': DateTime.now().toIso8601String()};
  }

  static Future<List<dynamic>> getUserComplaints(int userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {'id': 1, 'category': 'Pothole', 'status': 'Reported', 'created_at': DateTime.now().toIso8601String(), 'image': null},
      {'id': 2, 'category': 'Garbage', 'status': 'In Progress', 'created_at': DateTime.now().toIso8601String(), 'image': null},
    ];
  }

  static Future<Map<String, dynamic>?> getComplaint(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {'id': id, 'category': 'Pothole', 'description': 'Mock description', 'latitude': 12.34, 'longitude': 56.78, 'severity': 3, 'status': 'Reported', 'image': null, 'created_at': DateTime.now().toIso8601String()};
  }

  static Future<List<dynamic>> getComplaintStatus(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'status': 'Reported', 'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String()},
      {'status': 'Verified', 'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()},
    ];
  }

  static Future<bool> postFeedback(int id, Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  static Future<List<dynamic>> getNotifications(int userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'title': 'Status updated', 'body': 'Your complaint #1 is now In Progress'},
      {'title': 'New assignment', 'body': 'A department was assigned to complaint #2'},
    ];
  }
}
