import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // My Status
        _buildStatusItem(
          context,
          title: 'My Status',
          subtitle: 'Tap to add status update',
          isMe: true,
          avatarColor: t.primary.withOpacity(0.1),
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            'RECENT UPDATES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
        ),

        // Dummy Recent Updates
        _buildStatusItem(
          context,
          title: 'Alex Johnson',
          subtitle: 'Today, 09:24',
          hasUpdate: true,
          avatarColor: Colors.blueAccent,
        ),
        _buildStatusItem(
          context,
          title: 'Sarah Parker',
          subtitle: 'Yesterday, 21:15',
          hasUpdate: true,
          avatarColor: Colors.purpleAccent,
        ),
        _buildStatusItem(
          context,
          title: 'Tech Group',
          subtitle: 'Yesterday, 18:40',
          hasUpdate: true,
          avatarColor: Colors.orangeAccent,
        ),
      ],
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    bool isMe = false,
    bool hasUpdate = false,
    required Color avatarColor,
  }) {
    final t = Provider.of<ThemeProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: hasUpdate 
                    ? Border.all(color: t.primary, width: 2.5) 
                    : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarColor,
                  ),
                  child: Center(
                    child: isMe 
                      ? Icon(Icons.person_rounded, color: t.primary, size: 30)
                      : Text(title[0], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              if (isMe)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: t.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: t.bgPrimary, width: 2),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: t.textMuted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
