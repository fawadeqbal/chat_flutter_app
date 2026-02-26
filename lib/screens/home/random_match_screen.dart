import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../providers/random_match_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/call_provider.dart';

class RandomMatchScreen extends StatefulWidget {
  const RandomMatchScreen({super.key});

  @override
  State<RandomMatchScreen> createState() => _RandomMatchScreenState();
}

class _RandomMatchScreenState extends State<RandomMatchScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);
    final match = Provider.of<RandomMatchProvider>(context);
    final call = Provider.of<CallProvider>(context);

    // Ensure camera is active when searching
    if (match.isSearching && call.localStream == null) {
      call.ensureLocalStream();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live Camera Preview
          if (call.localStream != null)
            SizedBox.expand(
              child: RTCVideoView(
                call.localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            )
          else
            Container(color: const Color(0xFF121212)),

          // Overlay Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // App Bar Area
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () {
                    match.stopMatching();
                    call.stopLocalStream();
                    Navigator.pop(context);
                  },
                ),
                const Spacer(),
                const Text(
                  'RANDOM MATCH',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48), // Balance for Leading
              ],
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (match.isSearching)
                        ...List.generate(3, (index) {
                          return AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final progress = (_pulseController.value + (index / 3)) % 1.0;
                              return Container(
                                width: 120 + (180 * progress),
                                height: 120 + (180 * progress),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(1.0 - progress),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: t.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: t.primary.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                Text(
                  match.isSearching ? 'SEARCHING...' : 'READY TO FLIP?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                if (match.isSearching)
                  Column(
                    children: [
                      Text(
                        'Matching you with someone new!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${match.queueCount} people searching now',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 100),
                if (!match.isSearching)
                  ElevatedButton(
                    onPressed: () {
                      call.ensureLocalStream();
                      match.startMatching();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: t.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      elevation: 12,
                    ),
                    child: const Text(
                      'START MATCHING',
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
                  )
                else
                  OutlinedButton(
                    onPressed: () {
                      match.stopMatching();
                      call.stopLocalStream();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                    child: const Text(
                      'STOP',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper to handle rounded rectangle based on app patterns
class RoundedRectanglePlatform {
  static BorderRadius borderRadius(double radius) => BorderRadius.circular(radius);
}
