import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/social_provider.dart';
import 'home/chat_list_tab.dart';
import 'home/friends_tab.dart';
import 'home/user_search_screen.dart';
import 'status/status_screen.dart';
import 'call/call_history_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = ['Chats', 'Friends', 'Status', 'Calls', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);
    
    final List<Widget> _tabs = [
      const ChatListTab(),
      const FriendsTab(),
      const StatusScreen(),
      const CallHistoryScreen(),
      const ProfileScreen(),
    ];

    Widget _buildIcon(IconData icon, bool isSelected, Color primaryColor) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 22, color: isSelected ? primaryColor : null),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.user;
            final name = user?.username ?? user?.email ?? 'Me';
            final avatarBg = t.avatarColor(name);
            return Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _titles[_selectedIndex],
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: t.textPrimary, letterSpacing: -0.2),
            ),
            if (_selectedIndex == 0)
              Consumer2<ChatProvider, SocialProvider>(
                builder: (context, chat, social, _) {
                  final onlineFriendsCount = chat.onlineUserIds.where((id) => social.friendIds.contains(id)).length;
                  return Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: t.online, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$onlineFriendsCount friends online',
                          style: TextStyle(fontSize: 10, color: t.textSecondary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              t.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: t.textSecondary,
              size: 20,
            ),
            onPressed: () => t.toggleTheme(),
          ),
          if (_selectedIndex == 0 || _selectedIndex == 1)
            IconButton(
              icon: Icon(Icons.add_rounded, size: 24, color: t.primary),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserSearchScreen())),
            ),
          if (_selectedIndex == 3)
            IconButton(
              icon: Icon(Icons.logout_rounded, size: 20, color: t.primary),
              onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: t.isDarkMode ? t.bgPrimary : t.bgSecondary,
          border: Border(top: BorderSide(color: t.border.withOpacity(0.1), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: t.isDarkMode ? t.bgPrimary : t.bgSecondary,
          selectedItemColor: t.primary,
          unselectedItemColor: t.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.chat_bubble_outline_rounded, false, t.primary),
              activeIcon: _buildIcon(Icons.chat_bubble_rounded, true, t.primary),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.people_outline_rounded, false, t.primary),
              activeIcon: _buildIcon(Icons.people_rounded, true, t.primary),
              label: 'Friends',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.donut_large_rounded, false, t.primary),
              activeIcon: _buildIcon(Icons.donut_large_rounded, true, t.primary),
              label: 'Status',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.call_outlined, false, t.primary),
              activeIcon: _buildIcon(Icons.call_rounded, true, t.primary),
              label: 'Calls',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.person_outline_rounded, false, t.primary),
              activeIcon: _buildIcon(Icons.person_rounded, true, t.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
