import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import 'account_info_screen.dart';
import 'notifications_settings_screen.dart';
import 'storage_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'theme_settings_screen.dart';
import 'starred_messages_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final displayName = user?.username ?? user?.email ?? 'User';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          // Header Section
          Center(
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountInfoScreen()),
              ),
              borderRadius: BorderRadius.circular(60),
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.avatarColor(displayName),
                      boxShadow: [
                        BoxShadow(
                          color: t.primary.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: user?.avatarUrl != null 
                        ? ClipOval(
                            child: Image.network(
                              '${auth.baseUrl}${user!.avatarUrl}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Text(
                                  displayName[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              displayName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
                            ),
                          ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: t.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.bgPrimary, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: t.textPrimary, letterSpacing: -0.5),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.qr_code_2_rounded, color: t.primary, size: 28),
                onPressed: () => _showQRCodeModal(context),
              ),
            ],
          ),
          Text(
            user?.email ?? '',
            style: TextStyle(fontSize: 14, color: t.textMuted, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),

          // Settings Options
          _buildSettingsTile(
            context,
            icon: Icons.person_outline_rounded,
            title: 'Account Information',
            color: Colors.blueAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountInfoScreen()),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.star_outline_rounded,
            title: 'Starred Messages',
            color: Colors.amber,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StarredMessagesScreen()),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            color: Colors.orangeAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsSettingsScreen()),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.data_usage_rounded,
            title: 'Storage and Data',
            subtitle: '2.4 GB used',
            color: Colors.tealAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StorageSettingsScreen()),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: t.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            title: 'Appearance',
            subtitle: t.isDarkMode ? 'Dark Mode' : 'Light Mode',
            color: Colors.purpleAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline_rounded,
            title: 'Privacy & Security',
            color: Colors.greenAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.logout_rounded,
            title: 'Log Out',
            color: Colors.redAccent,
            isDestructive: true,
            onTap: () => auth.logout(),
          ),
        ],
      ),
    );
  }

  void _showQRCodeModal(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: t.bgPrimary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: t.textDim.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            Text('My QR Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: t.textPrimary)),
            const SizedBox(height: 12),
            Text('Scan this to start a chat with me', style: TextStyle(fontSize: 14, color: t.textSecondary)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
              ),
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=PingCroodUser',
                width: 200,
                height: 200,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(width: 200, height: 200, child: Center(child: CircularProgressIndicator()));
                },
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.share_rounded, size: 20),
              label: const Text('Share Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: t.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final t = Provider.of<ThemeProvider>(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15, 
                      fontWeight: FontWeight.w700, 
                      color: isDestructive ? Colors.redAccent : t.textPrimary
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: t.textMuted, fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: t.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
