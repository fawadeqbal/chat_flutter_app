import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/social_provider.dart';
import '../chat/chat_screen.dart';
import '../../models/user_model.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _searchController = TextEditingController();

  void _onSearchChanged(String value) {
    Provider.of<ChatProvider>(context, listen: false).searchUsers(value);
  }

  void _startChat(String userId) async {
    final chat = Provider.of<ChatProvider>(context, listen: false);
    final roomId = await chat.startPrivateChat(userId);
    if (roomId != null && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        title: Container(
          height: 44,
          decoration: BoxDecoration(color: t.bgInput, borderRadius: BorderRadius.circular(22)),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(color: t.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by username...',
              hintStyle: TextStyle(color: t.textDim),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: Icon(Icons.search_rounded, color: t.iconMuted, size: 20),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chat, _) {
          if (chat.isLoading) {
            return Center(child: CircularProgressIndicator(color: t.primary, strokeWidth: 2.5));
          }

          if (_searchController.text.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.primary.withOpacity(0.12),
                    ),
                    child: Icon(Icons.search_rounded, size: 38, color: t.primary.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 24),
                  Text('Find friends', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: t.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Search by username to start chatting', style: TextStyle(fontSize: 13, color: t.textSecondary)),
                ],
              ),
            );
          }

          if (chat.searchResults.isEmpty) {
            return Center(child: Text('No users found', style: TextStyle(fontSize: 14, color: t.textSecondary)));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: chat.searchResults.length,
            itemBuilder: (context, index) {
              final user = chat.searchResults[index];
              final displayName = user.username ?? user.email ?? 'Unknown';
              final avatarBg = t.avatarColor(displayName);

              return InkWell(
                onTap: () => _startChat(user.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // Circular avatar
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: avatarBg,
                        ),
                        child: Center(
                          child: Text(
                            displayName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Name + email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                            if (user.email != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(user.email!, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                              ),
                          ],
                        ),
                      ),

                      // Relationship-aware button
                      _UserActionButton(user: user),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _UserActionButton extends StatelessWidget {
  final UserModel user;
  const _UserActionButton({required this.user});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);
    final social = Provider.of<SocialProvider>(context);
    final chat = Provider.of<ChatProvider>(context, listen: false);

    return FutureBuilder<SocialStatus>(
      future: social.getFriendshipStatus(user.id),
      builder: (context, snapshot) {
        final status = snapshot.data ?? SocialStatus.NONE;

        if (status == SocialStatus.ACCEPTED) {
          return GestureDetector(
            onTap: () async {
              final roomId = await chat.startPrivateChat(user.id);
              if (roomId != null && context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: t.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Message', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          );
        }

        if (status == SocialStatus.PENDING) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: t.bgInput,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: t.border.withOpacity(0.2)),
            ),
            child: Text('Pending', style: TextStyle(color: t.textSecondary, fontWeight: FontWeight.w700, fontSize: 12)),
          );
        }

        return GestureDetector(
          onTap: () => social.sendFriendRequest(user.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: t.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: t.primary.withOpacity(0.3)),
            ),
            child: Text('Add Friend', style: TextStyle(color: t.primary, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        );
      },
    );
  }
}
