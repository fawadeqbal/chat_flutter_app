import 'dart:convert';
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
    
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
    }

    if (_token != null) {
      try {
        final response = await _apiClient.dio.get('/users/me');
        _user = UserModel.fromJson(response.data);
        await prefs.setString('user_data', jsonEncode(_user!.toJson()));
      } catch (e) {
        print('Session restore failed: $e');
        if (e.toString().contains('401')) {
          _token = null;
          _user = null;
          await prefs.remove('jwt_token');
          await prefs.remove('user_data');
        }
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
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));
      
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
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));

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
    await prefs.remove('user_data');
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.updateProfile(data);
      _user = UserModel.fromJson(response.data);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));
      
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
