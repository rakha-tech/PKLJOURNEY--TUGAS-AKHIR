import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/attendance_record.dart' show ApprovalStatus;
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _journalService = JournalService();

  bool _isLoading = true;
  final List<JournalEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    setState(() => _isLoading = true);
    try {
      final list = await _journalService.fetchMyJournals();
      if (mounted) {
        setState(() {
          _entries
            ..clear()
            ..addAll(list);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat jurnal: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openEntryForm() async {
    final entry = await showModalBottomSheet<JournalEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _JournalFormSheet(journalService: _journalService),
    );
    if (entry != null && mounted) {
      setState(() {
        _entries.insert(0, entry);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jurnal berhasil disimpan dan diunggah.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadJournals,
        color: AppColors.maroon,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            PageHeading(
              title: 'Jurnal kegiatan',
              subtitle: 'Simpan pengalaman dan hal baru yang kamu pelajari.',
              trailing: IconButton.filled(
                onPressed: _openEntryForm,
                tooltip: 'Tambah jurnal',
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: AppColors.paleAmber,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cream),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: AppColors.amber),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Catatan kecil hari ini bisa jadi bekal besar untuk masa depan.',
                      style: TextStyle(
                        color: AppColors.taupe,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SectionLabel(
              'Catatanmu',
              action: '${_entries.length} kegiatan',
            ),
            if (_isLoading && _entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.maroon),
                ),
              )
            else if (_entries.isEmpty)
              WhiteCard(
                child: Column(
                  children: [
                    const Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.maroon,
                      size: 38,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada jurnal',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Mulai catat pengalaman PKL pertamamu hari ini.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _openEntryForm,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Tulis jurnal'),
                    ),
                  ],
                ),
              )
            else
              ..._entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _JournalCard(entry: entry),
                ),
              ),
            const SizedBox(height: 5),
            OutlinedButton.icon(
              onPressed: _openEntryForm,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah catatan kegiatan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.maroon,
                side: const BorderSide(color: AppColors.maroon),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final (pillBg, pillText) = switch (entry.status) {
      ApprovalStatus.approved => (AppColors.paleGreen, AppColors.green),
      ApprovalStatus.rejected => (const Color(0xFFFDE8E8), Colors.red.shade700),
      ApprovalStatus.pending => (AppColors.paleAmber, AppColors.amber),
    };

    return WhiteCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.dateLabel,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InfoPill(
                label: entry.statusLabel,
                color: pillBg,
                textColor: pillText,
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(entry.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(entry.description),
          if (entry.status == ApprovalStatus.rejected &&
              entry.rejectionNote != null &&
              entry.rejectionNote!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Catatan penolakan: ${entry.rejectionNote}',
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (entry.documentPhoto != null &&
              entry.documentPhoto!.isNotEmpty) ...[
            const SizedBox(height: 12),
            PklPhotoThumbnail(
              imageUrl: entry.documentPhoto!,
              height: 140,
              caption: 'Foto Dokumentasi Kegiatan: ${entry.title}',
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: AppColors.muted,
              ),
              const SizedBox(width: 5),
              Text(
                'Ditambahkan pukul ${entry.timeLabel}',
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JournalFormSheet extends StatefulWidget {
  const _JournalFormSheet({required this.journalService});

  final JournalService journalService;

  @override
  State<_JournalFormSheet> createState() => _JournalFormSheetState();
}

class _JournalFormSheetState extends State<_JournalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  File? _selectedPhotoFile;
  bool _photoError = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (xFile == null || !mounted) return;
    setState(() {
      _selectedPhotoFile = File(xFile.path);
      _photoError = false;
    });
  }

  void _choosePhoto() {
    showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (pickerContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Upload Bukti Foto Kegiatan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ambil foto langsung atau unggah dari galeri untuk melengkapi jurnal:',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pop(pickerContext, ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded, size: 18),
                      label: const Text('Buka Kamera'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pop(pickerContext, ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_rounded, size: 18),
                      label: const Text('Pilih Galeri'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.line),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((source) {
      if (source != null) {
        _pickImage(source);
      }
    });
  }

  Future<void> _save() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (_selectedPhotoFile == null) {
      setState(() {
        _photoError = true;
      });
    }

    if (!isFormValid || _selectedPhotoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wajib melampirkan foto dokumentasi kegiatan!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.maroon,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final entry = await widget.journalService.addJournal(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        photoFile: _selectedPhotoFile!,
      );
      if (mounted) {
        Navigator.of(context).pop(entry);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan jurnal: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.maroon,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 19),
                Text(
                  'Tulis jurnal baru',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 5),
                const Text('Apa yang kamu kerjakan atau pelajari hari ini?'),
                const SizedBox(height: 19),
                const _FormLabel('JUDUL KEGIATAN'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _titleController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Membuat halaman profil',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Judul kegiatan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 15),
                const _FormLabel('CERITA KEGIATAN'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_isSaving,
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText:
                        'Tuliskan ringkasan kegiatan dan hal yang kamu pelajari...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value == null || value.trim().length < 8
                      ? 'Ceritakan kegiatan minimal 8 karakter'
                      : null,
                ),
                const SizedBox(height: 15),
                const _FormLabel('FOTO DOKUMENTASI KEGIATAN *'),
                const SizedBox(height: 7),
                InkWell(
                  onTap: _isSaving ? null : _choosePhoto,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _photoError
                          ? const Color(0xFFFDE8E8)
                          : _selectedPhotoFile != null
                              ? AppColors.paleGreen
                              : AppColors.paper,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _photoError
                            ? Colors.red
                            : _selectedPhotoFile != null
                                ? AppColors.green
                                : AppColors.line,
                        width: 1.5,
                      ),
                    ),
                    child: _selectedPhotoFile != null
                        ? Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedPhotoFile!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded,
                                            size: 16, color: AppColors.green),
                                        SizedBox(width: 4),
                                        Text(
                                          'Foto Terlampir',
                                          style: TextStyle(
                                            color: AppColors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Ketuk untuk mengganti foto',
                                      style: TextStyle(
                                          fontSize: 11, color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.edit_outlined,
                                  size: 18, color: AppColors.taupe),
                            ],
                          )
                        : const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    color: AppColors.maroon, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Upload Bukti Foto Kegiatan (Wajib)',
                                  style: TextStyle(
                                    color: AppColors.maroon,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                if (_photoError) ...[
                  const SizedBox(height: 5),
                  const Text(
                    'Foto kegiatan wajib diupload untuk bukti pengerjaan tugas PKL',
                    style: TextStyle(color: Colors.red, fontSize: 11),
                  ),
                ],
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_isSaving ? 'Mengunggah...' : 'Simpan jurnal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.taupe,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}
