import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/pkl_models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    this.student,
    this.idukaMentorName = 'Hendro Prasetyo, S.T.',
    this.schedule,
    this.records,
    this.onCheckIn,
    this.onCheckOut,
    this.notifications,
    this.unreadNotificationCount = 2,
    this.onNotificationsOpened,
  });

  final PklUser? student;
  final String idukaMentorName;
  final InternshipSchedule? schedule;
  final List<PklAttendanceRecord>? records;
  final ValueChanged<Uint8List>? onCheckIn;
  final ValueChanged<Uint8List>? onCheckOut;
  final List<PklNotificationItem>? notifications;
  final int unreadNotificationCount;
  final VoidCallback? onNotificationsOpened;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Uint8List? _selectedPhotoBytes;
  String? _selectedPhotoName;

  late List<PklAttendanceRecord> _localRecords;

  @override
  void initState() {
    super.initState();
    _localRecords = widget.records != null
        ? List.from(widget.records!)
        : [
            PklAttendanceRecord(
              id: 'att-demo-1',
              studentAccountId: widget.student?.accountId ?? '0054321980',
              studentName: widget.student?.name ?? 'Ahmad Fauzi',
              date: DateTime(2026, 11, 26),
              checkInTime: '07.50',
              checkOutTime: '16.05',
              checkInPhoto: PklPhotoPresets.coding,
              checkOutPhoto: PklPhotoPresets.report,
              isApprovedByIduka: true,
              idukaApproverName: widget.idukaMentorName,
              idukaApprovalTime: '16.15 WIB',
            ),
            PklAttendanceRecord(
              id: 'att-demo-2',
              studentAccountId: widget.student?.accountId ?? '0054321980',
              studentName: widget.student?.name ?? 'Ahmad Fauzi',
              date: DateTime(2026, 11, 25),
              checkInTime: '07.45',
              checkOutTime: '16.10',
              checkInPhoto: PklPhotoPresets.meeting,
              checkOutPhoto: PklPhotoPresets.report,
              isApprovedByIduka: true,
              idukaApproverName: widget.idukaMentorName,
              idukaApprovalTime: '16.20 WIB',
            ),
          ];
  }

  @override
  void didUpdateWidget(covariant AttendanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.records != null && widget.records != oldWidget.records) {
      _localRecords = List.from(widget.records!);
    }
  }

  PklAttendanceRecord? get _todayRecord {
    final now = DateTime.now();
    for (final r in _localRecords) {
      if (r.date.year == now.year &&
          r.date.month == now.month &&
          r.date.day == now.day) {
        return r;
      }
    }
    return null;
  }

  void _submitAttendance(bool isCheckIn) {
    final bytes = _selectedPhotoBytes;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCheckIn
                ? 'Pilih foto dari perangkat terlebih dahulu untuk presensi masuk.'
                : 'Pilih foto dari perangkat terlebih dahulu untuk presensi pulang.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';

    if (isCheckIn) {
      if (widget.onCheckIn != null) {
        widget.onCheckIn!(bytes);
      } else {
        setState(() {
          _localRecords.insert(
            0,
            PklAttendanceRecord(
              id: 'att-${now.microsecondsSinceEpoch}',
              studentAccountId: widget.student?.accountId ?? '0054321980',
              studentName: widget.student?.name ?? 'Ahmad Fauzi',
              date: DateTime(now.year, now.month, now.day),
              checkInTime: timeStr,
              checkInPhotoBytes: bytes,
            ),
          );
        });
      }
    } else {
      if (widget.onCheckOut != null) {
        widget.onCheckOut!(bytes);
      } else {
        setState(() {
          final idx = _localRecords.indexWhere(
            (r) =>
                r.date.year == now.year &&
                r.date.month == now.month &&
                r.date.day == now.day,
          );
          if (idx != -1) {
            _localRecords[idx] = _localRecords[idx].copyWith(
              checkOutTime: timeStr,
              checkOutPhotoBytes: bytes,
            );
          }
        });
      }
    }

    setState(() {
      _selectedPhotoBytes = null;
      _selectedPhotoName = null;
    });

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
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
                    ? 'Foto Presensi Masuk Berhasil Diunggah!'
                    : 'Foto Presensi Pulang Berhasil Diunggah!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kehadiranmu tercatat pukul $timeStr WIB dan menunggu validasi dari Mentor IDUKA (${widget.idukaMentorName}).',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Mengerti & Tutup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttendanceDetail(PklAttendanceRecord record) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                    Text(
                      'Detail Presensi Harian',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.shortWeekday}, ${record.shortDate}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: record.isApprovedByIduka
                        ? AppColors.paleGreen
                        : AppColors.paleAmber,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: record.isApprovedByIduka
                          ? AppColors.green.withValues(alpha: 0.3)
                          : AppColors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: record.isApprovedByIduka
                            ? AppColors.green
                            : record.isRejectedByIduka
                                ? AppColors.maroon
                                : AppColors.amber,
                        child: Icon(
                          record.isApprovedByIduka
                              ? Icons.check_circle_rounded
                              : record.isRejectedByIduka
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
                              record.approvalStatusLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: record.isApprovedByIduka
                                    ? AppColors.green
                                    : record.isRejectedByIduka
                                        ? AppColors.maroon
                                        : AppColors.amber,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (record.isApprovedByIduka ||
                                      record.isRejectedByIduka)
                                  ? 'Oleh ${record.idukaApproverName ?? widget.idukaMentorName} • ${record.idukaApprovalTime ?? '-'}'
                                  : 'Pembimbing industri: ${widget.idukaMentorName}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.taupe,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
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
                            record.checkInTime != null
                                ? '${record.checkInTime} WIB'
                                : 'Belum presensi',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      if (record.checkInPhotoBytes != null ||
                          record.checkInPhoto != null) ...[
                        const SizedBox(height: 10),
                        PklPhotoThumbnail(
                          imageBytes: record.checkInPhotoBytes,
                          imageUrl: record.checkInPhoto,
                          height: 130,
                          caption: 'Foto Bukti Presensi Masuk',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.logout_rounded,
                              size: 16, color: AppColors.maroon),
                          const SizedBox(width: 6),
                          const Text('Waktu Pulang: ',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                          Text(
                            record.checkOutTime != null
                                ? '${record.checkOutTime} WIB'
                                : 'Belum presensi pulang',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      if (record.checkOutPhotoBytes != null ||
                          record.checkOutPhoto != null) ...[
                        const SizedBox(height: 10),
                        PklPhotoThumbnail(
                          imageBytes: record.checkOutPhotoBytes,
                          imageUrl: record.checkOutPhoto,
                          height: 130,
                          caption: 'Foto Bukti Presensi Pulang',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup Detail'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayRecord;
    final hasCheckedIn = today?.checkInTime != null;
    final hasCheckedOut = today?.checkOutTime != null;
    final isComplete = hasCheckedIn && hasCheckedOut;

    final activeSchedule = widget.schedule ??
        InternshipSchedule(
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 12, 31),
          durationMonths: 6,
        );
    final now = DateTime.now();
    final isWeekend =
        now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    final statusLabel = isComplete
        ? 'Presensi Lengkap'
        : hasCheckedIn
            ? 'Sudah Masuk'
            : 'Belum Presensi';
    final statusColor = isComplete
        ? AppColors.green
        : hasCheckedIn
            ? AppColors.amber
            : AppColors.maroon;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Presensi PKL',
            subtitle: 'Upload foto dari perangkat untuk masuk & pulang.',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoPill(
                  label: statusLabel,
                  color: isComplete
                      ? AppColors.paleGreen
                      : hasCheckedIn
                          ? AppColors.paleAmber
                          : AppColors.cream,
                  textColor: statusColor,
                  icon: isComplete
                      ? Icons.check_circle_outline_rounded
                      : Icons.schedule_rounded,
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

          // Live Clock & Operational Time Banner
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
                        color: AppColors.cream.withValues(alpha: 0.85),
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    InfoPill(
                      label: isWeekend ? 'SABTU/MINGGU LIBUR' : 'PKL 6 BULAN',
                      color: const Color(0x33FFFFFF),
                      textColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const LiveClockWidget(isLight: true),
                const SizedBox(height: 6),
                Text(
                  'Hari Kerja: Senin–Jumat (${activeSchedule.totalWorkingDays} hari kerja / 6 bulan) • Sabtu & Minggu Libur',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Durasi PKL Summary Card
          WhiteCard(
            padding: 14,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.cream,
                  child: Icon(Icons.date_range_rounded,
                      color: AppColors.maroon, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Periode ${activeSchedule.durationMonths} Bulan (${activeSchedule.periodLabel})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Berjalan ${activeSchedule.elapsedWorkingDays()} hari • Sisa ${activeSchedule.remainingWorkingDays()} hari kerja',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Presensi Masuk / Pulang with Device Photo Picker
          SectionLabel(
            !hasCheckedIn
                ? 'Presensi Masuk Hari Ini'
                : !hasCheckedOut
                    ? 'Presensi Pulang Hari Ini'
                    : 'Presensi Hari Ini Selesai',
          ),
          WhiteCard(
            padding: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasCheckedIn) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.paleGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.login_rounded,
                            color: AppColors.green, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Presensi masuk tercatat pukul ${today!.checkInTime} WIB',
                            style: const TextStyle(
                              color: AppColors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (hasCheckedOut) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.paleGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded,
                            color: AppColors.green, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Presensi pulang tercatat pukul ${today!.checkOutTime} WIB',
                            style: const TextStyle(
                              color: AppColors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAttendanceDetail(today),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Lihat Foto Masuk & Pulang Hari Ini'),
                  ),
                ] else ...[
                  DevicePhotoPickerBox(
                    selectedBytes: _selectedPhotoBytes,
                    selectedFileName: _selectedPhotoName,
                    title: !hasCheckedIn
                        ? 'Upload Foto Presensi Masuk'
                        : 'Upload Foto Presensi Pulang',
                    subtitle: 'Pilih foto dari perangkat pengguna.',
                    onPhotoSelected: (bytes, name) {
                      setState(() {
                        _selectedPhotoBytes = bytes;
                        _selectedPhotoName = name;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () => _submitAttendance(!hasCheckedIn),
                    icon: Icon(
                      !hasCheckedIn
                          ? Icons.login_rounded
                          : Icons.logout_rounded,
                    ),
                    label: Text(
                      !hasCheckedIn
                          ? 'Kirim Presensi Masuk'
                          : 'Kirim Presensi Pulang',
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),

          SectionLabel(
            'Riwayat Presensi',
            action: '${_localRecords.length} catatan',
          ),
          ..._localRecords.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WhiteCard(
                padding: 14,
                onTap: () => _showAttendanceDetail(record),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: record.isApprovedByIduka
                          ? AppColors.paleGreen
                          : record.isRejectedByIduka
                              ? AppColors.cream
                              : AppColors.paleAmber,
                      child: Icon(
                        record.isApprovedByIduka
                            ? Icons.verified_rounded
                            : record.isRejectedByIduka
                                ? Icons.cancel_rounded
                                : Icons.hourglass_top_rounded,
                        color: record.isApprovedByIduka
                            ? AppColors.green
                            : record.isRejectedByIduka
                                ? AppColors.maroon
                                : AppColors.amber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${record.shortWeekday}, ${record.shortDate}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Masuk: ${record.checkInTime ?? '-'} • Pulang: ${record.checkOutTime ?? '-'}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          InfoPill(
                            label: record.approvalStatusLabel,
                            color: record.isApprovedByIduka
                                ? AppColors.paleGreen
                                : record.isRejectedByIduka
                                    ? AppColors.cream
                                    : AppColors.paleAmber,
                            textColor: record.isApprovedByIduka
                                ? AppColors.green
                                : record.isRejectedByIduka
                                    ? AppColors.maroon
                                    : AppColors.amber,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.muted),
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
