import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../api/api_client.dart';

class SocketService {
  IO.Socket? _socket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _presenceController = StreamController<Map<String, dynamic>>.broadcast();
  final _onlineListController = StreamController<List<String>>.broadcast();

  // Call event stream controllers
  final _callIncomingController = StreamController<Map<String, dynamic>>.broadcast();
  final _callAcceptedController = StreamController<Map<String, dynamic>>.broadcast();
  final _callDeclinedController = StreamController<void>.broadcast();
  final _callEndedController = StreamController<void>.broadcast();
  final _callSignalController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _socialController = StreamController<Map<String, dynamic>>.broadcast();
  final _pinUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _reactionUpdateController = StreamController<Map<String, dynamic>>.broadcast();

  // Matchmaking event stream controllers
  final _matchFoundController = StreamController<Map<String, dynamic>>.broadcast();
  final _waitingForPartnerController = StreamController<Map<String, dynamic>>.broadcast();
  final _partnerSkippedController = StreamController<void>.broadcast();
  final _queueUpdateController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get presenceStream => _presenceController.stream;
  Stream<List<String>> get onlineListStream => _onlineListController.stream;
  Stream<Map<String, dynamic>> get statusUpdateStream => _statusUpdateController.stream;
  Stream<Map<String, dynamic>> get socialStream => _socialController.stream;
  Stream<Map<String, dynamic>> get pinUpdateStream => _pinUpdateController.stream;
  Stream<Map<String, dynamic>> get reactionUpdateStream => _reactionUpdateController.stream;

  // Matchmaking event streams
  Stream<Map<String, dynamic>> get matchFoundStream => _matchFoundController.stream;
  Stream<Map<String, dynamic>> get waitingForPartnerStream => _waitingForPartnerController.stream;
  Stream<void> get partnerSkippedStream => _partnerSkippedController.stream;
  Stream<Map<String, dynamic>> get queueUpdateStream => _queueUpdateController.stream;

  IO.Socket? get socket => _socket;

  // Call event streams
  Stream<Map<String, dynamic>> get callIncomingStream => _callIncomingController.stream;
  Stream<Map<String, dynamic>> get callAcceptedStream => _callAcceptedController.stream;
  Stream<void> get callDeclinedStream => _callDeclinedController.stream;
  Stream<void> get callEndedStream => _callEndedController.stream;
  Stream<Map<String, dynamic>> get callSignalStream => _callSignalController.stream;

  String? _token;
  String? _activeRoomId;

  void connect(String token) {
    _token = token;
    _socket?.disconnect();

    final s = IO.io(ApiClient.baseUrl, 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'ngrok-skip-browser-warning': 'true'})
        .setAuth({'token': token})
        .enableAutoConnect()
        .enableReconnection()
        .build()
    );
    _socket = s;

    s.onConnect((_) {
      print('Socket connected');
      // Re-join active room on reconnect
      if (_activeRoomId != null) {
        emit('room:join', {'roomId': _activeRoomId});
      }
    });

    s.onReconnect((_) {
      print('Socket reconnected');
      if (_activeRoomId != null) {
        emit('room:join', {'roomId': _activeRoomId});
      }
    });

    // Chat events
    s.on('message:new', (data) => _messageController.add(Map<String, dynamic>.from(data)));
    s.on('typing', (data) => _typingController.add(Map<String, dynamic>.from(data)));
    s.on('user:online', (data) => _presenceController.add({...Map<String, dynamic>.from(data), 'status': 'ONLINE'}));
    s.on('user:offline', (data) => _presenceController.add({...Map<String, dynamic>.from(data), 'status': 'OFFLINE'}));

    s.on('user:online_list', (data) {
      if (data is Map && data.containsKey('onlineIds')) {
        _onlineListController.add(List<String>.from(data['onlineIds']));
      } else if (data is List) {
        _onlineListController.add(List<String>.from(data));
      }
    });

    s.on('message:status_update', (data) => _statusUpdateController.add(Map<String, dynamic>.from(data)));
    s.on('room:pin_update', (data) => _pinUpdateController.add(Map<String, dynamic>.from(data)));
    s.on('message:reaction_update', (data) => _reactionUpdateController.add(Map<String, dynamic>.from(data)));

    // Social events
    s.on('friend:request:received', (data) => _socialController.add({'event': 'request:received', 'data': data}));
    s.on('friend:request:accepted', (data) => _socialController.add({'event': 'request:accepted', 'data': data}));
    s.on('user:profile_updated', (data) => _socialController.add({'event': 'profile_updated', 'data': data}));

    // Call events
    s.on('call:incoming', (data) => _callIncomingController.add(Map<String, dynamic>.from(data)));
    s.on('call:accepted', (data) => _callAcceptedController.add(Map<String, dynamic>.from(data)));
    s.on('call:declined', (_) => _callDeclinedController.add(null));
    s.on('call:ended', (_) => _callEndedController.add(null));
    s.on('call:signal', (data) => _callSignalController.add(Map<String, dynamic>.from(data)));

    // Matchmaking events
    s.on('match_found', (data) => _matchFoundController.add(Map<String, dynamic>.from(data)));
    s.on('waiting_for_partner', (data) => _waitingForPartnerController.add(Map<String, dynamic>.from(data ?? {})));
    s.on('partner_skipped', (_) => _partnerSkippedController.add(null));
    s.on('queue_update', (data) => _queueUpdateController.add(Map<String, dynamic>.from(data ?? {})));

    s.onDisconnect((_) => print('Socket disconnected'));
  }

  void setActiveRoom(String? roomId) {
    _activeRoomId = roomId;
  }

  void reconnect() {
    if (_token != null && (_socket == null || _socket!.disconnected)) {
      connect(_token!);
    }
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  // Chat emitters
  void joinRoom(String roomId) {
    _socket?.emit('room:join', {'roomId': roomId});
  }

  void leaveRoom(String roomId) {
    _socket?.emit('room:leave', {'roomId': roomId});
  }

  void sendMessage(String roomId, String content, {String? clientId}) {
    _socket?.emit('message:send', {
      'roomId': roomId,
      'content': content,
      'clientId': clientId,
    });
  }

  void sendTyping(String roomId, bool isTyping) {
    _socket?.emit('typing', {
      'roomId': roomId,
      'isTyping': isTyping,
    });
  }

  void markAsSeen(String roomId) {
    _socket?.emit('message:seen', {'roomId': roomId});
  }

  void markAsReceived(String messageId) {
    _socket?.emit('message:received', {'messageId': messageId});
  }

  void pinMessage(String roomId, String messageId) {
    _socket?.emit('message:pin', {'roomId': roomId, 'messageId': messageId});
  }

  void unpinMessage(String roomId) {
    _socket?.emit('message:unpin', {'roomId': roomId});
  }

  void reactToMessage(String roomId, String messageId, String emoji) {
    _socket?.emit('message:react', {
      'roomId': roomId,
      'messageId': messageId,
      'emoji': emoji,
    });
  }

  // Call emitters
  void callInit(String roomId, String type, {bool isRandom = false}) {
    _socket?.emit('call:init', {'roomId': roomId, 'type': type, 'isRandom': isRandom});
  }

  void callAnswer(String callId, String roomId, bool accepted) {
    _socket?.emit('call:answer', {
      'callId': callId,
      'roomId': roomId,
      'accepted': accepted,
    });
  }

  void callSignal(String roomId, dynamic signal, {String? toUserId}) {
    _socket?.emit('call:signal', {
      'roomId': roomId,
      'signal': signal,
      if (toUserId != null) 'toUserId': toUserId,
    });
  }

  void callHangup(String callId, String roomId) {
    _socket?.emit('call:hangup', {'callId': callId, 'roomId': roomId});
  }

  // Matchmaking emitters
  void startRandomMatch() {
    _socket?.emit('start_random_match');
  }

  void skipRandomMatch() {
    _socket?.emit('skip_random_match');
  }

  void leaveRandomMode() {
    _socket?.emit('leave_random_mode');
  }

  void dispose() {
    _messageController.close();
    _typingController.close();
    _presenceController.close();
    _onlineListController.close();
    _callIncomingController.close();
    _callAcceptedController.close();
    _callDeclinedController.close();
    _callEndedController.close();
    _callSignalController.close();
    _statusUpdateController.close();
    _socialController.close();
    _pinUpdateController.close();
    _reactionUpdateController.close();
    _socket?.disconnect();
  }
}
