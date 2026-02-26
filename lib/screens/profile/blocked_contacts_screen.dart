import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class BlockedContactsScreen extends StatelessWidget {
  const BlockedContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);
    final mockBlocked = [
      {'name': 'Spam User 1', 'email': 'spam1@test.com'},
      {'name': 'Aggressive Account', 'email': 'bad@test.com'},
      {'name': 'Unknown #402', 'email': '+1992929292'},
    ];

    return Scaffold(
      backgroundColor: t.bgPrimary,
      appBar: AppBar(
        title: Text('Blocked Contacts', style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: t.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Add', style: TextStyle(color: t.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Blocked contacts will no longer be able to call you or send you messages.',
              textAlign: TextAlign.center,
              style: TextStyle(color: t.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: mockBlocked.length,
              itemBuilder: (context, index) {
                final user = mockBlocked[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: t.bgSecondary, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: t.primary.withOpacity(0.1),
                        child: Text(user['name']![0], style: TextStyle(color: t.primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['name']!, style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                            Text(user['email']!, style: TextStyle(color: t.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Unblock', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
