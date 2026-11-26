import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class TeacherReviewItem {
  final String id;
  final String studentName;
  final String studentId;
  final String title;
  final String description;
  final String date;
  final String time;
  final String? imageUrl;
  final bool isReviewed;
  final String? teacherNote;

  const TeacherReviewItem({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.imageUrl,
    this.isReviewed = false,
    this.teacherNote,
  });

  TeacherReviewItem copyWith({
    bool? isReviewed,
    String? teacherNote,
  }) {
    return TeacherReviewItem(
      id: id,
      studentName: studentName,
      studentId: studentId,
      title: title,
      description: description,
      date: date,
      time: time,
      imageUrl: imageUrl,
      isReviewed: isReviewed ?? this.isReviewed,
      teacherNote: teacherNote ?? this.teacherNote,
    );
  }
}

class TeacherReviewsScreen extends StatefulWidget {
  const TeacherReviewsScreen({
    super.key,
    this.initialReviews,
    this.onMarkReviewed,
  });

  final List<TeacherReviewItem>? initialReviews;
  final void Function(String entryId, {String? teacherNote})? onMarkReviewed;

  @override
  State<TeacherReviewsScreen> createState() => _TeacherReviewsScreenState();
}

class _TeacherReviewsScreenState extends State<TeacherReviewsScreen> {
  String _filter = 'Semua';

  late final List<TeacherReviewItem> _reviews = widget.initialReviews != null
      ? List.from(widget.initialReviews!)
      : [
          const TeacherReviewItem(
            id: 'j-01',
            studentName: 'Frida Awan',
            studentId: '007812121134',
            title: 'Slicing UI dashboard guru pembimbing',
            description:
                'Menyusun komponen kartu ringkasan, tombol notifikasi, dan daftar murid bimbingan sesuai rancangan Figma.',
            date: '20 Nov 2026',
            time: '14.30',
            imageUrl:
                'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&q=80',
            isReviewed: false,
          ),
          const TeacherReviewItem(
            id: 'j-02',
            studentName: 'Frida Awan',
            studentId: '007812121134',
            title: 'Integrasi widget presensi mandiri',
            description:
                'Menambahkan status check-in, check-out, dan riwayat presensi harian siswa.',
            date: '19 Nov 2026',
            time: '16.05',
            imageUrl:
                'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&q=80',
            isReviewed: true,
            teacherNote: 'Bagus, teruskan dokumentasi kodenya.',
          ),
          const TeacherReviewItem(
            id: 'j-03',
            studentName: 'Muhammad Rakha',
            studentId: '008127658190',
            title: 'Review layout dan responsiveness halaman murid',
            description:
                'Menguji tampilan pada berbagai ukuran layar ponsel dan memperbaiki padding berlebih.',
            date: '18 Nov 2026',
            time: '15.10',
            imageUrl:
                'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800&q=80',
            isReviewed: false,
          ),
        ];

  void _openReviewDialog(BuildContext context, TeacherReviewItem item) {
    final noteController = TextEditingController(
      text: item.teacherNote ?? 'Kegiatan PKL terverifikasi dengan baik.',
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
                      Text('Tinjau & Beri Feedback',
                          style: Theme.of(sheetContext).textTheme.headlineSmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Murid: ${item.studentName} • ${item.title}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CATATAN / MASUKAN PEMBIMBING',
                    style: TextStyle(
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
                  ElevatedButton.icon(
                    onPressed: () {
                      final note = noteController.text.trim();
                      setState(() {
                        final index =
                            _reviews.indexWhere((r) => r.id == item.id);
                        if (index != -1) {
                          _reviews[index] = _reviews[index].copyWith(
                            isReviewed: true,
                            teacherNote: note.isEmpty ? null : note,
                          );
                        }
                      });
                      widget.onMarkReviewed?.call(
                        item.id,
                        teacherNote: note.isEmpty ? null : note,
                      );
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Jurnal dan catatan berhasil diverifikasi.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Setujui & Simpan Catatan'),
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
    final pendingCount = _reviews.where((review) => !review.isReviewed).length;

    final filtered = _reviews.where((r) {
      if (_filter == 'Menunggu') return !r.isReviewed;
      if (_filter == 'Selesai') return r.isReviewed;
      return true;
    }).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Tinjau Jurnal',
            subtitle: 'Evaluasi catatan kegiatan dan dokumentasi murid bimbingan.',
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
                const PklNotificationButton(unreadCount: 2),
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
              (review) => Padding(
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
                            label: review.isReviewed
                                ? 'Disetujui'
                                : 'Perlu Tinjauan',
                            color: review.isReviewed
                                ? AppColors.paleGreen
                                : AppColors.paleAmber,
                            textColor: review.isReviewed
                                ? AppColors.green
                                : AppColors.amber,
                            icon: review.isReviewed
                                ? Icons.check_circle_rounded
                                : Icons.schedule_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        review.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        review.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.ink,
                              height: 1.45,
                            ),
                      ),
                      if (review.imageUrl != null) ...[
                        const SizedBox(height: 10),
                        PklPhotoThumbnail(
                          imageUrl: review.imageUrl!,
                          height: 140,
                          caption:
                              'Dokumentasi: ${review.studentName} - ${review.title}',
                        ),
                      ],
                      if (review.teacherNote != null &&
                          review.teacherNote!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.paleGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.comment_rounded,
                                  color: AppColors.green, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Catatan Anda: "${review.teacherNote}"',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '${review.date} • ${review.time} WIB',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () =>
                                _openReviewDialog(context, review),
                            icon: Icon(
                              review.isReviewed
                                  ? Icons.edit_note_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 16,
                            ),
                            label: Text(
                              review.isReviewed
                                  ? 'Ubah Catatan'
                                  : 'Beri Masukan / Setujui',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.maroon,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
