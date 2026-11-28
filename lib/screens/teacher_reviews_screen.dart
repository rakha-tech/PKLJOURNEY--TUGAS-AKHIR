import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../services/teacher_mentor_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class TeacherReviewsScreen extends StatefulWidget {
  const TeacherReviewsScreen({
    super.key,
    this.isMentor = false,
  });

  final bool isMentor;

  @override
  State<TeacherReviewsScreen> createState() => _TeacherReviewsScreenState();
}

class _TeacherReviewsScreenState extends State<TeacherReviewsScreen> {
  final _service = TeacherMentorService();

  bool _isLoading = true;
  List<StudentJournalItem> _journals = [];
  String _filter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    setState(() => _isLoading = true);
    try {
      final list = await _service.fetchStudentsJournals();
      if (mounted) {
        setState(() {
          _journals = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat jurnal siswa: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _approve(StudentJournalItem item) async {
    try {
      final updated = await _service.approveJournal(item.entry.journalId);
      if (!mounted) return;
      setState(() {
        final idx = _journals.indexWhere(
          (i) => i.entry.journalId == updated.journalId,
        );
        if (idx != -1) {
          _journals[idx] = StudentJournalItem(
            entry: updated,
            student: item.student,
            companyName: item.companyName,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jurnal "${item.entry.title}" disetujui.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyetujui jurnal: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.maroon,
          ),
        );
      }
    }
  }

  Future<void> _reject(StudentJournalItem item) async {
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Tolak Jurnal'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Catatan penolakan',
              hintText: 'Contoh: Deskripsi kegiatan masih terlalu singkat',
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Catatan penolakan wajib diisi'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.maroon),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogCtx, noteCtrl.text.trim());
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    noteCtrl.dispose();

    if (note == null || !mounted) return;

    try {
      final updated = await _service.rejectJournal(
        item.entry.journalId,
        note: note,
      );
      if (!mounted) return;
      setState(() {
        final idx = _journals.indexWhere(
          (i) => i.entry.journalId == updated.journalId,
        );
        if (idx != -1) {
          _journals[idx] = StudentJournalItem(
            entry: updated,
            student: item.student,
            companyName: item.companyName,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jurnal "${item.entry.title}" ditolak.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menolak jurnal: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.maroon,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        _journals.where((j) => j.entry.status == ApprovalStatus.pending).length;
    final approvedCount = _journals
        .where((j) => j.entry.status == ApprovalStatus.approved)
        .length;
    final rejectedCount = _journals
        .where((j) => j.entry.status == ApprovalStatus.rejected)
        .length;

    final filtered = _journals.where((j) {
      return switch (_filter) {
        'Menunggu' => j.entry.status == ApprovalStatus.pending,
        'Disetujui' => j.entry.status == ApprovalStatus.approved,
        'Ditolak' => j.entry.status == ApprovalStatus.rejected,
        _ => true,
      };
    }).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadJournals,
        color: AppColors.maroon,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            PageHeading(
              title: widget.isMentor ? 'Review Jurnal PKL' : 'Jurnal Murid',
              subtitle: widget.isMentor
                  ? 'Periksa dan setujui laporan kegiatan harian siswa.'
                  : 'Pantau jurnal kegiatan dan dokumentasi siswa bimbingan.',
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterPill(
                    label: 'Semua (${_journals.length})',
                    selected: _filter == 'Semua',
                    onTap: () => setState(() => _filter = 'Semua'),
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Menunggu ($pendingCount)',
                    selected: _filter == 'Menunggu',
                    onTap: () => setState(() => _filter = 'Menunggu'),
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Disetujui ($approvedCount)',
                    selected: _filter == 'Disetujui',
                    onTap: () => setState(() => _filter = 'Disetujui'),
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Ditolak ($rejectedCount)',
                    selected: _filter == 'Ditolak',
                    onTap: () => setState(() => _filter = 'Ditolak'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SectionLabel(
              'Daftar jurnal',
              action: '${filtered.length} jurnal',
            ),

            if (_isLoading && _journals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.maroon),
                ),
              )
            else if (filtered.isEmpty)
              const WhiteCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.muted,
                      size: 38,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Belum ada jurnal kegiatan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Belum ada siswa bimbingan yang menulis jurnal.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...filtered.map((item) {
                final entry = item.entry;
                final (pillBg, pillText) = switch (entry.status) {
                  ApprovalStatus.approved => (
                      AppColors.paleGreen,
                      AppColors.green,
                    ),
                  ApprovalStatus.rejected => (
                      const Color(0xFFFDE8E8),
                      Colors.red.shade700,
                    ),
                  ApprovalStatus.pending => (
                      AppColors.paleAmber,
                      AppColors.amber,
                    ),
                };

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WhiteCard(
                    padding: 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.student.fullName,
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${entry.dateLabel} • ${entry.timeLabel} WIB',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InfoPill(
                              label: entry.statusLabel,
                              color: pillBg,
                              textColor: pillText,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          entry.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(entry.description),
                        if (entry.documentPhoto != null &&
                            entry.documentPhoto!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          PklPhotoThumbnail(
                            imageUrl: entry.documentPhoto!,
                            height: 140,
                            caption:
                                'Dokumentasi: ${entry.title} (${item.student.fullName})',
                          ),
                        ],
                        if (entry.status == ApprovalStatus.rejected &&
                            entry.rejectionNote != null &&
                            entry.rejectionNote!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Catatan penolakan: ${entry.rejectionNote}',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (widget.isMentor &&
                            entry.status == ApprovalStatus.pending) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _reject(item),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                    side: BorderSide(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: const Text('Tolak'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () => _approve(item),
                                  icon: const Icon(
                                    Icons.check_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Setujui Jurnal'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.maroon : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.maroon : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.ink,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
