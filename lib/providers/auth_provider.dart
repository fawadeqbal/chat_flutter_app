import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  String get baseUrl => ApiClient.baseUrl;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    if (_token != null) {
      try {
        final response = await _apiClient.dio.get('/users/me');
        _user = UserModel.fromJson(response.data);
      } catch (e) {
        print('Session restore failed: $e');
        // Token likely expired — clear it
        _token = null;
        await prefs.remove('jwt_token');
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.login(email, password);
      _token = response.data['access_token'];
      _user = UserModel.fromJson(response.data['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', _token!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String username) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.register(email, password, username);
      _token = response.data['access_token'];
      _user = UserModel.fromJson(response.data['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.updateProfile(data);
      _user = UserModel.fromJson(response.data);
      notifyListeners();
      return true;
    } catch (e) {
      print('Profile update failed: $e');
      return false;
    }
  }

  Future<String?> uploadAvatar(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final response = await _apiClient.uploadFileFromBytes(bytes, file.name);
      final avatarUrl = response.data['url'];
      // After upload, update profile with new avatarUrl
      await updateProfile({'avatarUrl': avatarUrl});
      return avatarUrl;
    } catch (e) {
      print('Avatar upload failed: $e');
      return null;
    }
  }
}
