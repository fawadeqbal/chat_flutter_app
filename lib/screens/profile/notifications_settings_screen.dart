import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _messages = true;
  bool _groups = false;
  bool _calls = true;
  bool _preview = true;
  bool _vibrate = true;

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: t.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('MESSAGE NOTIFICATIONS'),
          _buildSwitchTile('Show Notifications', 'Receive alerts for new messages', _messages, (v) => setState(() => _messages = v)),
          _buildSwitchTile('Show Previews', 'Show message content in notifications', _preview, (v) => setState(() => _preview = v)),
          const SizedBox(height: 24),
          _buildSectionHeader('GROUP NOTIFICATIONS'),
          _buildSwitchTile('Show Notifications', 'Receive alerts for group activity', _groups, (v) => setState(() => _groups = v)),
          const SizedBox(height: 24),
          _buildSectionHeader('SYSTEM'),
          _buildSwitchTile('Calls', 'Sound and vibrate for incoming calls', _calls, (v) => setState(() => _calls = v)),
          _buildSwitchTile('Vibrate', 'Enable haptic feedback', _vibrate, (v) => setState(() => _vibrate = v)),
          const SizedBox(height: 24),
          _buildSettingsActionTile(
            'Sound', 
            'Reflection', 
            Icons.volume_up_rounded,
            onTap: () => _showSelectionScreen(context, 'Sound', ['Reflection', 'Default', 'Chirp', 'None']),
          ),
          _buildSettingsActionTile(
            'Badge Count', 
            'Enabled', 
            Icons.looks_one_rounded,
            onTap: () => _showSelectionScreen(context, 'Badge Count', ['Enabled', 'Disabled']),
          ),
        ],
      ),
    );
  }

  void _showSelectionScreen(BuildContext context, String title, List<String> options) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectionSubScreen(title: title, options: options, currentSelection: options.first),
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

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    final t = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: t.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
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

  Widget _buildSettingsActionTile(String title, String value, IconData icon, {VoidCallback? onTap}) {
    final t = Provider.of<ThemeProvider>(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.bgSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
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
