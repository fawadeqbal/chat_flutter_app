import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/socket/socket_service.dart';
import '../core/notifications/notification_service.dart';
import '../models/room_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final SocketService _socketService;
  final NotificationService _notificationService = NotificationService();
  
  List<RoomModel> _rooms = [];
  Map<String, List<MessageModel>> _messagesByRoom = {};
  List<UserModel>? _searchResults;
  String? _activeRoomId;
  String? _currentUserId;
  bool _isLoading = false;
  
  Set<String> _onlineUserIds = {};
  Set<String> _typingRoomIds = {};
  final Set<String> _seenMessageIds = {};
  bool _initialized = false;

  ChatProvider(this._socketService);

  List<RoomModel> get rooms => _rooms;
  List<MessageModel> get currentRoomMessages => _messagesByRoom[_activeRoomId] ?? [];
  List<UserModel> get searchResults => _searchResults ?? [];
  bool get isLoading => _isLoading;
  String? get activeRoomId => _activeRoomId;
  String? get currentUserId => _currentUserId;
  Set<String> get onlineUserIds => _onlineUserIds;
  bool isTyping(String roomId) => _typingRoomIds.contains(roomId);

  void init(String token, String userId) {
    if (_initialized) {
      _socketService.reconnect();
      return;
    }
    _initialized = true;
    _currentUserId = userId;
    _socketService.connect(token);
    _notificationService.init();
    _loadCachedRooms(); // Load local data first
    _listenToEvents();
    fetchRooms(); // Then fetch fresh data
  }

  Future<void> _loadCachedRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? roomsJson = prefs.getString('cached_rooms');
      if (roomsJson != null) {
        final List<dynamic> list = jsonDecode(roomsJson);
        _rooms = list.map((r) => RoomModel.fromJson(Map<String, dynamic>.from(r))).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cached rooms: $e');
    }
  }

  Future<void> _saveRoomsToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String roomsJson = jsonEncode(_rooms.map((r) => r.toJson()).toList());
      await prefs.setString('cached_rooms', roomsJson);
    } catch (e) {
      print('Error saving rooms to cache: $e');
    }
  }

  /// Refresh all data from the server (rooms + active room messages)
  Future<void> refreshFromServer() async {
    await fetchRooms();
    if (_activeRoomId != null) {
      await fetchMessages(_activeRoomId!);
    }
  }

  void _listenToEvents() {
    _socketService.messageStream.listen((data) {
      try {
        final message = MessageModel.fromJson(data);
        
        if (_seenMessageIds.contains(message.id)) return;
        _seenMessageIds.add(message.id);
        
        if (_messagesByRoom.containsKey(message.roomId)) {
          _messagesByRoom[message.roomId]!.insert(0, message);
        } else {
          _messagesByRoom[message.roomId] = [message];
        }
        
        final roomIndex = _rooms.indexWhere((r) => r.id == message.roomId);
        if (roomIndex != -1) {
          final room = _rooms.removeAt(roomIndex);
          final updatedRoom = room.copyWith(
            lastMessage: message,
            unreadCount: (message.senderId != _currentUserId && _activeRoomId != message.roomId)
                ? room.unreadCount + 1
                : room.unreadCount,
          );
          _rooms.insert(0, updatedRoom);
          _saveRoomsToCache();
        }
        
        // If message is for THIS user from SOMEONE ELSE, mark as DELIVERED
        if (message.senderId != _currentUserId) {
          _socketService.markAsReceived(message.id);
          
          if (_activeRoomId != message.roomId) {
            final senderName = data['sender']?['username']?.toString() ?? 'Someone';
            _notificationService.showMessageNotification(
              senderName: senderName,
              message: message.content,
              roomId: message.roomId,
            );
          }
        }

        notifyListeners();
      } catch (e, stack) {
        print('Error handling message sync: $e');
      }
    });

    _socketService.presenceStream.listen((data) {
      final String userId = data['userId']?.toString() ?? '';
      final String status = data['status']?.toString() ?? 'OFFLINE';
      
      if (status == 'ONLINE') {
        _onlineUserIds.add(userId);
      } else {
        _onlineUserIds.remove(userId);
      }
      notifyListeners();
    });

    _socketService.onlineListStream.listen((ids) {
      _onlineUserIds = Set<String>.from(ids);
      notifyListeners();
    });

    _socketService.typingStream.listen((data) {
      final String roomId = data['roomId']?.toString() ?? '';
      final bool isTyping = data['isTyping'] == true;
      
      if (isTyping) {
        _typingRoomIds.add(roomId);
      } else {
        _typingRoomIds.remove(roomId);
      }
      notifyListeners();
    });

    _socketService.statusUpdateStream.listen((data) {
      final String roomId = data['roomId']?.toString() ?? '';
      final String? messageId = data['messageId']?.toString();
      final String statusStr = data['status']?.toString() ?? '';
      
      final newStatus = _parseStatus(statusStr);
      final statusMap = {MessageStatus.SENT: 1, MessageStatus.DELIVERED: 2, MessageStatus.SEEN: 3};
      final DateTime? timestamp = data['timestamp'] != null
          ? DateTime.tryParse(data['timestamp'].toString())
          : DateTime.now();
      
      if (_messagesByRoom.containsKey(roomId)) {
        final messages = _messagesByRoom[roomId]!;
        bool changed = false;
        
        for (int i = 0; i < messages.length; i++) {
          final m = messages[i];
          if (statusMap[newStatus]! <= statusMap[m.status]!) continue;
          
          if (messageId != null && messageId.isNotEmpty && m.id == messageId) {
            messages[i] = m.copyWith(
              status: newStatus,
              deliveredAt: newStatus == MessageStatus.DELIVERED ? timestamp : null,
              seenAt: newStatus == MessageStatus.SEEN ? timestamp : null,
            );
            changed = true;
          } else if ((messageId == null || messageId.isEmpty) && m.senderId == _currentUserId) {
            messages[i] = m.copyWith(
              status: newStatus,
              deliveredAt: newStatus == MessageStatus.DELIVERED ? timestamp : m.deliveredAt,
              seenAt: newStatus == MessageStatus.SEEN ? timestamp : null,
            );
            changed = true;
          }
        }
        
        if (changed) {
          _saveRoomsToCache();
          notifyListeners();
        }
      }
    });

    _socketService.pinUpdateStream.listen((data) {
      final String roomId = data['roomId']?.toString() ?? '';
      final pinnedMsgData = data['pinnedMessage'];
      
      final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
      if (roomIndex != -1) {
        final room = _rooms[roomIndex];
        _rooms[roomIndex] = room.copyWith(
          pinnedMessageId: pinnedMsgData?['id']?.toString(),
          pinnedMessage: pinnedMsgData != null ? MessageModel.fromJson(pinnedMsgData) : null,
        );
        _saveRoomsToCache();
        notifyListeners();
      }
    });

    _socketService.reactionUpdateStream.listen((data) {
      final String roomId = data['roomId']?.toString() ?? '';
      final String messageId = data['messageId']?.toString() ?? '';
      final reactionsData = data['reactions'] as List;
      
      if (_messagesByRoom.containsKey(roomId)) {
        final messages = _messagesByRoom[roomId]!;
        final msgIndex = messages.indexWhere((m) => m.id == messageId);
        if (msgIndex != -1) {
          final reactions = reactionsData.map((r) => ReactionModel.fromJson(Map<String, dynamic>.from(r))).toList();
          messages[msgIndex] = messages[msgIndex].copyWith(reactions: reactions);
          notifyListeners();
        }
      }
    });

    // Handle Profile Updates
    _socketService.socialStream.listen((eventData) {
      if (eventData['event'] == 'profile_updated') {
        final data = eventData['data'];
        final String userId = data['userId'].toString();
        
        bool changed = false;
        for (int i = 0; i < _rooms.length; i++) {
          final members = _rooms[i].members;
          final memberIndex = members.indexWhere((m) => m.userId == userId);
          if (memberIndex != -1) {
            final existingUser = members[memberIndex].user;
            final updatedUser = UserModel(
              id: userId,
              username: data['username'] ?? existingUser.username,
              avatarUrl: data['avatarUrl'] ?? existingUser.avatarUrl,
              bio: data['bio'] ?? existingUser.bio,
              presence: existingUser.presence,
            );
            
            final updatedMembers = List<RoomMember>.from(members);
            updatedMembers[memberIndex] = RoomMember(userId: userId, user: updatedUser);
            _rooms[i] = _rooms[i].copyWith(members: updatedMembers);
            changed = true;
          }
        }
        
        if (changed) {
          _saveRoomsToCache();
          notifyListeners();
        }
      }
    });
  }

  MessageStatus _parseStatus(String status) {
    switch (status) {
      case 'DELIVERED':
        return MessageStatus.DELIVERED;
      case 'SEEN':
        return MessageStatus.SEEN;
      default:
        return MessageStatus.SENT;
    }
  }

  Future<void> fetchRooms() async {
    _isLoading = _rooms.isEmpty; // Only show loading if we have no cached data
    notifyListeners();
    try {
      final response = await _apiClient.getRooms();
      _rooms = (response.data as List).map((r) => RoomModel.fromJson(Map<String, dynamic>.from(r))).toList();
      _saveRoomsToCache();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching rooms: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setActiveRoom(String roomId) async {
    _activeRoomId = roomId;
    _socketService.setActiveRoom(roomId);
    _socketService.joinRoom(roomId);
    if (!_messagesByRoom.containsKey(roomId)) {
      await fetchMessages(roomId);
    }
    _socketService.markAsSeen(roomId);
    
    final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex != -1) {
      _rooms[roomIndex] = _rooms[roomIndex].copyWith(unreadCount: 0);
      _saveRoomsToCache();
    }
    
    notifyListeners();
  }

  Future<void> fetchMessages(String roomId) async {
    try {
      final response = await _apiClient.getMessages(roomId);
      final messages = (response.data as List)
          .map((m) => MessageModel.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      _messagesByRoom[roomId] = messages;
      notifyListeners();
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.searchUsers(query);
      if (response.data != null) {
        final List<dynamic> data = response.data as List;
        _searchResults = data.map((u) => UserModel.fromJson(Map<String, dynamic>.from(u)))
            .where((u) => u.id != (_currentUserId ?? '')).toList();
      } else {
        _searchResults = [];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Search error: $e');
      _searchResults = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> startPrivateChat(String targetUserId) async {
    try {
      final response = await _apiClient.createPrivateRoom(targetUserId);
      final room = RoomModel.fromJson(Map<String, dynamic>.from(response.data));
      if (!_rooms.any((r) => r.id == room.id)) {
        _rooms.insert(0, room);
        _saveRoomsToCache();
      }
      await setActiveRoom(room.id);
      return room.id;
    } catch (e) {
      print('Error starting chat: $e');
      return null;
    }
  }

  void sendTypingEvent(bool typing) {
    if (_activeRoomId != null) {
      _socketService.sendTyping(_activeRoomId!, typing);
    }
  }

  void markRoomAsSeen() {
    if (_activeRoomId != null) {
      _socketService.markAsSeen(_activeRoomId!);
    }
  }

  void sendMessage(String content) {
    if (_activeRoomId != null) {
      _socketService.sendMessage(_activeRoomId!, content);
    }
  }

  void pinMessage(String messageId) {
    if (_activeRoomId != null) {
      _socketService.pinMessage(_activeRoomId!, messageId);
    }
  }

  void unpinMessage() {
    if (_activeRoomId != null) {
      _socketService.unpinMessage(_activeRoomId!);
    }
  }

  void reactToMessage(String messageId, String emoji) {
    if (_activeRoomId != null) {
      _socketService.reactToMessage(_activeRoomId!, messageId, emoji);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
