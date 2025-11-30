// dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'mock_api_service.dart';

// Aligns with the Spring Boot API structure
const String baseUrl = 'http://15.207.115.58:8000/api';

// Disable mock by default so app connects to real server.
final bool _useMock = false;

class ApiService {
  // Authentication
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    if (_useMock) return MockApiService.login(email, password);
    try {
      final res = await http
          .post(Uri.parse('$baseUrl/auth/login'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': email, 'password': password}))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // ignore or log
    }
    return null;
  }

  static Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    if (_useMock) return MockApiService.register(name, email, password);
    try {
      final res = await http
          .post(Uri.parse('$baseUrl/auth/register'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'name': name, 'email': email, 'password': password}))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // ignore or log
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
      // ignore or log
    }
    return [];
  }

  // Complaints
  static Future<Map<String, dynamic>?> postComplaint({required String token, required Map<String, String> fields, File? image}) async {
    if (_useMock) return MockApiService.postComplaint(fields: fields);
    try {
      final uri = Uri.parse('$baseUrl/complaints');
      final request = http.MultipartRequest('POST', uri);
      // include standard auth headers (Accept + Authorization)
      request.headers.addAll(_auth(token));
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
      // ignore or log
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
      // ignore or log
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
    } catch (e) {
      // ignore or log
    }
    return null;
  }

  static Future<List<dynamic>> getComplaintStatus(int id, {String? token}) async {
    if (_useMock) return MockApiService.getComplaintStatus(id);
    try {
      final res = await http.get(Uri.parse('$baseUrl/complaints/$id/status'), headers: _auth(token)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {
      // ignore or log
    }
    return [];
  }

  static Future<bool> postFeedback(int id, Map<String, dynamic> payload, {String? token}) async {
    if (_useMock) return MockApiService.postFeedback(id, payload);
    try {
      final headers = _auth(token)..addAll({'Content-Type': 'application/json'});
      final res = await http.post(Uri.parse('$baseUrl/complaints/$id/feedback'), headers: headers, body: jsonEncode(payload)).timeout(const Duration(seconds: 15));
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      // ignore or log
    }
    return false;
  }

  // Notifications (optional)
  static Future<List<dynamic>> getNotifications(int userId, {String? token}) async {
    if (_useMock) return MockApiService.getNotifications(userId);
    try {
      final res = await http.get(Uri.parse('$baseUrl/notifications/$userId'), headers: _auth(token)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    } catch (e) {
      // ignore or log
    }
    return [];
  }

  static Map<String, String> _auth(String? token) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }
}
