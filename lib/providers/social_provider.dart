import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/socket/socket_service.dart';
import '../models/user_model.dart';

enum SocialStatus { NONE, PENDING, ACCEPTED, DECLINED, BLOCKED }

class SocialProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final SocketService _socketService;
  
  List<Map<String, dynamic>> _pendingRequests = [];
  Map<String, SocialStatus> _friendshipStatuses = {};
  Set<String> _friendIds = {};
  List<UserModel> _friends = [];
  bool _isLoading = false;

  SocialProvider(this._socketService) {
    _listenToSocket();
    fetchFriends();
  }

  List<Map<String, dynamic>> get pendingRequests => _pendingRequests;
  Set<String> get friendIds => _friendIds;
  List<UserModel> get friends => _friends;
  bool get isLoading => _isLoading;

  void _listenToSocket() {
    _socketService.socialStream.listen((event) {
      final String type = event['event'];
      final dynamic data = event['data'];

      if (type == 'request:received') {
        fetchPendingRequests();
      } else if (type == 'request:accepted') {
        final String receiverId = data['receiverId'];
        _friendshipStatuses[receiverId] = SocialStatus.ACCEPTED;
        _friendIds.add(receiverId);
        fetchFriends(); // Refresh to get the user model
        notifyListeners();
      }
    });
  }

  Future<void> fetchPendingRequests() async {
    try {
      final response = await _apiClient.getPendingRequests();
      _pendingRequests = List<Map<String, dynamic>>.from(response.data);
      notifyListeners();
    } catch (e) {
      print('Error fetching pending requests: $e');
    }
  }

  Future<void> fetchFriends() async {
    try {
      final response = await _apiClient.getFriends();
      final List<dynamic> friendsData = response.data;
      _friends = friendsData.map((f) => UserModel.fromJson(f)).toList();
      _friendIds = _friends.map((f) => f.id).toSet();
      notifyListeners();
    } catch (e) {
      print('Error fetching friends: $e');
    }
  }

  Future<void> sendFriendRequest(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiClient.sendFriendRequest(userId);
      _friendshipStatuses[userId] = SocialStatus.PENDING;
    } catch (e) {
      print('Error sending friend request: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> respondToRequest(String requestId, String status, String senderId) async {
    try {
      await _apiClient.respondToFriendRequest(requestId, status);
      _pendingRequests.removeWhere((req) => req['id'] == requestId);
      if (status == 'ACCEPTED') {
        _friendshipStatuses[senderId] = SocialStatus.ACCEPTED;
        _friendIds.add(senderId);
      } else {
        _friendshipStatuses[senderId] = SocialStatus.NONE;
      }
      notifyListeners();
    } catch (e) {
      print('Error responding to request: $e');
    }
  }

  Future<SocialStatus> getFriendshipStatus(String userId) async {
    if (_friendIds.contains(userId)) {
      return SocialStatus.ACCEPTED;
    }
    if (_friendshipStatuses.containsKey(userId)) {
      return _friendshipStatuses[userId]!;
    }

    try {
      final response = await _apiClient.getFriendshipStatus(userId);
      if (response.data == null) {
        _friendshipStatuses[userId] = SocialStatus.NONE;
      } else {
        final statusStr = response.data['status'];
        final status = _parseStatus(statusStr);
        _friendshipStatuses[userId] = status;
        if (status == SocialStatus.ACCEPTED) {
          _friendIds.add(userId);
        }
      }
      return _friendshipStatuses[userId]!;
    } catch (e) {
      print('Error getting friendship status: $e');
      return SocialStatus.NONE;
    }
  }

  SocialStatus _parseStatus(String? status) {
    switch (status) {
      case 'PENDING':
        return SocialStatus.PENDING;
      case 'ACCEPTED':
        return SocialStatus.ACCEPTED;
      case 'DECLINED':
        return SocialStatus.DECLINED;
      case 'BLOCKED':
        return SocialStatus.BLOCKED;
      default:
        return SocialStatus.NONE;
    }
  }
  
  void clearLocalCache() {
    _friendshipStatuses.clear();
    _pendingRequests.clear();
    notifyListeners();
  }
}
