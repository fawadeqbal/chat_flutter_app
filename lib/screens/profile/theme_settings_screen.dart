import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  String _selectedTheme = 'System Default';
  String _selectedFontSize = 'Medium';

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      appBar: AppBar(
        title: Text('Appearance', style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: t.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('THEME'),
          _buildDropdownTile(
            'App Theme', 
            _selectedTheme, 
            ['Light', 'Dark', 'System Default'], 
            (val) => setState(() => _selectedTheme = val!),
            Icons.palette_outlined,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('DISPLAY'),
          _buildDropdownTile(
            'Font Size', 
            _selectedFontSize, 
            ['Small', 'Medium', 'Large', 'Extra Large'], 
            (val) => setState(() => _selectedFontSize = val!),
            Icons.format_size_rounded,
          ),
          const SizedBox(height: 24),
          _buildSwitchTile('Bold Text', 'Increase readability', false, (v) {}),
          _buildSwitchTile('High Contrast', 'More distinct colors', false, (v) {}),
          const SizedBox(height: 24),
          _buildSectionHeader('CHAT BACKGROUND'),
          _buildSettingsActionTile('Chat Wallpaper', 'Solid Colors', Icons.wallpaper_rounded),
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

  Widget _buildDropdownTile(String title, String value, List<String> options, ValueChanged<String?> onChanged, IconData icon) {
    final t = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: t.bgSecondary, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: t.textSecondary, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 15))),
          DropdownButton<String>(
            value: value,
            dropdownColor: t.bgSecondary,
            underline: const SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: t.primary),
            items: options.map((String opt) {
              return DropdownMenuItem<String>(
                value: opt,
                child: Text(opt, style: TextStyle(color: t.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
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

  Widget _buildSettingsActionTile(String title, String value, IconData icon) {
    final t = Provider.of<ThemeProvider>(context);
    return Container(
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
    );
  }
}
