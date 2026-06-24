import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

/// Halaman Edit Profil — berlaku untuk ketiga role (Admin/Helpdesk/User).
/// Mengupdate kolom `name` dan `avatar_url` di tabel profiles lewat
/// AuthService.updateProfile().
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  bool _isLoading = false;
  String? _errorMessage;
  File? _pickedImage;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _currentAvatarUrl = user?.avatarUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? img =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (img != null) {
        setState(() => _pickedImage = File(img.path));
      }
    } catch (e) {
      _showError('Tidak dapat mengakses galeri: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = AuthService().currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? newAvatarUrl;

      // Upload foto baru ke Supabase Storage bucket 'avatars' bila dipilih.
      if (_pickedImage != null) {
        final client = Supabase.instance.client;
        final ext = _pickedImage!.path.split('.').last;
        final storagePath = '${user.id}/avatar.$ext';
        await client.storage.from('avatars').upload(
              storagePath,
              _pickedImage!,
              fileOptions: const FileOptions(upsert: true),
            );
        newAvatarUrl = client.storage.from('avatars').getPublicUrl(storagePath);
      }

      await AuthService().updateProfile(
        name: _nameCtrl.text.trim(),
        avatarUrl: newAvatarUrl ?? _currentAvatarUrl,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: AppColors.statusResolved,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal menyimpan profil: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : (_currentAvatarUrl != null
                                  ? NetworkImage(_currentAvatarUrl!)
                                  : null) as ImageProvider?,
                          child: _pickedImage == null && _currentAvatarUrl == null
                              ? const Icon(Icons.person,
                                  size: 56, color: AppColors.primary)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text('Ketuk untuk ganti foto',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ),
                const SizedBox(height: 28),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const Text('Nama Lengkap',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama lengkap',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),

                const Text('Email',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: user?.email ?? '',
                  enabled: false,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Email tidak dapat diubah',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),

                const SizedBox(height: 16),
                const Text('Username',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: user?.username ?? '',
                  enabled: false,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
