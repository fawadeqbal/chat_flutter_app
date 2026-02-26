import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart'; // Added for kIsWeb

class ApiClient {
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://1bba-203-215-178-220.ngrok-free.app';
    } else {
      return 'https://1bba-203-215-178-220.ngrok-free.app';
    }
  }
  late Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Bypass ngrok browser warning
        options.headers['ngrok-skip-browser-warning'] = 'true';
        
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          // Handle token expiry (e.g., redirect to login)
        }
        return handler.next(e);
      },
    ));
  }

  // Auth Endpoints
  Future<Response> login(String email, String password) async {
    try {
      return await dio.post('/auth/login', data: {'email': email, 'password': password});
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<Response> register(String email, String password, String username) async {
    return dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'username': username,
    });
  }

  // Chat Endpoints
  Future<Response> getRooms() async {
    return dio.get('/chat/rooms');
  }

  Future<Response> getMessages(String roomId, {int limit = 50, int skip = 0}) async {
    return dio.get('/chat/rooms/$roomId/messages', queryParameters: {
      'limit': limit,
      'skip': skip,
    });
  }

  Future<Response> searchUsers(String username) async {
    return dio.get('/users/search/$username');
  }

  Future<Response> getFriends() async {
    return dio.get('/friends/list');
  }

  Future<Response> createPrivateRoom(String targetUserId) async {
    return dio.post('/chat/rooms/private', data: {'targetUserId': targetUserId});
  }

  // Friend Endpoints
  Future<Response> sendFriendRequest(String userId) async {
    return dio.post('/friends/request/$userId');
  }

  Future<Response> getPendingRequests() async {
    return dio.get('/friends/pending');
  }

  Future<Response> respondToFriendRequest(String requestId, String status) async {
    return dio.patch('/friends/respond/$requestId', data: {'status': status});
  }

  Future<Response> getFriendshipStatus(String userId) async {
    return dio.get('/friends/status/$userId');
  }

  // User & Profile Endpoints
  Future<Response> getMe() async {
    return dio.get('/users/me');
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return dio.patch('/users/profile', data: data);
  }

  Future<Response> uploadFile(String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    return dio.post('/upload', data: formData);
  }

  Future<Response> uploadFileFromBytes(Uint8List bytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    return dio.post('/upload', data: formData);
  }
}
