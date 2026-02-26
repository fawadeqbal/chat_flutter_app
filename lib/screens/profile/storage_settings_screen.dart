import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class StorageSettingsScreen extends StatelessWidget {
  const StorageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: t.bgPrimary,
      appBar: AppBar(
        title: Text('Storage and Data', style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: t.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUsageOverview(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'STORAGE USAGE'),
            _buildStorageItem(context, 'Media', '1.2 GB', Icons.image_rounded, Colors.blue, onTap: () => _showStorageDetail(context, 'Media', '1.2 GB', ['Photos: 800 MB', 'Videos: 400 MB'])),
            _buildStorageItem(context, 'Files', '840 MB', Icons.file_present_rounded, Colors.orange, onTap: () => _showStorageDetail(context, 'Files', '840 MB', ['PDFs: 500 MB', 'Docs: 340 MB'])),
            _buildStorageItem(context, 'Voice Messages', '420 MB', Icons.mic_rounded, Colors.green, onTap: () => _showStorageDetail(context, 'Voice Messages', '420 MB', ['Voice clips: 420 MB'])),
            _buildStorageItem(context, 'Other', '120 MB', Icons.more_horiz_rounded, Colors.grey),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'NETWORK USAGE'),
            _buildSettingsActionTile(context, 'Network Usage', '2.4 GB sent • 8.1 GB received', Icons.network_check_rounded),
            _buildSwitchTile(context, 'Use Less Data for Calls', 'Reduce quality during voice calls', false, (v) {}),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'AUTO-DOWNLOAD'),
            _buildSettingsActionTile(context, 'When using cellular', 'Photos', Icons.signal_cellular_alt_rounded),
            _buildSettingsActionTile(context, 'When using Wi-Fi', 'All Media', Icons.wifi_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageOverview(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Storage', style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
              Text('2.58 GB', style: TextStyle(color: t.primary, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.65,
              minHeight: 12,
              backgroundColor: t.bgSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(t.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildUsageDot(context, 'Used (65%)', t.primary),
              const SizedBox(width: 16),
              _buildUsageDot(context, 'Free (35%)', t.textMuted.withOpacity(0.3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageDot(BuildContext context, String label, Color color) {
    final t = Provider.of<ThemeProvider>(context);
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: t.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final t = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: TextStyle(color: t.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
    );
  }

  void _showStorageDetail(BuildContext context, String title, String total, List<String> breakdown) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StorageBreakdownScreen(title: title, total: total, breakdown: breakdown),
      ),
    );
  }

  Widget _buildStorageItem(BuildContext context, String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    final t = Provider.of<ThemeProvider>(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 15))),
            Text(value, style: TextStyle(color: t.textMuted, fontWeight: FontWeight.w600, fontSize: 13)),
            if (onTap != null) const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    final t = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
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

  Widget _buildSettingsActionTile(BuildContext context, String title, String value, IconData icon) {
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

class StorageBreakdownScreen extends StatelessWidget {
  final String title;
  final String total;
  final List<String> breakdown;

  const StorageBreakdownScreen({super.key, required this.title, required this.total, required this.breakdown});

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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.bgSecondary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text('Total usage for $title', style: TextStyle(color: t.textSecondary, fontSize: 14)),
                const SizedBox(height: 8),
                Text(total, style: TextStyle(color: t.primary, fontWeight: FontWeight.w900, fontSize: 32)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('DETAIL BREAKDOWN', style: TextStyle(color: t.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 16),
          ...breakdown.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: t.bgSecondary, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.split(':')[0], style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(item.split(':')[1].trim(), style: TextStyle(color: t.textMuted, fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              )),
          const SizedBox(height: 48),
          OutlinedButton(
            onPressed: () {}, // Mock action
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Clear Chat Media', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
