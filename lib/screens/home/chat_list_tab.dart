import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/social_provider.dart';
import 'package:intl/intl.dart';
import '../chat/chat_screen.dart';

class ChatListTab extends StatelessWidget {
  const ChatListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final currentUserId = auth.user?.id;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: t.bgInput,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.border.withOpacity(0.05)),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search chats...',
                hintStyle: TextStyle(color: t.textMuted, fontSize: 14),
                icon: Icon(Icons.search_rounded, color: t.textMuted, size: 20),
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ),

        // Filter Chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip(context, 'All', true),
              _buildFilterChip(context, 'Unread', false),
              _buildFilterChip(context, 'Groups', false),
              _buildFilterChip(context, 'Personal', false),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: Consumer2<ChatProvider, SocialProvider>(
            builder: (context, chat, social, _) {
              if (chat.isLoading && chat.rooms.isEmpty) {
                return Center(child: CircularProgressIndicator(color: t.primary, strokeWidth: 2.5));
              }

              final filteredRooms = chat.rooms.where((room) {
                if (room.isGroup) return true;
                final otherMembers = room.members.where((m) => m.userId != currentUserId).toList();
                if (otherMembers.isEmpty) return false;
                return social.friendIds.contains(otherMembers.first.userId);
              }).toList();

              if (filteredRooms.isEmpty) {
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
                        child: Icon(Icons.chat_bubble_outline_rounded, size: 38, color: t.primary.withOpacity(0.5)),
                      ),
                      const SizedBox(height: 24),
                      Text('No conversations yet', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: t.textPrimary)),
                      const SizedBox(height: 8),
                      Text('Tap + to start chatting', style: TextStyle(fontSize: 13, color: t.textSecondary)),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  if (social.pendingRequests.isNotEmpty)
                    Container(
                      color: t.primary.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.person_add_rounded, color: t.primary, size: 20),
                          const SizedBox(width: 12),
                          Text('${social.pendingRequests.length} pending friend requests',
                              style: TextStyle(color: t.primary, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _showRequestsSheet(context),
                            child: const Text('View'),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => chat.refreshFromServer(),
                      color: t.primary,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 0, bottom: 80),
                        itemCount: filteredRooms.length,
                        itemBuilder: (context, index) {
                          final room = filteredRooms[index];
                          final otherMembers = room.members.where((m) => m.userId != currentUserId).toList();
                          if (otherMembers.isEmpty) return const SizedBox.shrink();
                          final other = otherMembers.first;

                          final isOnline = chat.onlineUserIds.contains(other.userId);
                          final isRoomTyping = chat.isTyping(room.id);
                          final displayName = other.user.username ?? other.user.email ?? 'Unknown';
                          final avatarBg = t.avatarColor(displayName);

                          String timeStr = '';
                          if (room.lastMessage?.createdAt != null) {
                            final dt = room.lastMessage!.createdAt;
                            final now = DateTime.now();
                            if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
                              timeStr = DateFormat('HH:mm').format(dt);
                            } else {
                              timeStr = DateFormat('MMM d').format(dt);
                            }
                          }

                          return InkWell(
                            onTap: () {
                              chat.setActiveRoom(room.id);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: avatarBg,
                                        ),
                                        child: other.user.avatarUrl != null
                                            ? ClipOval(
                                                child: Image.network(
                                                  '${auth.baseUrl}${other.user.avatarUrl}',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Center(
                                                    child: Text(
                                                      displayName[0].toUpperCase(),
                                                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  displayName[0].toUpperCase(),
                                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                                                ),
                                              ),
                                      ),
                                      if (isOnline)
                                        Positioned(
                                          right: 1,
                                          bottom: 1,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: t.online,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: t.bgPrimary, width: 2.5),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName,
                                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: t.textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        isRoomTyping
                                            ? Text(
                                                'typing...',
                                                style: TextStyle(color: t.primary, fontStyle: FontStyle.italic, fontSize: 13, fontWeight: FontWeight.w600),
                                              )
                                            : Text(
                                                room.lastMessage?.content ?? 'Start a conversation',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 13, color: t.textSecondary, fontWeight: FontWeight.w400),
                                              ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (timeStr.isNotEmpty)
                                        Text(
                                          timeStr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: room.unreadCount > 0 ? t.primary : t.textMuted,
                                            fontWeight: room.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                                          ),
                                        ),
                                      if (room.unreadCount > 0) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: t.primary,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          constraints: const BoxConstraints(minWidth: 20),
                                          child: Center(
                                            child: Text(
                                              '${room.unreadCount}',
                                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    final t = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : t.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        backgroundColor: isSelected ? t.primary : t.bgInput,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _showRequestsSheet(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: t.bgPrimary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Consumer<SocialProvider>(
          builder: (context, social, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: t.border, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Text('Friend Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const SizedBox(height: 12),
                if (social.pendingRequests.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text('No pending requests'),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: social.pendingRequests.length,
                      itemBuilder: (context, index) {
                        final req = social.pendingRequests[index];
                        final sender = req['sender'];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: sender['avatarUrl'] != null ? NetworkImage(sender['avatarUrl']) : null,
                            child: sender['avatarUrl'] == null ? const Icon(Icons.person) : null,
                          ),
                          title: Text(sender['username'] ?? 'Unknown User'),
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
                      },
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            );
          },
        );
      },
    );
  }
}
