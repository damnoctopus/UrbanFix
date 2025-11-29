import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'mock_api_service.dart';

// Configure your backend base URL here. For local development:
// - Android emulator: use 10.0.2.2 (maps to host localhost)
// - iOS simulator / web / desktop: use localhost
// Update the port below to match your local server port (e.g. 8000).
final String baseUrl = _determineBaseUrl();

String _determineBaseUrl() {
  const int port = 8000; // change this to your local server port
  if (kIsWeb) return 'http://localhost:$port';
  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:$port';
  } catch (_) {}
  return 'http://localhost:$port';
}

// Disable mock by default so app connects to local server.
// Set to true if you want to use the built-in mock service instead.
final bool _useMock = false;

class ApiService {
  // Authentication
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    if (_useMock) return MockApiService.login(email, password);
    try {
      final res = await http.post(Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password})).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  static Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    if (_useMock) return MockApiService.register(name, email, password);
    try {
      final res = await http.post(Uri.parse('$baseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name, 'email': email, 'password': password})).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  // Meta
  static Future<List<dynamic>> getCategories({String? token}) async {
    if (_useMock) return MockApiService.getCategories();
    try {
      final res = await http.get(Uri.parse('$baseUrl/meta/categories'), headers: _auth(token)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  // Complaints
  static Future<Map<String, dynamic>?> postComplaint({required String token, required Map<String, String> fields, File? image}) async {
    if (_useMock) return MockApiService.postComplaint(fields: fields);
    try {
      final uri = Uri.parse('$baseUrl/complaints');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({'Authorization': 'Bearer $token'});
      fields.forEach((k, v) => request.fields[k] = v);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  static Future<List<dynamic>> getUserComplaints(int userId, {String? token}) async {
    if (_useMock) return MockApiService.getUserComplaints(userId);
    try {
      final res = await http.get(Uri.parse('$baseUrl/complaints/user/$userId'), headers: _auth(token)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getComplaint(int id, {String? token}) async {
    if (_useMock) return MockApiService.getComplaint(id);
    try {
      final res = await http.get(Uri.parse('$baseUrl/complaints/$id'), headers: _auth(token)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {}
    return null;
  }

  static Future<List<dynamic>> getComplaintStatus(int id, {String? token}) async {
    if (_useMock) return MockApiService.getComplaintStatus(id);
    try {
      final res = await http.get(Uri.parse('$baseUrl/complaints/$id/status'), headers: _auth(token)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {}
    return [];
  }

  static Future<bool> postFeedback(int id, Map<String, dynamic> payload, {String? token}) async {
    if (_useMock) return MockApiService.postFeedback(id, payload);
    try {
      final res = await http.post(Uri.parse('$baseUrl/complaints/$id/feedback'), headers: _auth(token)..addAll({'Content-Type':'application/json'}), body: jsonEncode(payload)).timeout(const Duration(seconds: 15));
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {}
    return false;
  }

  // Notifications (optional)
  static Future<List<dynamic>> getNotifications(int userId, {String? token}) async {
    if (_useMock) return MockApiService.getNotifications(userId);
    try {
      final res = await http.get(Uri.parse('$baseUrl/notifications/$userId'), headers: _auth(token)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    } catch (e) {}
    return [];
  }

  static Map<String, String> _auth(String? token) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }
}
