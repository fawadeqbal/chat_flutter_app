import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/social_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/theme_provider.dart';
import '../chat/chat_screen.dart';
import '../../models/user_model.dart';

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SocialProvider>(context, listen: false).fetchFriends();
      Provider.of<SocialProvider>(context, listen: false).fetchPendingRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      body: Consumer<SocialProvider>(
        builder: (context, social, _) {
          if (social.isLoading && social.friendIds.isEmpty && social.pendingRequests.isEmpty) {
            return Center(child: CircularProgressIndicator(color: t.primary, strokeWidth: 2.5));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await social.fetchFriends();
              await social.fetchPendingRequests();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (social.pendingRequests.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Pending Requests (${social.pendingRequests.length})'),
                  ...social.pendingRequests.map((req) => _buildRequestTile(context, req)),
                  const SizedBox(height: 16),
                ],
                _buildSectionHeader(context, 'All Friends (${social.friends.length})'),
                if (social.friends.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.people_outline_rounded, size: 48, color: t.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('No friends yet', style: TextStyle(color: t.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('Search for users to add them!', style: TextStyle(color: t.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                else
                  ...social.friends.map((friend) => _buildFriendTile(context, friend)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final t = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: t.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildRequestTile(BuildContext context, Map<String, dynamic> req) {
    final t = Provider.of<ThemeProvider>(context);
    final social = Provider.of<SocialProvider>(context, listen: false);
    final sender = req['sender'];
    final displayName = sender['username'] ?? sender['email'] ?? 'Unknown';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: t.avatarColor(displayName),
        child: Text(displayName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      title: Text(displayName, style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w700)),
      subtitle: Text('Sent you a friend request', style: TextStyle(color: t.textSecondary, fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () => social.respondToRequest(req['id'], 'ACCEPTED', sender['id']),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () => social.respondToRequest(req['id'], 'DECLINED', sender['id']),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendTile(BuildContext context, UserModel friend) {
    final t = Provider.of<ThemeProvider>(context);
    final chat = Provider.of<ChatProvider>(context, listen: false);
    final displayName = friend.username ?? friend.email ?? 'Unknown';
    final avatarBg = t.avatarColor(displayName);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: avatarBg,
        child: Text(displayName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      title: Text(displayName, style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w700)),
      subtitle: Text(friend.email ?? '', style: TextStyle(color: t.textSecondary, fontSize: 12)),
      onTap: () async {
        final roomId = await chat.startPrivateChat(friend.id);
        if (roomId != null && context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        }
      },
    );
  }
}
