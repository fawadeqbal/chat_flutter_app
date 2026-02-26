import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'blocked_contacts_screen.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      appBar: AppBar(
        title: Text('Privacy & Security', style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: t.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('PRIVACY'),
          _buildPrivacyTile('Last Seen & Online', 'Everyone', Icons.access_time_rounded, onTap: () => _showPrivacySelection(context, 'Last Seen & Online', ['Everyone', 'My Contacts', 'Nobody'])),
          _buildPrivacyTile('Profile Photo', 'My Contacts', Icons.person_rounded, onTap: () => _showPrivacySelection(context, 'Profile Photo', ['Everyone', 'My Contacts', 'Nobody'])),
          _buildPrivacyTile('About', 'Everyone', Icons.info_outline_rounded, onTap: () => _showPrivacySelection(context, 'About', ['Everyone', 'My Contacts', 'Nobody'])),
          _buildPrivacyTile('Status', 'My Contacts', Icons.donut_large_rounded, onTap: () => _showPrivacySelection(context, 'Status', ['Everyone', 'My Contacts', 'Nobody'])),
          _buildPrivacyTile('Groups', 'Everyone', Icons.group_rounded, onTap: () => _showPrivacySelection(context, 'Groups', ['Everyone', 'My Contacts', 'Nobody'])),
          const SizedBox(height: 24),
          _buildSectionHeader('CHATS'),
          _buildPrivacyTile(
            'Blocked Contacts', 
            '12 contacts', 
            Icons.block_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BlockedContactsScreen()),
            ),
          ),
          _buildSwitchTile('Read Receipts', 'If turned off, you won\'t send or receive read receipts', true, (v) {}),
          const SizedBox(height: 24),
          _buildSectionHeader('SECURITY'),
          _buildPrivacyTile('App Lock', 'Disabled', Icons.fingerprint_rounded),
          _buildPrivacyTile('Two-Step Verification', 'Enabled', Icons.security_rounded),
          _buildPrivacyTile('Security Notifications', 'Enabled', Icons.notifications_active_rounded),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Your privacy is our priority.',
              style: TextStyle(color: t.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final t = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: TextStyle(color: t.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
    );
  }

  void _showPrivacySelection(BuildContext context, String title, List<String> options) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectionSubScreen(title: title, options: options, currentSelection: options.first),
      ),
    );
  }

  Widget _buildPrivacyTile(String title, String value, IconData icon, {VoidCallback? onTap}) {
    final t = Provider.of<ThemeProvider>(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: t.bgSecondary, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: t.textSecondary, size: 20),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 15))),
            Text(value, style: TextStyle(color: t.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    final t = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: t.bgSecondary, borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile.adaptive(
        title: Text(title, style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: t.textMuted, fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: t.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

class SelectionSubScreen extends StatelessWidget {
  final String title;
  final List<String> options;
  final String currentSelection;

  const SelectionSubScreen({super.key, required this.title, required this.options, required this.currentSelection});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: t.bgPrimary,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: t.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option == currentSelection;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: t.bgSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text(option, style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              trailing: isSelected ? Icon(Icons.check_circle_rounded, color: t.primary) : null,
              onTap: () => Navigator.pop(context),
            ),
          );
        },
      ),
    );
  }
}
