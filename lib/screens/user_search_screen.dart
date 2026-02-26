import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/social_provider.dart';
import '../models/user_model.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final socialProvider = Provider.of<SocialProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by username...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) => chatProvider.searchUsers(val),
            ),
          ),
        ),
      ),
      body: chatProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: chatProvider.searchResults.length,
              itemBuilder: (context, index) {
                final user = chatProvider.searchResults[index];
                return _UserListTile(user: user);
              },
            ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  final UserModel user;

  const _UserListTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final socialProvider = Provider.of<SocialProvider>(context);

    return FutureBuilder<SocialStatus>(
      future: socialProvider.getFriendshipStatus(user.id),
      builder: (context, snapshot) {
        final status = snapshot.data ?? SocialStatus.NONE;
        
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          title: Text(user.username ?? 'Unknown'),
          subtitle: Text(user.email ?? ''),
          trailing: _buildActionButton(context, socialProvider, status),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, SocialProvider social, SocialStatus status) {
    switch (status) {
      case SocialStatus.ACCEPTED:
        return ElevatedButton(
          onPressed: () {
            // Already friends, start chat
            Provider.of<ChatProvider>(context, listen: false).startPrivateChat(user.id);
            Navigator.pop(context);
          },
          child: const Text('Message'),
        );
      case SocialStatus.PENDING:
        return const Text('Pending', style: TextStyle(color: Colors.grey));
      default:
        return ElevatedButton(
          onPressed: () => social.sendFriendRequest(user.id),
          child: const Text('Add Friend'),
        );
    }
  }
}
