import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/pkl_models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({
    super.key,
    this.student,
    this.entries = const [
      PklJournalEntry(
        id: 'journal-001',
        studentAccountId: '0054321980',
        studentName: 'Ahmad Fauzi',
        title: 'Orientasi lingkungan kerja',
        description:
            'Mengenal tim, aturan kerja, dan alur kegiatan di tempat PKL.',
        date: '26 November 2026',
        time: '08.15',
        tag: 'Orientasi',
        imageUrl: PklPhotoPresets.meeting,
        isValidatedByMentor: true,
        mentorName: 'Hendro Prasetyo, S.T.',
        mentorNote: 'Adaptasi sangat baik, pertahankan komunikasi tim.',
      ),
      PklJournalEntry(
        id: 'journal-002',
        studentAccountId: '0054321980',
        studentName: 'Ahmad Fauzi',
        title: 'Membuat halaman profil',
        description:
            'Menyusun tampilan halaman profil dan mempelajari widget dasar Flutter.',
        date: '25 November 2026',
        time: '13.40',
        tag: 'Proyek',
        imageUrl: PklPhotoPresets.coding,
        isReviewedByTeacher: true,
        teacherName: 'Budi Santoso, M.Pd.',
        teacherNote: 'Struktur kode sudah rapi.',
      ),
    ],
    required this.onAddEntry,
  });

  final PklUser? student;
  final List<PklJournalEntry> entries;
  final ValueChanged<PklJournalEntry> onAddEntry;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  Future<void> _openEntryForm() async {
    final entry = await showModalBottomSheet<PklJournalEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _JournalFormSheet(student: widget.student),
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
            subtitle: 'Simpan kegiatan, foto dari perangkat, dan pantau validasi.',
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
                    'Lampirkan foto kegiatan dari perangkatmu agar Mentor IDUKA dan Guru Pembimbing dapat memvalidasi dan memberi masukan.',
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
        ],
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.entry});

  final PklJournalEntry entry;

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
          const SizedBox(height: 10),
          Text(entry.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(entry.description),
          if (entry.imageBytes != null || entry.imageUrl != null) ...[
            const SizedBox(height: 12),
            PklPhotoThumbnail(
              imageBytes: entry.imageBytes,
              imageUrl: entry.imageUrl,
              height: 145,
              caption: entry.title,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              InfoPill(
                label: entry.isValidatedByMentor
                    ? 'Disetujui Mentor'
                    : entry.isRejectedByMentor
                        ? 'Ditolak Mentor'
                        : 'Menunggu Mentor',
                color: entry.isValidatedByMentor
                    ? AppColors.paleGreen
                    : entry.isRejectedByMentor
                        ? AppColors.cream
                        : AppColors.paleAmber,
                textColor: entry.isValidatedByMentor
                    ? AppColors.green
                    : entry.isRejectedByMentor
                        ? AppColors.maroon
                        : AppColors.amber,
                icon: entry.isValidatedByMentor
                    ? Icons.verified_rounded
                    : entry.isRejectedByMentor
                        ? Icons.cancel_rounded
                        : Icons.hourglass_top_rounded,
              ),
              InfoPill(
                label: entry.isReviewedByTeacher
                    ? 'Ditinjau Guru'
                    : 'Menunggu Guru',
                color: entry.isReviewedByTeacher
                    ? AppColors.paleGreen
                    : AppColors.paper,
                textColor: entry.isReviewedByTeacher
                    ? AppColors.green
                    : AppColors.muted,
                icon: entry.isReviewedByTeacher
                    ? Icons.check_circle_rounded
                    : Icons.schedule_rounded,
              ),
            ],
          ),
          if (entry.mentorNote != null && entry.mentorNote!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _NoteBox(
              author: 'Masukan Mentor (${entry.mentorName ?? "IDUKA"})',
              note: entry.mentorNote!,
              color: entry.isRejectedByMentor
                  ? AppColors.cream
                  : AppColors.paleGreen,
              accent: entry.isRejectedByMentor
                  ? AppColors.maroon
                  : AppColors.green,
            ),
          ],
          if (entry.teacherNote != null && entry.teacherNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _NoteBox(
              author: 'Catatan Guru (${entry.teacherName ?? "Pembimbing"})',
              note: entry.teacherNote!,
              color: AppColors.paper,
              accent: AppColors.taupe,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: AppColors.muted,
              ),
              const SizedBox(width: 5),
              Text(
                'Ditambahkan pukul ${entry.time} WIB',
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox({
    required this.author,
    required this.note,
    required this.color,
    required this.accent,
  });

  final String author;
  final String note;
  final Color color;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            note,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.ink,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalFormSheet extends StatefulWidget {
  const _JournalFormSheet({this.student});
  final PklUser? student;

  @override
  State<_JournalFormSheet> createState() => _JournalFormSheetState();
}

class _JournalFormSheetState extends State<_JournalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _tag = 'Kegiatan';
  Uint8List? _photoBytes;
  String? _photoName;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final now = DateTime.now();
    final entry = PklJournalEntry(
      id: now.microsecondsSinceEpoch.toString(),
      studentAccountId: widget.student?.accountId ?? '0054321980',
      studentName: widget.student?.name ?? 'Ahmad Fauzi',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: currentDateLabel(),
      time:
          '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}',
      tag: _tag,
      imageBytes: _photoBytes,
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
                    hintText:
                        'Tuliskan ringkasan kegiatan dan hal yang kamu pelajari...',
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
                const _FormLabel('FOTO KEGIATAN (DARI PERANGKAT)'),
                const SizedBox(height: 7),
                DevicePhotoPickerBox(
                  selectedBytes: _photoBytes,
                  selectedFileName: _photoName,
                  title: 'Upload Foto Kegiatan Jurnal',
                  subtitle: 'Pilih foto dokumentasi dari perangkat Anda.',
                  onPhotoSelected: (bytes, name) {
                    setState(() {
                      _photoBytes = bytes;
                      _photoName = name;
                    });
                  },
                ),
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
