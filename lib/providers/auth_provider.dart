import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  int? userId;

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _autoLogin();
  }

  Future<void> _autoLogin() async {
    final t = await _storage.read(key: 'jwt_token');
    final uid = await _storage.read(key: 'user_id');
    if (t != null) {
      _token = t;
      userId = uid != null ? int.tryParse(uid) : null;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    final res = await ApiService.login(email, password);
    if (res != null && res['token'] != null) {
      _token = res['token'];
      userId = res['user_id'] != null ? res['user_id'] as int : null;
      await _storage.write(key: 'jwt_token', value: _token);
      if (userId != null) {
        await _storage.write(key: 'user_id', value: userId.toString());
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    final res = await ApiService.register(name, email, password);
    if (res != null && res['token'] != null) {
      _token = res['token'];
      userId = res['user_id'] != null ? res['user_id'] as int : null;
      await _storage.write(key: 'jwt_token', value: _token);
      if (userId != null) {
        await _storage.write(key: 'user_id', value: userId.toString());
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    userId = null;
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_id');
    notifyListeners();
  }
}
