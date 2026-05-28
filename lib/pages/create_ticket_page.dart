// lib/pages/create_ticket_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/ticket_store.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'Jaringan / Internet';
  String _selectedPriority = 'Medium';

  /// Stores picked image/file paths
  final List<_Attachment> _attachments = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Jaringan / Internet',
    'Printer / Scanner',
    'Komputer / Hardware',
    'Sistem / Software',
    'Email / Akun',
    'Lainnya',
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'label': 'Low', 'color': Colors.green, 'icon': Icons.arrow_downward},
    {'label': 'Medium', 'color': Colors.orange, 'icon': Icons.remove},
    {'label': 'High', 'color': Colors.red, 'icon': Icons.arrow_upward},
  ];

  // ── Attachment helpers ─────────────────────────────────────

  Future<void> _pickFromCamera() async {
    Navigator.pop(context);
    try {
      final XFile? photo =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (photo != null) {
        setState(() => _attachments.add(_Attachment(path: photo.path, isImage: true)));
      }
    } catch (e) {
      _showError('Tidak dapat mengakses kamera: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    Navigator.pop(context);
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);
      if (images.isNotEmpty) {
        setState(() {
          for (final img in images) {
            _attachments.add(_Attachment(path: img.path, isImage: true));
          }
        });
      }
    } catch (e) {
      _showError('Tidak dapat mengakses galeri: $e');
    }
  }

  /// For non-image files we simulate (image_picker doesn't support general files;
  /// in production swap with file_picker package)
  Future<void> _pickFile() async {
    Navigator.pop(context);
    _showError(
        'Untuk memilih file dokumen, gunakan package file_picker.\nSaat ini hanya foto yang didukung.');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  // ── Submit ─────────────────────────────────────────────────

  void _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // slight delay UX

    final user = AuthService().currentUser;
    TicketStore().createTicket(
      userId: user?.id ?? '2',
      userName: user?.name ?? 'John Doe',
      title: _titleCtrl.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      description: _descCtrl.text.trim(),
      attachments: _attachments.map((a) => a.path).toList(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.statusResolved.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.statusResolved, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tiket Berhasil Dibuat!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tiket Anda telah dikirim dan akan segera diproses oleh tim helpdesk.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondaryLight, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pushReplacementNamed(context, '/tickets');
                },
                child: const Text('Lihat Tiket Saya'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tambah Lampiran',
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  color: AppColors.primary,
                  onTap: _pickFromCamera,
                ),
                _buildAttachOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  color: AppColors.accent,
                  onTap: _pickFromGallery,
                ),
                _buildAttachOption(
                  icon: Icons.insert_drive_file_rounded,
                  label: 'File',
                  color: AppColors.statusInProgress,
                  onTap: _pickFile,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Tiket Baru'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.statusOpen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.statusOpen.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppColors.statusOpen, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Isi formulir dengan lengkap agar tiket dapat ditangani lebih cepat.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.statusOpen),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Judul
              _buildLabel('Judul Keluhan *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'Deskripsi singkat masalah Anda',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Kategori
              _buildLabel('Kategori *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 16),

              // Prioritas
              _buildLabel('Prioritas *'),
              const SizedBox(height: 8),
              Row(
                children: _priorities.asMap().entries.map((entry) {
                  final p = entry.value;
                  final isLast = entry.key == _priorities.length - 1;
                  final isSelected = _selectedPriority == p['label'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedPriority = p['label']),
                      child: Container(
                        margin: EdgeInsets.only(right: isLast ? 0 : 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (p['color'] as Color).withOpacity(0.15)
                              : Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? p['color'] as Color
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(p['icon'] as IconData,
                                color: p['color'] as Color, size: 20),
                            const SizedBox(height: 4),
                            Text(
                              p['label'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: p['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Deskripsi
              _buildLabel('Deskripsi Detail *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText:
                      'Jelaskan masalah secara detail, kapan terjadi, dampaknya, dsb.',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Lampiran
              _buildLabel('Lampiran (Opsional)'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showAttachmentOptions,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_file_rounded,
                          color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Tambah Lampiran (Foto / File)',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Preview lampiran
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _attachments.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final att = _attachments[i];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: att.isImage
                                ? Image.file(
                                    File(att.path),
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _fileThumb(att.path),
                                  )
                                : _fileThumb(att.path),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => _removeAttachment(i),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Text(
                  '${_attachments.length} lampiran dipilih',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight),
                ),
              ],

              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTicket,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Kirim Tiket'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fileThumb(String path) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              color: AppColors.primary, size: 28),
          const SizedBox(height: 4),
          Text(
            path.split('/').last.split('\\').last,
            style:
                const TextStyle(fontSize: 9, color: AppColors.primary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      );

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}

class _Attachment {
  final String path;
  final bool isImage;
  _Attachment({required this.path, required this.isImage});
}