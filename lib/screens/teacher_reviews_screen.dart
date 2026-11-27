import 'package:flutter/material.dart';

import '../models/pkl_models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class TeacherReviewsScreen extends StatefulWidget {
  const TeacherReviewsScreen({
    super.key,
    this.isIduka = false,
    this.reviewerName = 'Pembimbing',
    this.initialReviews,
    this.onReviewTeacher,
    this.onValidateMentor,
    this.notifications,
    this.unreadNotificationCount = 2,
    this.onNotificationsOpened,
  });

  final bool isIduka;
  final String reviewerName;
  final List<PklJournalEntry>? initialReviews;
  final void Function(String journalId, {String? note})? onReviewTeacher;
  final void Function(String journalId, {required bool approve, String? note})?
      onValidateMentor;
  final List<PklNotificationItem>? notifications;
  final int unreadNotificationCount;
  final VoidCallback? onNotificationsOpened;

  @override
  State<TeacherReviewsScreen> createState() => _TeacherReviewsScreenState();
}

class _TeacherReviewsScreenState extends State<TeacherReviewsScreen> {
  String _filter = 'Semua';

  late List<PklJournalEntry> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = widget.initialReviews != null
        ? List.from(widget.initialReviews!)
        : [
            const PklJournalEntry(
              id: 'j-01',
              studentName: 'Ahmad Fauzi',
              studentAccountId: '0054321980',
              title: 'Slicing UI dashboard guru pembimbing',
              description:
                  'Menyusun komponen kartu ringkasan, tombol notifikasi, dan daftar murid bimbingan sesuai rancangan.',
              date: '26 Nov 2026',
              time: '14.30',
              tag: 'Proyek',
              imageUrl: PklPhotoPresets.meeting,
            ),
            const PklJournalEntry(
              id: 'j-02',
              studentName: 'Siti Nurhaliza',
              studentAccountId: '0054321981',
              title: 'Integrasi widget presensi mandiri',
              description:
                  'Menambahkan status check-in, check-out, dan riwayat presensi harian siswa.',
              date: '25 Nov 2026',
              time: '16.05',
              tag: 'Proyek',
              imageUrl: PklPhotoPresets.coding,
              isReviewedByTeacher: true,
              teacherNote: 'Bagus, teruskan dokumentasi kodenya.',
              teacherName: 'Budi Santoso, M.Pd.',
              isValidatedByMentor: true,
              mentorNote: 'Sesuai standar tim.',
              mentorName: 'Hendro Prasetyo, S.T.',
            ),
          ];
  }

  @override
  void didUpdateWidget(covariant TeacherReviewsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialReviews != null &&
        widget.initialReviews != oldWidget.initialReviews) {
      _reviews = List.from(widget.initialReviews!);
    }
  }

  bool _isDoneForCurrentRole(PklJournalEntry item) {
    return widget.isIduka
        ? (item.isValidatedByMentor || item.isRejectedByMentor)
        : item.isReviewedByTeacher;
  }

  void _openReviewDialog(BuildContext context, PklJournalEntry item) {
    final existingNote = widget.isIduka ? item.mentorNote : item.teacherNote;
    final noteController = TextEditingController(
      text: existingNote ?? 'Kegiatan PKL terlaksana dengan baik.',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottom = MediaQuery.viewInsetsOf(sheetContext).bottom;
        return Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.rate_review_rounded,
                          color: AppColors.maroon, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.isIduka
                              ? 'Validasi & Masukan Mentor'
                              : 'Tinjau & Beri Masukan',
                          style: Theme.of(sheetContext).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Murid: ${item.studentName} • ${item.title}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  if (item.imageBytes != null || item.imageUrl != null) ...[
                    const SizedBox(height: 12),
                    PklPhotoThumbnail(
                      imageBytes: item.imageBytes,
                      imageUrl: item.imageUrl,
                      height: 130,
                      caption: item.title,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    widget.isIduka
                        ? 'MASUKAN / CATATAN MENTOR IDUKA'
                        : 'CATATAN / MASUKAN GURU PEMBIMBING',
                    style: const TextStyle(
                      color: AppColors.taupe,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText:
                          'Tuliskan apresiasi, masukan, atau arahan untuk murid...',
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (widget.isIduka)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final note = noteController.text.trim();
                              setState(() {
                                final idx =
                                    _reviews.indexWhere((r) => r.id == item.id);
                                if (idx != -1) {
                                  _reviews[idx] = _reviews[idx].copyWith(
                                    isValidatedByMentor: false,
                                    isRejectedByMentor: true,
                                    mentorNote: note.isEmpty ? null : note,
                                    mentorName: widget.reviewerName,
                                  );
                                }
                              });
                              widget.onValidateMentor?.call(
                                item.id,
                                approve: false,
                                note: note,
                              );
                              Navigator.pop(sheetContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Jurnal ditolak beserta catatan masukan.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('Tolak'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.maroon,
                              side: const BorderSide(color: AppColors.maroon),
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final note = noteController.text.trim();
                              setState(() {
                                final idx =
                                    _reviews.indexWhere((r) => r.id == item.id);
                                if (idx != -1) {
                                  _reviews[idx] = _reviews[idx].copyWith(
                                    isValidatedByMentor: true,
                                    isRejectedByMentor: false,
                                    mentorNote: note.isEmpty ? null : note,
                                    mentorName: widget.reviewerName,
                                  );
                                }
                              });
                              widget.onValidateMentor?.call(
                                item.id,
                                approve: true,
                                note: note,
                              );
                              Navigator.pop(sheetContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Jurnal disetujui dan masukan tersimpan.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle_rounded),
                            label: const Text('Setujui & Simpan'),
                          ),
                        ),
                      ],
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        final note = noteController.text.trim();
                        setState(() {
                          final idx =
                              _reviews.indexWhere((r) => r.id == item.id);
                          if (idx != -1) {
                            _reviews[idx] = _reviews[idx].copyWith(
                              isReviewedByTeacher: true,
                              teacherNote: note.isEmpty ? null : note,
                              teacherName: widget.reviewerName,
                            );
                          }
                        });
                        widget.onReviewTeacher?.call(
                          item.id,
                          note: note.isEmpty ? null : note,
                        );
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Jurnal dan masukan berhasil disimpan.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Simpan Masukan Guru'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        _reviews.where((review) => !_isDoneForCurrentRole(review)).length;

    final filtered = _reviews.where((r) {
      if (_filter == 'Menunggu') return !_isDoneForCurrentRole(r);
      if (_filter == 'Selesai') return _isDoneForCurrentRole(r);
      return true;
    }).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: widget.isIduka ? 'Validasi Jurnal' : 'Tinjau Jurnal',
            subtitle: widget.isIduka
                ? 'Validasi kegiatan dan beri masukan jurnal murid PKL.'
                : 'Evaluasi catatan kegiatan dan dokumentasi murid bimbingan.',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoPill(
                  label: '$pendingCount menunggu',
                  color: pendingCount == 0
                      ? AppColors.paleGreen
                      : AppColors.paleAmber,
                  textColor:
                      pendingCount == 0 ? AppColors.green : AppColors.amber,
                  icon: Icons.rate_review_outlined,
                ),
                const SizedBox(width: 6),
                PklNotificationButton(
                  unreadCount: widget.unreadNotificationCount,
                  notifications: widget.notifications,
                  onOpened: widget.onNotificationsOpened,
                ),
              ],
            ),
          ),

          // Filter bar
          Row(
            children: ['Semua', 'Menunggu', 'Selesai'].map((f) {
              final isSelected = _filter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: AppColors.maroon,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.ink,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.maroon : AppColors.line,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          if (filtered.isEmpty)
            const WhiteCard(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.checklist_rounded,
                        color: AppColors.green, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Tidak ada jurnal pada kategori ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.ink, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filtered.map(
              (review) {
                final done = _isDoneForCurrentRole(review);
                final roleNote =
                    widget.isIduka ? review.mentorNote : review.teacherNote;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: WhiteCard(
                    padding: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.cream,
                              child: Text(
                                review.studentName.isEmpty
                                    ? '?'
                                    : review.studentName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.maroon,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                review.studentName,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            InfoPill(
                              label: widget.isIduka
                                  ? (review.isValidatedByMentor
                                      ? 'Disetujui Mentor'
                                      : review.isRejectedByMentor
                                          ? 'Ditolak Mentor'
                                          : 'Perlu Validasi')
                                  : (review.isReviewedByTeacher
                                      ? 'Ditinjau Guru'
                                      : 'Perlu Tinjauan'),
                              color: done
                                  ? (review.isRejectedByMentor && widget.isIduka
                                      ? AppColors.cream
                                      : AppColors.paleGreen)
                                  : AppColors.paleAmber,
                              textColor: done
                                  ? (review.isRejectedByMentor && widget.isIduka
                                      ? AppColors.maroon
                                      : AppColors.green)
                                  : AppColors.amber,
                              icon: done
                                  ? Icons.check_circle_rounded
                                  : Icons.schedule_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          review.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          review.description,
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12),
                        ),
                        if (review.imageBytes != null ||
                            review.imageUrl != null) ...[
                          const SizedBox(height: 12),
                          PklPhotoThumbnail(
                            imageBytes: review.imageBytes,
                            imageUrl: review.imageUrl,
                            height: 150,
                            caption:
                                '${review.studentName} • ${review.title}',
                          ),
                        ],
                        if (roleNote != null && roleNote.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.paper,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${widget.isIduka ? "Masukan Mentor" : "Catatan Guru"}: $roleNote',
                              style: const TextStyle(
                                color: AppColors.taupe,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${review.date} • ${review.time} WIB',
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 10),
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () =>
                                  _openReviewDialog(context, review),
                              icon: Icon(
                                done
                                    ? Icons.edit_note_rounded
                                    : Icons.rate_review_rounded,
                                size: 17,
                              ),
                              label: Text(
                                done
                                    ? 'Ubah Masukan'
                                    : (widget.isIduka
                                        ? 'Validasi & Masukan'
                                        : 'Tinjau & Beri Catatan'),
                                style: const TextStyle(fontSize: 11),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: done
                                    ? AppColors.paper
                                    : AppColors.maroon,
                                foregroundColor:
                                    done ? AppColors.ink : Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
