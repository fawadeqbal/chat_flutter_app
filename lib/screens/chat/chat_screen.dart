import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/call_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _typingTimer;
  bool _isTyping = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final chat = Provider.of<ChatProvider>(context, listen: false);
      chat.sendMessage(_messageController.text.trim());
      _messageController.clear();
      _stopTyping();
      _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _onTextChanged(String value) {
    final chat = Provider.of<ChatProvider>(context, listen: false);
    if (value.isNotEmpty && !_isTyping) {
      _isTyping = true;
      chat.sendTypingEvent(true);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () => _stopTyping());
    setState(() {});
  }

  void _stopTyping() {
    if (_isTyping) {
      _isTyping = false;
      Provider.of<ChatProvider>(context, listen: false).sendTypingEvent(false);
    }
    _typingTimer?.cancel();
  }

  @override
  void dispose() {
    _stopTyping();
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  String _formatMessageTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today ${DateFormat('HH:mm').format(dt)}';
    }
    return DateFormat('MMM d, HH:mm').format(dt);
  }

  Widget _buildStatusIndicator(MessageStatus status) {
    final t = Provider.of<ThemeProvider>(context, listen: false);
    switch (status) {
      case MessageStatus.SENT:
        return Icon(Icons.done_rounded, size: 14, color: t.textMuted.withOpacity(0.5));
      case MessageStatus.DELIVERED:
        return Icon(Icons.done_all_rounded, size: 14, color: t.textMuted.withOpacity(0.5));
      case MessageStatus.SEEN:
        return Icon(Icons.done_all_rounded, size: 14, color: t.primary);
    }
  }

  void _showPinOptions(BuildContext context, MessageModel message, ChatProvider chat) {
    final t = Provider.of<ThemeProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: t.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: t.border, borderRadius: BorderRadius.circular(2)),
            ),
            // Emoji Row
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['👍', '❤️', '😂', '😮', '😢', '🔥'].map((emoji) {
                  final isReacted = message.reactions.any((r) => r.emoji == emoji && r.userId == chat.currentUserId);
                  return InkWell(
                    onTap: () {
                      chat.reactToMessage(message.id, emoji);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isReacted ? t.primary.withOpacity(0.15) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isReacted ? Border.all(color: t.primary.withOpacity(0.3), width: 1) : null,
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  );
                }).toList(),
              ),
            ),
            Divider(color: t.border.withOpacity(0.5), height: 1),
            ListTile(
              leading: Icon(Icons.push_pin_rounded, color: t.primary),
              title: Text(chat.rooms.firstWhere((r) => r.id == chat.activeRoomId).pinnedMessageId == message.id ? 'Unpin Message' : 'Pin Message', 
                style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600)),
              onTap: () {
                if (chat.rooms.firstWhere((r) => r.id == chat.activeRoomId).pinnedMessageId == message.id) {
                  chat.unpinMessage();
                } else {
                  chat.pinMessage(message.id);
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.copy_rounded, color: t.textSecondary),
              title: Text('Copy Text', style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReactionBadges(List<ReactionModel> reactions, ThemeProvider t) {
    if (reactions.isEmpty) return [];
    
    final Map<String, int> counts = {};
    for (var r in reactions) {
      counts[r.emoji] = (counts[r.emoji] ?? 0) + 1;
    }

    return counts.entries.map((e) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: t.isDarkMode ? t.bgSecondary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.border.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(e.key, style: const TextStyle(fontSize: 12)),
            if (e.value > 1) ...[
              const SizedBox(width: 4),
              Text(
                '${e.value}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: t.textSecondary),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final currentUserId = auth.user?.id;
    final t = Provider.of<ThemeProvider>(context);

    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        String otherName = 'Chat';
        bool isOtherOnline = false;
        bool isOtherTyping = false;
        String? otherAvatarUrl;

        if (chat.activeRoomId != null) {
          final activeRoom = chat.rooms.where((r) => r.id == chat.activeRoomId).toList();
          if (activeRoom.isNotEmpty) {
            final room = activeRoom.first;
            final otherMembers = room.members.where((m) => m.userId != currentUserId).toList();
            if (otherMembers.isNotEmpty) {
              final other = otherMembers.first;
              otherName = other.user.username ?? other.user.email ?? 'Unknown';
              isOtherOnline = chat.onlineUserIds.contains(other.userId);
              otherAvatarUrl = other.user.avatarUrl;
            }
            isOtherTyping = chat.isTyping(room.id);
          }
        }

        final avatarBg = t.avatarColor(otherName);

        return Scaffold(
          appBar: AppBar(
            leadingWidth: 56,
            titleSpacing: 0,
            title: Row(
              children: [
                // Circular avatar
                Stack(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: avatarBg,
                        image: otherAvatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage('${auth.baseUrl}$otherAvatarUrl'),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: otherAvatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                '${auth.baseUrl}$otherAvatarUrl',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Text(
                                    otherName[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                otherName[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                              ),
                            ),
                    ),
                    if (isOtherOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: t.online,
                            shape: BoxShape.circle,
                            border: Border.all(color: t.bgPrimary, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(otherName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: t.textPrimary, letterSpacing: -0.2)),
                      if (isOtherTyping)
                        Text('typing...', style: TextStyle(fontSize: 10, color: t.primary, fontStyle: FontStyle.italic, fontWeight: FontWeight.w700))
                      else
                        Text(
                          isOtherOnline ? 'Online' : 'Offline',
                          style: TextStyle(fontSize: 10, color: isOtherOnline ? t.online : t.textMuted, fontWeight: FontWeight.w700),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.phone_rounded, color: t.primary, size: 20),
                onPressed: () {
                  if (chat.activeRoomId != null) {
                    Provider.of<CallProvider>(context, listen: false).initiateCall(chat.activeRoomId!, 'AUDIO');
                  }
                },
                tooltip: 'Audio Call',
              ),
              IconButton(
                icon: Icon(Icons.videocam_rounded, color: t.primary, size: 22),
                onPressed: () {
                  if (chat.activeRoomId != null) {
                    Provider.of<CallProvider>(context, listen: false).initiateCall(chat.activeRoomId!, 'VIDEO');
                  }
                },
                tooltip: 'Video Call',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Pinned Message Bar
              Consumer<ChatProvider>(
                builder: (context, chat, _) {
                  final activeRoom = chat.rooms.where((r) => r.id == chat.activeRoomId).toList();
                  if (activeRoom.isEmpty || activeRoom.first.pinnedMessage == null) return const SizedBox.shrink();
                  
                  final pinned = activeRoom.first.pinnedMessage!;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: t.isDarkMode ? t.bgSecondary.withOpacity(0.8) : Colors.white,
                      border: Border(bottom: BorderSide(color: t.border.withOpacity(0.08))),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: t.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.push_pin_rounded, size: 14, color: t.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pinned Message', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: t.primary, letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text(
                                pinned.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, color: t.textPrimary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 18, color: t.textMuted),
                          onPressed: () => chat.unpinMessage(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final messages = chat.currentRoomMessages;
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.waving_hand_rounded, size: 48, color: t.textDim),
                            const SizedBox(height: 16),
                            Text('Say hello! 👋', style: TextStyle(fontSize: 16, color: t.textSecondary)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUserId;
                        final showTime = index == messages.length - 1 ||
                            messages[index].createdAt.difference(messages[index + 1].createdAt).inMinutes.abs() > 5;

                        return Column(
                          children: [
                            if (showTime)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  _formatMessageTime(message.createdAt),
                                  style: TextStyle(fontSize: 10, color: t.textDim, fontWeight: FontWeight.w600),
                                ),
                              ),
                            GestureDetector(
                              onLongPress: () {
                                _showPinOptions(context, message, chat);
                                HapticFeedback.mediumImpact();
                              },
                              child: Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 2),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                    child: Column(
                                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isMe ? t.msgMeBg : t.msgOtherBg,
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(22),
                                              topRight: const Radius.circular(22),
                                              bottomLeft: isMe ? const Radius.circular(22) : const Radius.circular(6),
                                              bottomRight: isMe ? const Radius.circular(6) : const Radius.circular(22),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              )
                                            ],
                                          ),
                                          child: Text(
                                            message.content,
                                            style: TextStyle(
                                              color: isMe ? t.msgMeText : t.msgOtherText,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        if (message.reactions.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                                            child: Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: _buildReactionBadges(message.reactions, t),
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
                                          child: Row(
                                            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                DateFormat('HH:mm').format(message.createdAt),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: t.textMuted.withOpacity(0.7),
                                                ),
                                              ),
                                              if (isMe) ...[
                                                const SizedBox(width: 6),
                                                _buildStatusIndicator(message.status),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // Typing indicator
              if (isOtherTyping)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: t.msgOtherBg, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (i) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.4, end: 1.0),
                              duration: Duration(milliseconds: 600 + i * 200),
                              builder: (context, val, _) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(color: t.primary.withOpacity(val), shape: BoxShape.circle),
                                );
                              },
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$otherName is typing', style: TextStyle(fontSize: 11, color: t.textMuted, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),

              // Message Input — Snapchat style
              Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 16, 24),
                decoration: BoxDecoration(
                  color: t.isDarkMode ? t.bgPrimary : t.bgSecondary,
                  border: Border(top: BorderSide(color: t.border)),
                ),
                child: Row(
                  children: [
                    // Attachment Icon
                    IconButton(
                      icon: Icon(Icons.attach_file_rounded, color: t.textMuted, size: 24),
                      onPressed: () {
                        // Handle attachment
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: t.bgInput,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: t.border.withOpacity(0.05)),
                        ),
                        child: _isRecording 
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.2, end: 1.0),
                                    duration: const Duration(milliseconds: 500),
                                    builder: (context, val, _) => Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(val), shape: BoxShape.circle),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('Recording...', style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )
                          : TextField(
                              controller: _messageController,
                              style: TextStyle(color: t.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Send a Message',
                                hintStyle: TextStyle(color: t.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                                border: InputBorder.none,
                                filled: false,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              onChanged: _onTextChanged,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_messageController.text.trim().isEmpty)
                      GestureDetector(
                        onLongPressStart: (_) => setState(() => _isRecording = true),
                        onLongPressEnd: (_) => setState(() => _isRecording = false),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording ? Colors.redAccent.withOpacity(0.1) : t.bgInput,
                          ),
                          child: Icon(
                            _isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                            color: _isRecording ? Colors.redAccent : t.textMuted,
                            size: 24,
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _sendMessage,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: 1.0,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: t.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: t.primary.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

