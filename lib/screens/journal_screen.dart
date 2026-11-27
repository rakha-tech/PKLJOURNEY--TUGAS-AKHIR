import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.tag,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String tag;
  final String? imageUrl;
}

class JournalScreen extends StatefulWidget {
  const JournalScreen({
    super.key,
    this.entries = const [
      JournalEntry(
        id: 'journal-001',
        title: 'Orientasi lingkungan kerja',
        description:
            'Mengenal tim, aturan kerja, dan alur kegiatan di tempat PKL.',
        date: '26 November 2026',
        time: '08.15',
        tag: 'Orientasi',
        imageUrl: PklPhotoPresets.meeting,
      ),
      JournalEntry(
        id: 'journal-002',
        title: 'Membuat halaman profil',
        description: 'Menyusun tampilan halaman profil dan mempelajari widget dasar Flutter.',
        date: '25 November 2026',
        time: '13.40',
        tag: 'Proyek',
        imageUrl: PklPhotoPresets.uiDesign,
      ),
      JournalEntry(
        id: 'journal-003',
        title: 'Belajar Git dan version control',
        description: 'Mencoba membuat branch dan mencatat perubahan kode menggunakan Git.',
        date: '24 November 2026',
        time: '10.05',
        tag: 'Pembelajaran',
        imageUrl: PklPhotoPresets.coding,
      ),
    ],
    required this.onAddEntry,
  });

  final List<JournalEntry> entries;
  final ValueChanged<JournalEntry> onAddEntry;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  Future<void> _openEntryForm() async {
    final entry = await showModalBottomSheet<JournalEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _JournalFormSheet(),
    );
    if (entry != null) widget.onAddEntry(entry);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            action: '${widget.entries.length} kegiatan',
          ),
          if (widget.entries.isEmpty)
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
            ...widget.entries.map(
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
          const SizedBox(height: 14),
          const Text(
            'Jurnal tersimpan selama aplikasi demo terbuka.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.date,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InfoPill(
                label: entry.tag,
                color: AppColors.cream,
                textColor: AppColors.taupe,
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(entry.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(entry.description),
          if (entry.imageUrl != null) ...[
            const SizedBox(height: 12),
            PklPhotoThumbnail(
              imageUrl: entry.imageUrl!,
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
                'Ditambahkan pukul ${entry.time}',
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
  const _JournalFormSheet();

  @override
  State<_JournalFormSheet> createState() => _JournalFormSheetState();
}

class _JournalFormSheetState extends State<_JournalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _tag = 'Kegiatan';
  String? _selectedPhotoUrl;
  bool _photoError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _choosePhoto() {
    showModalBottomSheet<String>(
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
                      onPressed: () {
                        Navigator.pop(pickerContext, PklPhotoPresets.coding);
                      },
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
                      onPressed: () {
                        Navigator.pop(pickerContext, PklPhotoPresets.uiDesign);
                      },
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
    ).then((chosen) {
      if (chosen != null) {
        setState(() {
          _selectedPhotoUrl = chosen;
          _photoError = false;
        });
      }
    });
  }

  void _save() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (_selectedPhotoUrl == null) {
      setState(() {
        _photoError = true;
      });
    }

    if (!isFormValid || _selectedPhotoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wajib melampirkan foto dokumentasi kegiatan!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.maroon,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final entry = JournalEntry(
      id: now.microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: currentDateLabel(),
      time:
          '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}',
      tag: _tag,
      imageUrl: _selectedPhotoUrl,
    );
    Navigator.of(context).pop(entry);
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
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan ringkasan kegiatan dan hal yang kamu pelajari...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value == null || value.trim().length < 8
                      ? 'Ceritakan kegiatan minimal 8 karakter'
                      : null,
                ),
                const SizedBox(height: 15),
                const _FormLabel('KATEGORI'),
                const SizedBox(height: 7),
                DropdownButtonFormField<String>(
                  value: _tag,
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem(
                      value: 'Kegiatan',
                      child: Text('Kegiatan'),
                    ),
                    DropdownMenuItem(
                      value: 'Pembelajaran',
                      child: Text('Pembelajaran'),
                    ),
                    DropdownMenuItem(
                      value: 'Orientasi',
                      child: Text('Orientasi'),
                    ),
                    DropdownMenuItem(value: 'Proyek', child: Text('Proyek')),
                  ],
                  onChanged: (value) =>
                      setState(() => _tag = value ?? 'Kegiatan'),
                ),
                const SizedBox(height: 15),
                const _FormLabel('FOTO DOKUMENTASI KEGIATAN *'),
                const SizedBox(height: 7),
                InkWell(
                  onTap: _choosePhoto,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _photoError
                          ? const Color(0xFFFDE8E8)
                          : _selectedPhotoUrl != null
                              ? AppColors.paleGreen
                              : AppColors.paper,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _photoError
                            ? Colors.red
                            : _selectedPhotoUrl != null
                                ? AppColors.green
                                : AppColors.line,
                        width: 1.5,
                      ),
                    ),
                    child: _selectedPhotoUrl != null
                        ? Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _selectedPhotoUrl!,
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
                  onPressed: _save,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Simpan jurnal'),
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
