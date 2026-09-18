import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = true;

  AppUser? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;

  Future<void> init() async {
    await ApiService.loadToken();
    if (ApiService.isLoggedIn) {
      try {
        final data = await ApiService.get('/auth/me');
        _user = AppUser.fromJson(data);
      } catch (_) {
        await ApiService.clearToken();
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await ApiService.post('/auth/login', {'email': email, 'password': password});
    await ApiService.saveToken(data['token']);
    _user = AppUser.fromJson(data['user']);
    notifyListeners();
  }

  Future<void> register(String name, String email, String password, String? phone) async {
    final data = await ApiService.post('/auth/register', {
      'name': name, 'email': email, 'password': password, 'phone': phone,
    });
    await ApiService.saveToken(data['token']);
    _user = AppUser.fromJson(data['user']);
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService.clearToken();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? phone, String? avatar}) async {
    final data = await ApiService.put('/users/me', {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (avatar != null) 'avatar': avatar,
    });
    _user = AppUser.fromJson(data);
    notifyListeners();
  }
}
