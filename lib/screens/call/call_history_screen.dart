import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'package:intl/intl.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);

    // Dummy data for demonstration
    final List<Map<String, dynamic>> dummyCalls = [
      {'name': 'Alex Johnson', 'time': DateTime.now().subtract(const Duration(hours: 2)), 'type': 'VIDEO', 'incoming': true, 'missed': false},
      {'name': 'Sarah Parker', 'time': DateTime.now().subtract(const Duration(days: 1)), 'type': 'AUDIO', 'incoming': false, 'missed': false},
      {'name': 'Marcus Aurelius', 'time': DateTime.now().subtract(const Duration(days: 1, hours: 4)), 'type': 'VIDEO', 'incoming': true, 'missed': true},
      {'name': 'Alex Johnson', 'time': DateTime.now().subtract(const Duration(days: 2)), 'type': 'VIDEO', 'incoming': false, 'missed': false},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: dummyCalls.length,
      itemBuilder: (context, index) {
        final call = dummyCalls[index];
        final dt = call['time'] as DateTime;
        final timeStr = DateFormat('MMM d, HH:mm').format(dt);
        final isMissed = call['missed'] == true;
        final isIncoming = call['incoming'] == true;
        final isVideo = call['type'] == 'VIDEO';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.avatarColor(call['name'] as String),
                ),
                child: Center(
                  child: Text(
                    (call['name'] as String)[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call['name'] as String,
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w700, 
                        color: isMissed ? Colors.redAccent : t.textPrimary
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isIncoming ? Icons.call_received_rounded : Icons.call_made_rounded,
                          size: 14,
                          color: isMissed ? Colors.redAccent : Colors.greenAccent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          timeStr,
                          style: TextStyle(fontSize: 12, color: t.textMuted, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isVideo ? Icons.videocam_rounded : Icons.phone_rounded,
                  color: t.primary,
                  size: 22,
                ),
                onPressed: () {
                  // Re-initiate call logic
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
