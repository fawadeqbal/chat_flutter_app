import 'dart:async';
import 'package:flutter/material.dart';
import '../core/socket/socket_service.dart';
import 'call_provider.dart';

enum MatchState { idle, searching, matched }

class RandomMatchProvider extends ChangeNotifier {
  final SocketService _socketService;
  final CallProvider _callProvider;

  MatchState _state = MatchState.idle;
  String? _currentRoomId;
  String? _partnerId;
  bool _initialized = false;
  int _queueCount = 0;

  // Getters
  MatchState get state => _state;
  String? get currentRoomId => _currentRoomId;
  String? get partnerId => _partnerId;
  bool get isSearching => _state == MatchState.searching;
  int get queueCount => _queueCount;

  RandomMatchProvider(this._socketService, this._callProvider);

  void init() {
    if (_initialized) return;
    _initialized = true;
    _listenToEvents();
  }

  void _listenToEvents() {
    _socketService.matchFoundStream.listen((data) {
      _currentRoomId = data['roomId']?.toString();
      _partnerId = data['partnerId']?.toString();
      final bool isOfferer = data['isOfferer'] ?? false;
      _state = MatchState.matched;
      notifyListeners();

      // Automatically initiate call when match is found, but only for the designated offerer
      if (_currentRoomId != null && isOfferer) {
        _callProvider.initiateCall(_currentRoomId!, 'VIDEO', isRandom: true);
      }
    });

    _socketService.waitingForPartnerStream.listen((data) {
      _state = MatchState.searching;
      _queueCount = data['count'] ?? 0;
      notifyListeners();
    });

    _socketService.queueUpdateStream.listen((data) {
      _queueCount = data['count'] ?? 0;
      notifyListeners();
    });

    _socketService.partnerSkippedStream.listen((_) {
      // Partner skipped, show logic or revert to searching
      // Backend automatically requeues us if we are in random mode
      _state = MatchState.searching;
      _currentRoomId = null;
      _partnerId = null;
      notifyListeners();
    });
    
    // Listen to call ended to potentially revert to searching or idle
    _socketService.callEndedStream.listen((_) {
      if (_state == MatchState.matched) {
         // Partner hung up or skipped
         // Keep them in searching mode for Azar-style continuity
         _state = MatchState.searching;
         _currentRoomId = null;
         _partnerId = null;
         notifyListeners();
         
         // Ensure searching logic is active on backend if they didn't skip
         // (If partner skipped, backend already requeued us. If partner hung up, we might need to start again)
         // To be safe, we can call startRandomMatch if we are still in this mode
         _socketService.startRandomMatch();
      }
    });
  }

  void startMatching() {
    _state = MatchState.searching;
    notifyListeners();
    _socketService.startRandomMatch();
  }

  void skipMatch() {
    if (_state == MatchState.matched) {
      _callProvider.hangupCall();
    }
    _state = MatchState.searching;
    _currentRoomId = null;
    _partnerId = null;
    notifyListeners();
    _socketService.skipRandomMatch();
    
    // Ensure camera preview is ready for the search UI
    _callProvider.ensureLocalStream();
  }

  void stopMatching() {
    if (_state == MatchState.matched) {
      _callProvider.hangupCall();
    }
    _state = MatchState.idle;
    _currentRoomId = null;
    _partnerId = null;
    notifyListeners();
    _socketService.leaveRandomMode();
  }
}
