import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../services/teacher_mentor_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({
    super.key,
    this.isIduka = false,
    this.idukaName = 'Pembimbing IDUKA',
  });

  final bool isIduka;
  final String idukaName;

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  final _service = TeacherMentorService();

  bool _isLoading = true;
  List<StudentAttendanceItem> _items = [];
  String _filter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadAttendances();
  }

  Future<void> _loadAttendances() async {
    setState(() => _isLoading = true);
    try {
      final list = await _service.fetchStudentsAttendances();
      if (mounted) {
        setState(() {
          _items = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat presensi siswa: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime? t) {
    if (t == null) return '--.--';
    return '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _approve(StudentAttendanceItem item) async {
    try {
      final updated = await _service.approveAttendance(item.record.attendanceId);
      if (!mounted) return;
      setState(() {
        final idx = _items.indexWhere(
          (i) => i.record.attendanceId == updated.attendanceId,
        );
        if (idx != -1) {
          _items[idx] = StudentAttendanceItem(
            record: updated,
            student: item.student,
            companyName: item.companyName,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Presensi ${item.student.fullName} disetujui.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyetujui presensi: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.maroon,
          ),
        );
      }
    }
  }

  Future<void> _reject(StudentAttendanceItem item) async {
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Tolak Presensi'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Alasan penolakan',
              hintText: 'Contoh: Foto tidak sesuai lokasi PKL',
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Alasan penolakan wajib diisi'
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
      final updated = await _service.rejectAttendance(
        item.record.attendanceId,
        note: note,
      );
      if (!mounted) return;
      setState(() {
        final idx = _items.indexWhere(
          (i) => i.record.attendanceId == updated.attendanceId,
        );
        if (idx != -1) {
          _items[idx] = StudentAttendanceItem(
            record: updated,
            student: item.student,
            companyName: item.companyName,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Presensi ${item.student.fullName} ditolak.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menolak presensi: $e'),
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
        _items.where((i) => i.record.status == ApprovalStatus.pending).length;
    final approvedCount =
        _items.where((i) => i.record.status == ApprovalStatus.approved).length;
    final rejectedCount =
        _items.where((i) => i.record.status == ApprovalStatus.rejected).length;

    final filtered = _items.where((i) {
      return switch (_filter) {
        'Menunggu' => i.record.status == ApprovalStatus.pending,
        'Disetujui' => i.record.status == ApprovalStatus.approved,
        'Ditolak' => i.record.status == ApprovalStatus.rejected,
        _ => true,
      };
    }).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadAttendances,
        color: AppColors.maroon,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            PageHeading(
              title: widget.isIduka ? 'Persetujuan Presensi' : 'Presensi Murid',
              subtitle: widget.isIduka
                  ? 'Verifikasi kehadiran harian siswa PKL (${widget.idukaName}).'
                  : 'Pantau catatan kehadiran dan status persetujuan IDUKA.',
            ),

            // Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterTab(
                    label: 'Semua (${_items.length})',
                    selected: _filter == 'Semua',
                    onTap: () => setState(() => _filter = 'Semua'),
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: 'Menunggu ($pendingCount)',
                    selected: _filter == 'Menunggu',
                    onTap: () => setState(() => _filter = 'Menunggu'),
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: 'Disetujui ($approvedCount)',
                    selected: _filter == 'Disetujui',
                    onTap: () => setState(() => _filter = 'Disetujui'),
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: 'Ditolak ($rejectedCount)',
                    selected: _filter == 'Ditolak',
                    onTap: () => setState(() => _filter = 'Ditolak'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SectionLabel(
              'Daftar presensi',
              action: '${filtered.length} catatan',
            ),

            if (_isLoading && _items.isEmpty)
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
                      Icons.fact_check_outlined,
                      color: AppColors.muted,
                      size: 38,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Belum ada data presensi',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Belum ada siswa bimbingan yang mencatat presensi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...filtered.map((item) {
                final rec = item.record;
                final (pillBg, pillText) = switch (rec.status) {
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${rec.shortWeekday}, ${rec.shortDate} • ${item.companyName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InfoPill(
                              label: rec.statusLabel,
                              color: pillBg,
                              textColor: pillText,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Masuk: ${_formatTime(rec.checkIn)} WIB',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Pulang: ${_formatTime(rec.checkOut)} WIB',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (rec.checkInPhoto != null &&
                            rec.checkInPhoto!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          PklPhotoThumbnail(
                            imageUrl: rec.checkInPhoto!,
                            height: 130,
                            caption:
                                'Foto Masuk: ${item.student.fullName} (${rec.shortDate})',
                          ),
                        ],
                        if (rec.checkOutPhoto != null &&
                            rec.checkOutPhoto!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          PklPhotoThumbnail(
                            imageUrl: rec.checkOutPhoto!,
                            height: 130,
                            caption:
                                'Foto Pulang: ${item.student.fullName} (${rec.shortDate})',
                          ),
                        ],
                        if (rec.status == ApprovalStatus.rejected &&
                            rec.rejectionNote != null &&
                            rec.rejectionNote!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Catatan penolakan: ${rec.rejectionNote}',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (widget.isIduka &&
                            rec.status == ApprovalStatus.pending) ...[
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
                                  label: const Text('Setujui Presensi'),
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

class _FilterTab extends StatelessWidget {
  const _FilterTab({
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
