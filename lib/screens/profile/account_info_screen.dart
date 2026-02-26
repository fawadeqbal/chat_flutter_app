import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _usernameController.text = user.username ?? '';
      _bioController.text = user.bio ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        if (!mounted) return;
        setState(() => _isSaving = true);
        final auth = Provider.of<AuthProvider>(context, listen: false);
        await auth.uploadAvatar(image);
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      print('DEBUG: Image selection failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select image: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _showImageSourceSheet() {
    final t = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: t.bgPrimary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: t.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(Icons.camera_alt_rounded, 'Camera', () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                }),
                _buildSourceOption(Icons.photo_library_rounded, 'Gallery', () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(IconData icon, String label, VoidCallback onTap) {
    final t = Provider.of<ThemeProvider>(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: t.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary)),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await auth.updateProfile({
      'username': _usernameController.text,
      'bio': _bioController.text,
      'phoneNumber': _phoneController.text,
    });

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), behavior: SnackBarBehavior.floating),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final displayName = user?.username ?? user?.email ?? 'User';

    return Scaffold(
      backgroundColor: t.bgPrimary,
      appBar: AppBar(
        title: Text('Account Info', style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving 
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: t.primary))
              : Text('Save', style: TextStyle(color: t.primary, fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Hero(
                    tag: 'profile_avatar',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.avatarColor(displayName),
                        border: Border.all(color: t.border.withOpacity(0.1), width: 1),
                        image: user?.avatarUrl != null 
                          ? DecorationImage(
                              image: NetworkImage('${auth.baseUrl}${user!.avatarUrl}'),
                              fit: BoxFit.cover,
                            )
                          : null,
                      ),
                      child: user?.avatarUrl == null 
                        ? Center(
                            child: Text(
                              displayName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
                            ),
                          )
                        : null,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: _showImageSourceSheet,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: t.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.bgPrimary, width: 3),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _buildInputField(
              label: 'Username',
              controller: _usernameController,
              icon: Icons.person_outline_rounded,
              hint: 'How people will see you',
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: 'Bio',
              controller: _bioController,
              icon: Icons.info_outline_rounded,
              hint: 'A little about yourself',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: 'Phone Number',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              hint: '+1 234 567 890',
            ),
            const SizedBox(height: 48),
            Text(
              'Email (Not editable)',
              style: TextStyle(color: t.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: t.bgSecondary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: t.border.withOpacity(0.1)),
              ),
              child: Text(user?.email ?? '', style: TextStyle(color: t.textMuted, fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    final t = Provider.of<ThemeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: TextStyle(color: t.textSecondary, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: t.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: t.textMuted, fontSize: 14, fontWeight: FontWeight.w400),
            prefixIcon: Icon(icon, color: t.primary, size: 20),
            filled: true,
            fillColor: t.bgSecondary,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
