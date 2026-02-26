import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../providers/call_provider.dart';
import '../../providers/random_match_provider.dart';
import '../../providers/theme_provider.dart';

class CallOverlay extends StatelessWidget {
  const CallOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CallProvider>(
      builder: (context, call, _) {
        if (call.incomingCall != null) {
          return _IncomingCallDialog(call: call);
        }
        if (call.activeCall != null || call.isCalling) {
          return _ActiveCallView(call: call);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ──────────────────────────────────────────
// Incoming Call Dialog — Snapchat Style
// ──────────────────────────────────────────
class _IncomingCallDialog extends StatelessWidget {
  final CallProvider call;
  const _IncomingCallDialog({required this.call});

  @override
  Widget build(BuildContext context) {
    final incoming = call.incomingCall!;
    final callerName = incoming['fromUserName']?.toString() ?? 'Unknown';
    final callType = incoming['type']?.toString() ?? 'AUDIO';
    final isVideo = callType == 'VIDEO';
    final t = Provider.of<ThemeProvider>(context, listen: false);

    return Material(
      color: Colors.black.withOpacity(0.88),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: t.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: t.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 40)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing circular icon
              Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.2),
                    duration: const Duration(milliseconds: 1000),
                    builder: (_, value, __) => Container(
                      width: 96 * value,
                      height: 96 * value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.primary.withOpacity(0.15),
                      ),
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.primary,
                      boxShadow: [BoxShadow(color: t.primary.withOpacity(0.4), blurRadius: 24)],
                    ),
                    child: Icon(
                      isVideo ? Icons.videocam_rounded : Icons.phone_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '${callType.toLowerCase()} Call',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: t.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'from $callerName',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: t.primary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decline
                  GestureDetector(
                    onTap: () => call.answerCall(false),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.destructive.withOpacity(0.1),
                        border: Border.all(color: t.destructive.withOpacity(0.3)),
                      ),
                      child: Icon(Icons.call_end_rounded, color: t.destructive, size: 28),
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Accept
                  GestureDetector(
                    onTap: () => call.answerCall(true),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.online.withOpacity(0.1),
                        border: Border.all(color: t.online.withOpacity(0.3)),
                        boxShadow: [BoxShadow(color: t.online.withOpacity(0.2), blurRadius: 16)],
                      ),
                      child: Icon(Icons.phone_rounded, color: t.online, size: 28),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Active Call View — Snapchat Style
// ──────────────────────────────────────────
class _ActiveCallView extends StatelessWidget {
  final CallProvider call;
  const _ActiveCallView({required this.call});

  @override
  Widget build(BuildContext context) {
    final callData = call.activeCall;
    final userName = callData?['userName']?.toString() ?? '';
    final isCalling = call.isCalling;
    final t = Provider.of<ThemeProvider>(context, listen: false);

    return Material(
      color: const Color(0xFF121212),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: t.destructive,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCalling ? 'CALLING...' : 'ON CALL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      if (!isCalling && userName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            userName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      call.formattedDuration,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video area
            Expanded(
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  // Detect Swipe Up
                  if (details.primaryVelocity != null && details.primaryVelocity! < -500) {
                    final match = Provider.of<RandomMatchProvider>(context, listen: false);
                    if (match.state == MatchState.matched) {
                      match.skipMatch();
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Stack(
                    children: [
                      // Remote video
                      if (call.remoteStream != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: RTCVideoView(
                            call.remoteRenderer,
                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          ),
                        )
                      else
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.05),
                                ),
                                child: Icon(Icons.videocam_rounded, size: 28, color: Colors.white.withOpacity(0.3)),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isCalling ? 'Ringing...' : 'Waiting for peer...',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withOpacity(0.3),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Overlay for Random Match (Portrait Name & Avatar)
                      Consumer<RandomMatchProvider>(
                        builder: (context, match, _) {
                          if (match.state == MatchState.matched) {
                            return Positioned(
                              top: 20,
                              left: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: t.primary,
                                      child: const Icon(Icons.person, size: 14, color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Local PiP
                      if (call.localStream != null)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            width: 100,
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 12)],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: RTCVideoView(
                                call.localRenderer,
                                mirror: true,
                                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                              ),
                            ),
                          ),
                        ),
                      
                      // Swipe Up Prompt
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white.withOpacity(0.5), size: 30),
                              Text(
                                'SWIPE UP TO SKIP',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Controls — Snapchat circular buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    icon: call.isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                    isActive: !call.isMicOn,
                    onTap: call.toggleMic,
                  ),
                  _ControlButton(
                    icon: call.isVideoOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                    isActive: !call.isVideoOn,
                    onTap: call.toggleVideo,
                  ),
                  // Skip button for Random Match
                  Consumer<RandomMatchProvider>(
                    builder: (context, match, _) {
                      if (match.state == MatchState.matched) {
                        return _ControlButton(
                          icon: Icons.skip_next_rounded,
                          isActive: true,
                          activeColor: t.primary,
                          onTap: () => match.skipMatch(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // Hangup — pill button
                  GestureDetector(
                    onTap: call.hangupCall,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      decoration: BoxDecoration(
                        color: t.destructive,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [BoxShadow(color: t.destructive.withOpacity(0.3), blurRadius: 16)],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.call_end_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'HANG UP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.isActive,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context, listen: false);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? (activeColor ?? t.destructive) : Colors.white.withOpacity(0.08),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
          size: 24,
        ),
      ),
    );
  }
}
