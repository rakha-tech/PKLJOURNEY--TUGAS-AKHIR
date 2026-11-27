import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/attendance_record.dart';
import '../services/attendance_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    this.idukaMentorName = 'Pembimbing IDUKA',
    this.onAttendanceAction,
  });

  final String idukaMentorName;
  final VoidCallback? onAttendanceAction;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _attendanceService = AttendanceService();
  final _picker = ImagePicker();

  bool _isLoading = true;
  AttendanceRecord? _todayRecord;
  final List<AttendanceRecord> _records = [];

  // Local preview path setelah ambil foto (sebelum diupload)
  String? _previewCheckInPath;
  String? _previewCheckOutPath;

  bool get _hasCheckedIn => _todayRecord?.checkIn != null;
  bool get _hasCheckedOut => _todayRecord?.checkOut != null;
  bool get _isComplete => _hasCheckedIn && _hasCheckedOut;

  String _formatTime(DateTime? t) {
    if (t == null) return '--.--';
    return '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final today = await _attendanceService.fetchTodayAttendance();
      final history = await _attendanceService.fetchMyAttendances();
      if (mounted) {
        setState(() {
          _todayRecord = today;
          _records
            ..clear()
            ..addAll(history);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startAttendanceFlow() {
    if (_isComplete) return;
    _showPhotoCaptureSheet(isCheckIn: !_hasCheckedIn);
  }

  void _showPhotoCaptureSheet({required bool isCheckIn}) {
    File? pickedFile;
    String? previewPath;
    bool isUploading = false;
    bool photoError = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setModal) {
          Future<void> pickImage(ImageSource source) async {
            final xFile = await _picker.pickImage(
              source: source,
              imageQuality: 80,
              maxWidth: 1280,
            );
            if (xFile == null) return;
            setModal(() {
              pickedFile = File(xFile.path);
              previewPath = xFile.path;
              photoError = false;
            });
          }

          Future<void> doConfirm() async {
            if (pickedFile == null) {
              setModal(() => photoError = true);
              return;
            }
            setModal(() => isUploading = true);
            try {
              final AttendanceRecord record = isCheckIn
                  ? await _attendanceService.checkIn(photoFile: pickedFile!)
                  : await _attendanceService.checkOut(photoFile: pickedFile!);

              if (!ctx.mounted) return;
              Navigator.pop(sheetContext);
              if (mounted) {
                setState(() {
                  _todayRecord = record;
                  if (isCheckIn) {
                    _previewCheckInPath = previewPath;
                  } else {
                    _previewCheckOutPath = previewPath;
                  }
                  // Update riwayat
                  _records
                    ..removeWhere((r) => r.attendanceId == record.attendanceId)
                    ..insert(0, record);
                });
                widget.onAttendanceAction?.call();
                _showSuccessSheet(isCheckIn: isCheckIn, previewPath: previewPath);
              }
            } catch (e) {
              setModal(() => isUploading = false);
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text('Gagal: $e'),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              }
            }
          }

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.line,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              isCheckIn ? AppColors.paleGreen : AppColors.cream,
                          child: Icon(
                            isCheckIn
                                ? Icons.camera_alt_rounded
                                : Icons.logout_rounded,
                            color: isCheckIn
                                ? AppColors.green
                                : AppColors.maroon,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCheckIn
                                    ? 'Presensi Masuk PKL'
                                    : 'Presensi Pulang PKL',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isCheckIn
                                    ? 'Upload foto kehadiran saat tiba di tempat industri.'
                                    : 'Upload foto bukti selesai kerja sebelum pulang.',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Kotak upload / preview foto
                    if (previewPath == null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: photoError
                              ? const Color(0xFFFDE8E8)
                              : AppColors.paper,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: photoError ? Colors.red : AppColors.line,
                            width: photoError ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isUploading) ...[
                              const CircularProgressIndicator(
                                color: AppColors.maroon,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Mengunggah foto ke server...',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ] else ...[
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: AppColors.cream,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.cloud_upload_outlined,
                                  color: photoError
                                      ? Colors.red
                                      : AppColors.maroon,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Upload Foto Bukti Kehadiran',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                photoError
                                    ? 'Foto wajib diambil sebelum konfirmasi!'
                                    : 'Ambil foto selfie atau pilih dari galeri.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: photoError
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  color: photoError
                                      ? Colors.red
                                      : AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          pickImage(ImageSource.camera),
                                      icon: const Icon(
                                          Icons.camera_alt_rounded,
                                          size: 18),
                                      label: const Text('Buka Kamera'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          pickImage(ImageSource.gallery),
                                      icon: const Icon(
                                          Icons.photo_library_rounded,
                                          size: 18),
                                      label: const Text('Pilih Galeri'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        side: const BorderSide(
                                            color: AppColors.line),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: AppColors.green, width: 1.5),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Image.file(
                                  File(previewPath!),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.green,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_rounded,
                                            color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          'Foto Siap Diupload',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.image_rounded,
                                      size: 20, color: AppColors.taupe),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Foto dipilih. Ketuk konfirmasi untuk menyimpan.',
                                      style: TextStyle(
                                          fontSize: 11, color: AppColors.muted),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => setModal(() {
                                      pickedFile = null;
                                      previewPath = null;
                                    }),
                                    icon: const Icon(Icons.refresh_rounded,
                                        size: 15, color: AppColors.maroon),
                                    label: const Text(
                                      'Ganti',
                                      style: TextStyle(
                                        color: AppColors.maroon,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: isUploading ? null : doConfirm,
                      icon: isUploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Icon(isCheckIn
                              ? Icons.check_circle_rounded
                              : Icons.logout_rounded),
                      label: Text(isCheckIn
                          ? 'Konfirmasi & Catat Masuk'
                          : 'Konfirmasi & Catat Pulang'),
                      style: (previewPath == null && !isUploading)
                          ? ElevatedButton.styleFrom(
                              backgroundColor: AppColors.line,
                              foregroundColor: AppColors.muted,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessSheet({
    required bool isCheckIn,
    String? previewPath,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.paleGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isCheckIn
                    ? 'Presensi Masuk Berhasil!'
                    : 'Presensi Pulang Berhasil!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kehadiranmu tercatat dan menunggu konfirmasi dari Pembimbing IDUKA (${widget.idukaMentorName}).',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.muted, fontSize: 12, height: 1.5),
              ),
              if (previewPath != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(previewPath),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 16, color: AppColors.maroon),
                    const SizedBox(width: 8),
                    const Text('Waktu Tercatat:',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.muted)),
                    const Spacer(),
                    Text('${currentTimeLabel()} WIB',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Mengerti & Tutup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttendanceDetail(AttendanceRecord record) {
    final isApproved = record.status == ApprovalStatus.approved;
    final isRejected = record.status == ApprovalStatus.rejected;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(Icons.event_note_rounded,
                        color: AppColors.maroon, size: 22),
                    const SizedBox(width: 8),
                    Text('Detail Presensi Harian',
                        style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateLong(record.attendanceDate),
                  style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 18),

                // Status approval
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? AppColors.paleGreen
                        : isRejected
                            ? const Color(0xFFFDE8E8)
                            : AppColors.paleAmber,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isApproved
                          ? AppColors.green.withOpacity(0.3)
                          : isRejected
                              ? Colors.red.withOpacity(0.3)
                              : AppColors.amber.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isApproved
                            ? AppColors.green
                            : isRejected
                                ? Colors.red.shade400
                                : AppColors.amber,
                        child: Icon(
                          isApproved
                              ? Icons.check_circle_rounded
                              : isRejected
                                  ? Icons.cancel_rounded
                                  : Icons.hourglass_top_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.statusLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isApproved
                                    ? AppColors.green
                                    : isRejected
                                        ? Colors.red.shade700
                                        : AppColors.amber,
                              ),
                            ),
                            if (record.rejectionNote != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Catatan: ${record.rejectionNote}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.taupe),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Presensi Masuk
                const Text(
                  'PRESENSI MASUK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.taupe,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.login_rounded,
                              size: 16, color: AppColors.green),
                          const SizedBox(width: 6),
                          const Text('Waktu Masuk: ',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                          Text(
                            record.checkIn != null
                                ? '${_formatTime(record.checkIn)} WIB'
                                : 'Belum presensi',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      if (record.checkInPhoto != null) ...[
                        const SizedBox(height: 10),
                        PklPhotoThumbnail(
                          imageUrl: record.checkInPhoto!,
                          height: 130,
                          caption: 'Foto Bukti Presensi Masuk',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Presensi Pulang
                const Text(
                  'PRESENSI PULANG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.taupe,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded,
                          size: 16, color: AppColors.maroon),
                      const SizedBox(width: 6),
                      const Text('Waktu Pulang: ',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.muted)),
                      Text(
                        record.checkOut != null
                            ? '${_formatTime(record.checkOut)} WIB'
                            : 'Belum presensi pulang',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tutup Detail'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateLong(DateTime d) {
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final weekday = days[(d.weekday - 1) % 7];
    return '$weekday, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _isComplete
        ? 'Presensi Lengkap'
        : _hasCheckedIn
            ? 'Sedang Praktik'
            : 'Belum Presensi';
    final statusColor = _isComplete
        ? AppColors.green
        : _hasCheckedIn
            ? AppColors.amber
            : AppColors.maroon;

    // Foto yang ditampilkan di banner
    final bannerPhoto = _previewCheckOutPath ??
        _previewCheckInPath ??
        _todayRecord?.checkInPhoto;

    return SafeArea(
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.maroon))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.maroon,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  PageHeading(
                    title: 'Presensi PKL',
                    subtitle:
                        'Upload foto kehadiran untuk konfirmasi Pembimbing IDUKA.',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InfoPill(
                          label: statusLabel,
                          color: _isComplete
                              ? AppColors.paleGreen
                              : _hasCheckedIn
                                  ? AppColors.paleAmber
                                  : AppColors.cream,
                          textColor: statusColor,
                          icon: _isComplete
                              ? Icons.check_circle_outline_rounded
                              : Icons.schedule_rounded,
                        ),
                        const SizedBox(width: 6),
                        const PklNotificationButton(unreadCount: 2),
                      ],
                    ),
                  ),

                  // Live Clock
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.maroon, AppColors.maroonDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentDateLabel().toUpperCase(),
                              style: TextStyle(
                                color: AppColors.cream.withOpacity(0.85),
                                fontSize: 10,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const InfoPill(
                              label: 'PKL AKTIF',
                              color: Color(0x33FFFFFF),
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const LiveClockWidget(isLight: true),
                        const SizedBox(height: 6),
                        Text(
                          'Jam Kerja Industri: 08.00 – 16.00 WIB',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // IDUKA notice
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.paleGreen,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.green.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded,
                            color: AppColors.green, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Presensi dikonfirmasi langsung oleh Pembimbing IDUKA (${widget.idukaMentorName}).',
                            style: const TextStyle(
                              color: AppColors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Foto & Tombol Kehadiran Hari Ini
                  const SectionLabel('Foto Kehadiran Hari Ini'),
                  WhiteCard(
                    padding: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Preview foto
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: bannerPhoto != null
                              ? _buildPhotoWidget(bannerPhoto,
                                  height: 170)
                              : Container(
                                  height: 170,
                                  color: AppColors.cream,
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.camera_alt_outlined,
                                            size: 48,
                                            color: AppColors.maroon),
                                        SizedBox(height: 8),
                                        Text('Belum ada foto hari ini',
                                            style: TextStyle(
                                                color: AppColors.muted,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        // Jam masuk / pulang
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _TimeBlock(
                                  label: 'JAM MASUK',
                                  time: _formatTime(_todayRecord?.checkIn),
                                  complete: _hasCheckedIn,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: AppColors.line,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 14),
                              ),
                              Expanded(
                                child: _TimeBlock(
                                  label: 'JAM PULANG',
                                  time: _formatTime(_todayRecord?.checkOut),
                                  complete: _hasCheckedOut,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isComplete ? null : _startAttendanceFlow,
                          icon: Icon(
                            _isComplete
                                ? Icons.check_circle_rounded
                                : _hasCheckedIn
                                    ? Icons.logout_rounded
                                    : Icons.camera_alt_rounded,
                          ),
                          label: Text(
                            _isComplete
                                ? 'Presensi Hari Ini Selesai'
                                : _hasCheckedIn
                                    ? 'Ambil Foto & Catat Pulang'
                                    : 'Ambil Foto & Catat Masuk',
                          ),
                          style: _isComplete
                              ? ElevatedButton.styleFrom(
                                  disabledBackgroundColor: AppColors.paleGreen,
                                  disabledForegroundColor: AppColors.green,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Riwayat
                  SectionLabel(
                    'Riwayat Kehadiran (Ketuk untuk Detail)',
                    action: '${_records.length} hari',
                  ),
                  WhiteCard(
                    padding: _records.isEmpty ? 16 : 0,
                    child: _records.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'Belum ada riwayat presensi.',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              for (var i = 0;
                                  i < _records.length && i < 14;
                                  i++) ...[
                                if (i > 0)
                                  const Divider(
                                      height: 1,
                                      indent: 16,
                                      endIndent: 16),
                                InkWell(
                                  onTap: () =>
                                      _showAttendanceDetail(_records[i]),
                                  borderRadius: BorderRadius.circular(16),
                                  child: _AttendanceHistoryRow(
                                      record: _records[i]),
                                ),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPhotoWidget(String src, {required double height}) {
    // Jika src adalah path lokal (dari image_picker), gunakan Image.file
    if (src.startsWith('/')) {
      return Image.file(
        File(src),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    // Jika URL (dari Supabase Storage signed URL), gunakan Image.network
    return Image.network(
      src,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: height,
        color: AppColors.cream,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              size: 40, color: AppColors.muted),
        ),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.label,
    required this.time,
    required this.complete,
  });

  final String label;
  final String time;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 9,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              time,
              style: TextStyle(
                color: complete ? AppColors.ink : AppColors.muted,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (complete) ...[
              const SizedBox(width: 5),
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.green, size: 15),
            ],
          ],
        ),
      ],
    );
  }
}

class _AttendanceHistoryRow extends StatelessWidget {
  const _AttendanceHistoryRow({required this.record});

  final AttendanceRecord record;

  String _fmt(DateTime? t) {
    if (t == null) return '--.--';
    return '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = record.status == ApprovalStatus.approved;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Text(
              _fmtDate(record.attendanceDate),
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Masuk: ${_fmt(record.checkIn)}',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Pulang: ${_fmt(record.checkOut)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  record.statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isApproved ? AppColors.green : AppColors.amber,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.muted, size: 19),
        ],
      ),
    );
  }
}
